package com.newgrounds.swivel.audio;
import com.huey.events.Dispatcher;
import com.newgrounds.swivel.ffmpeg.FfmpegProcess;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Decoder
{
	public var onComplete(default, null) : Dispatcher<Dynamic>;
	
	private var _clip : SoundClip;
	private var _ffmpeg : FfmpegProcess;
	
	private var _outFile : File;
	
	public function new(clip : SoundClip) {
		onComplete = new Dispatcher();
		_clip = clip;
	}
	
	public function start() : Void {
		// TODO: sometiems we are getting 0 length streams
		if(_clip.data[0].length == 0) {
			onComplete.dispatch();
			return;
		}
		
		var inFile : File = File.applicationStorageDirectory.resolvePath("temp_clipIn");
		_outFile = File.applicationStorageDirectory.resolvePath("temp_clipOut");
		var fileStream : FileStream = new FileStream();
		
		var useFlv = false;
		
		var args = ["-y", "-f"];
		
		args.push( switch(_clip.format) {
			case SFNativeEndianUncompressed,SFLittleEndianUncompressed:
				if (_clip.is16bit) "s16le" else "u8";
			case SFNellymoser,SFNellymoser16k,SFNellymoser8k,SFADPCM,SFSpeex:
				useFlv = true; "flv";
			case SFMP3:
				"mp3";
		} );
		
		switch(_clip.format) {
			case SFNativeEndianUncompressed,SFLittleEndianUncompressed:
				args = args.concat([
					"-ac",	_clip.isStereo ? "2" : "1",
					"-ar",
					switch(_clip.sampleRate) {
						case SR5k:	"5512";
						case SR11k:	"11025";
						case SR22k:	"22050";
						case SR44k:	"44100";
					}
				]);
			default:
		}
		
		args = args.concat(["-i", inFile.nativePath]);
		
		args = args.concat( [
			"-f",	"s16le",
			"-ac",  "2",
			"-ar",	"44100",
			_outFile.nativePath
		] );
		
		fileStream.open( inFile, FileMode.WRITE );
		if (useFlv) writeFlvData(_clip, fileStream);
		else writeAudioData(_clip, fileStream);
		fileStream.close();
		
		trace(args);

		_ffmpeg = new FfmpegProcess(args);
		
		_ffmpeg.onComplete.add(onDecodeComplete);
	}

	private function writeAudioData(sound : SoundClip, out : FileStream) : Void {
		out.writeBytes(sound.data[0].getData());
	}
	
	private function writeFlvData(sound : SoundClip, out : FileStream) : Void {
		out.endian = flash.utils.Endian.BIG_ENDIAN;
			
		out.writeUTFBytes("FLV");
		out.writeByte(1);
		out.writeByte(0x4);			// audio only
		out.writeUnsignedInt(0x9);	// header size
					
		// tag size
		out.writeUnsignedInt(0);
		
		for(packet in sound.data) {
			var pos = out.position;
			
			out.writeByte(0x8);			// audio
			
			// data size
			var dataSize: Int = packet.length + 1;
			out.writeByte((dataSize >> 16) & 0xff);
			out.writeByte((dataSize >> 8) & 0xff);
			out.writeByte(dataSize & 0xff);
			
			out.writeByte(0);		// timestamp TODO: write an actual value here? seems to work ok regardless
			out.writeShort(0);
			out.writeByte(0);		// timestamp ext.
			
			out.writeByte(0);		// stream id
			out.writeShort(0);
			
			// audio tag header
			var tagHeader : Int = 0x2;
			tagHeader |= switch(sound.format) {
				case SFADPCM:				0x10;
				case SFNellymoser16k:		0x40;
				case SFNellymoser8k:		0x50;
				case SFNellymoser:			0x60;
				case SFSpeex:				0xb0;
				default:					throw("FlvDecoder does not support codec " + sound.format);
			}
			
			tagHeader |= switch(sound.sampleRate) {
				case SR5k:		0;
				case SR11k:		0x4;
				case SR22k:		0x8;
				case SR44k:		0xc;
			}
			
			if (sound.isStereo) tagHeader |= 0x1;
			out.writeByte(tagHeader);
			
			out.writeBytes(packet.getData());
			
			out.writeUnsignedInt( Std.int(out.position - pos) );
		}
	}
	
	private function onDecodeComplete(exitCode) : Void {
		try {
			if(exitCode == 0) {
				var fileStream : FileStream = new FileStream();
				fileStream.open( _outFile, FileMode.READ );
				
				var byteArray : ByteArray = new ByteArray();
				var skipCount = _clip.latencySeek * 4;
				var scale = switch(_clip.sampleRate) {
					case SR5k:		8;
					case SR11k:		4;
					case SR22k:		2;
					case SR44k:		1;
				}

				fileStream.position += skipCount * scale;
				var len = if(_clip.numSamples != null) _clip.numSamples * 4 * scale else fileStream.bytesAvailable;
				if(len > Std.int(fileStream.bytesAvailable)) len = Std.int(fileStream.bytesAvailable);
				fileStream.readBytes(byteArray, 0, len);
				fileStream.close();
				
				_clip.data = [Bytes.ofData(byteArray)];
			} else {
				_clip.data = [Bytes.alloc(0)];
			}
		} catch(_ : Dynamic) {
			_clip.data = [Bytes.alloc(0)];
		}
		
		onComplete.dispatch();
	}
}
