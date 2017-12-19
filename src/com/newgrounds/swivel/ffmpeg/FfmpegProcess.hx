/*
 * Swivel
 * Copyright (C) 2012-2017, Newgrounds.com, Inc.
 * https://github.com/Herschel/Swivel
 *
 * Swivel is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Swivel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Swivel.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.newgrounds.swivel.ffmpeg;
import com.huey.events.Dispatcher;
import com.huey.events.Dispatcher;
import com.huey.utils.Logger;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.Lib;
import flash.utils.ByteArray;

class FfmpegProcess
{
	public var onComplete(default, null) : Dispatcher<Dynamic>;
	
	private static var _ffmpegFolder : File;
	
	private var _closed : Bool;
	private var _ffmpeg : NativeProcess;
	
	public function new(args : Array<String>) {
		onComplete = new Dispatcher();
		
		if (_ffmpegFolder == null) {
			try {
				var xmlData = flash.desktop.NativeApplication.nativeApplication.applicationDescriptor.toString();
				xmlData = StringTools.replace(xmlData, "xmlns", "x");
				var xml = Xml.parse(xmlData).firstElement();
				var fast = new haxe.xml.Fast( xml );
				_ffmpegFolder = File.applicationDirectory.resolvePath( fast.node.ffmpegPath.innerData );
			} catch (e:Dynamic) {
				_ffmpegFolder = File.applicationDirectory.resolvePath("ffmpeg/win32");
			}
		}
		_closed = false;
		
		
		var ffmpegFile : File = getFfmpegExecutable();
		
		var startupInfo = new NativeProcessStartupInfo();
		startupInfo.executable = ffmpegFile;
		startupInfo.workingDirectory = ffmpegFile.parent;
		
		startupInfo.arguments = flash.Vector.ofArray(args);
		Logger.log("FfmpegLog", Std.string(args) + "\n");
		
		_ffmpeg = new NativeProcess();
		
		_ffmpeg.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onStdinProgress);
		_ffmpeg.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onStdinError);
		_ffmpeg.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStderr);
		_ffmpeg.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStdOutData);
		_ffmpeg.addEventListener(NativeProcessExitEvent.EXIT, onFfmpegExit);
		_ffmpeg.start(startupInfo);
	}
	
	private function getFfmpegExecutable() : File {
		var ffmpegFile = _ffmpegFolder;
		switch( flash.system.Capabilities.os.split(" ")[0] ) {
			case "Windows":
				#if win32
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg.exe");
				#else
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg.exe");
				#end
			case "Mac":
				#if mac32
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg");
				#else
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg");
				#end
			default:			throw "Unsupported OS";
		}
		return ffmpegFile;
	}
	
	public function send(data) : Void {
		_ffmpeg.standardInput.writeBytes( data );
	}
	
	public function close(?force : Bool = false) : Void {
		_closed = true;
		_ffmpeg.closeInput();
		if(force) _ffmpeg.exit(true);
	}
	
	private function onStdinProgress(_) : Void {
	}
	
	private function onStdinError(event) : Void {
		Logger.log("FfmpegLog", Std.string(event));
		event.preventDefault();
	}
	
	private function onStdOutData(_) : Void {
		Logger.log("FfmpegLog", _ffmpeg.standardOutput.readUTFBytes(_ffmpeg.standardOutput.bytesAvailable) );
	}
	
	private function onStderr(_) : Void {
		var output : String = _ffmpeg.standardError.readUTFBytes(_ffmpeg.standardError.bytesAvailable);
		Logger.log("FfmpegLog", output);
	}
	
	private function onFfmpegExit(e) : Void {
		flash.system.System.resume();
		onComplete.dispatch(e.exitCode);
	}
	
}


class FfmpegEncoder extends FfmpegProcess
{
	
	public static var AUDIO_CODECS : Array<AudioCodec> = [
		{label: "AAC", codec: "aac", supportsBitRate: true},
		{label: "Raw PCM 16-bit", codec: "pcm_s16le", supportsBitRate: false},
		{label: "MP3", codec: "mp3", supportsBitRate: true},
		{label: "Vorbis", codec: "libvorbis", supportsBitRate: true},
		{label: "Windows Media Audio", codec: "wmav2", supportsBitRate: true},
	];
	
	public static var PRESETS : Array<VideoPreset> = [
		{label: "H.264 High", fileFormat: "mp4", codec: "libx264", supportsBitRate: true, extraParameters: ["-preset","slow","-pix_fmt","yuv420p"], supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[2]]},
		{label: "H.264 Main", fileFormat: "mp4", codec: "libx264", supportsBitRate: true, extraParameters: ["-preset","slow","-profile:v","main","-pix_fmt","yuv420p"], supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[2]]},
		{label: "H.264 Baseline", fileFormat: "mp4", codec: "libx264", supportsBitRate: true, extraParameters: ["-preset","slow","-profile:v","baseline","-pix_fmt","yuv420p"], supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[2]]},
		{label: "MPEG-2 Video", fileFormat: "mpg", codec: "mpeg2video", supportsBitRate: true, extraParameters: ["-preset","slow"], supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[2]]},
		{label: "Theora", fileFormat: "ogg", codec: "theora", supportsBitRate: true, extraParameters: ["-preset","slow"], supportedAudioCodecs: [AUDIO_CODECS[3]]},
		{label: "QuickTime Animation", fileFormat: "mov", codec: "qtrle", supportsBitRate: false, extraParameters: null,supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[1], AUDIO_CODECS[2]]},
		{label: "Uncompressed AVI", fileFormat: "avi", codec: "rawvideo", supportsBitRate: false, extraParameters: ["-pix_fmt","bgr24"], supportedAudioCodecs: [AUDIO_CODECS[1], AUDIO_CODECS[2]]},
		{label: "VP8", fileFormat: "webm", codec: "vp8", supportsBitRate: true, extraParameters: ["-preset","slow"], supportedAudioCodecs: [AUDIO_CODECS[3]]},
		{label: "Windows Media Video", fileFormat: "wmv", codec: "wmv2", supportsBitRate: true, extraParameters: ["-preset","slow"], supportedAudioCodecs: [AUDIO_CODECS[4]]},
		{label: "Xvid (MPEG-4 part 2)", fileFormat: "mp4", codec: "mpeg4", supportsBitRate: true, extraParameters: ["-preset","slow"], supportedAudioCodecs: [AUDIO_CODECS[0], AUDIO_CODECS[2]]},
	];
	public static var TRANSPARENT_PRESETS : Array<VideoPreset> = [
		PRESETS[3],
	];
	//private var _proc : FfmpegProcess;
	
	private var _framesSent : Int;
	private var _framesReceived : Int;
	private var _framesEncoded : Int;
	
	private var _isWindows : Bool;

	private var _frameQueue : Array<ByteArray>;
	inline private static var FRAME_QUEUE_SIZE : Int = 2;
	
	public var onFrameReceived(default, null) : Dispatcher<Dynamic>;
	
	public function new(preset : VideoPreset, videoBitRate : Null<Int>, outputFile : File, width : UInt, height : UInt, frameRate : Float, ?audioFile : String, ?audioCodec : AudioCodec, ?audioBitRate : Null<Int>, ?numChannels : Int, ?pngPath : File, ?keyframeEvery : Null<Int>) {
		_framesSent = _framesReceived = _framesEncoded = 0;
		_frameQueue = new Array();
			
		onFrameReceived = new Dispatcher();
		var params = [
			"-threads",	"0",			// multithreading
			"-y",						// overwrite output silently
						
			// read video from stdin
			"-f", "rawvideo",
			"-pix_fmt", "argb",
			"-s", width + "x" + height,
			"-r", Std.string(frameRate),
			"-i", "-",
		];
		
		if(audioFile == null) params.push("-an");
		else {
			params.push("-i");
			params.push(audioFile);
			params.push("-c:a");
			if(audioCodec == null) {
				params.push("copy");
			} else {
				params.push(audioCodec.codec);
				if(audioBitRate != null) {
					params.push("-b:a");
					params.push(Std.string(audioBitRate));
				}
				params.push("-ac");
				params.push(Std.string(numChannels));
			}
		}
		
		params.push("-c:v");
		params.push(preset.codec);
		
		if(videoBitRate != null) {
			params.push("-b:v");
			params.push(Std.string(videoBitRate));
		} else if(preset.supportsBitRate) {
			params.push("-q");
			params.push("0");
		}
		
		if(preset.extraParameters != null) {
			for(p in preset.extraParameters) params.push(p);
		}
		
		if (keyframeEvery != null) {
			params.push("-g");
			params.push(Std.string(keyframeEvery));
		}
		
		params.push("-aspect");
		params.push(width + ":" + height);

		params.push("-strict");
		params.push("-2");
		
		params.push(outputFile.nativePath);

		if (pngOutput == true) {
			params.push("-an");
			params.push("-c:v");
			params.push("png");
			params.push(pngPath.nativePath);
		}
		

		
		super( params );
	}
	
	private override function getFfmpegExecutable() : File {
		var ffmpegFile = FfmpegProcess._ffmpegFolder;
		switch( flash.system.Capabilities.os.split(" ")[0] ) {
			case "Windows":
				_isWindows = true;
				#if win32
					ffmpegFile = ffmpegFile.resolvePath("redirecter.exe");
				#else
					ffmpegFile = ffmpegFile.resolvePath("redirecter.exe");
				#end
			case "Mac":
				_isWindows = false;
				#if mac32
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg");
				#else
					ffmpegFile = ffmpegFile.resolvePath("ffmpeg");
				#end
			default:			throw "Unsupported OS";
		}
		return ffmpegFile;
	}
	
	public override function send(frame : ByteArray) {
		//if(_closed) return;
		
		_frameQueue.push(frame);
		_framesSent++;

		if(_frameQueue.length == 1) sendNextFrame();
		if(_frameQueue.length >= FRAME_QUEUE_SIZE) flash.system.System.pause();
	}
	
	private function sendNextFrame() {
		if(_frameQueue.length > 0) {
			super.send(_frameQueue[0]);
		}
		
		if(_frameQueue.length < FRAME_QUEUE_SIZE) flash.system.System.resume();
	}
	
	public override function close(?force : Bool = false) : Void {
		_closed = true;
		if (_framesReceived >= _framesSent)
			_ffmpeg.closeInput();
		if(force) _ffmpeg.exit(true);
	}
		
	private override function onStderr(_) : Void {
		var output : String = _ffmpeg.standardError.readUTFBytes(_ffmpeg.standardError.bytesAvailable);
		Logger.log("FfmpegLog", output);
						
		var frameRegex : EReg = ~/frame=\s*(\d+).*/;
		if ( frameRegex.match(output) ) {
			_framesEncoded = Std.parseInt( frameRegex.matched(1) );
		}
	}
	
	private override function onStdinError(event) : Void {
		Logger.log("FfmpegLog", Std.string(event));
		event.preventDefault();
		
		_framesReceived++;
		//trace("Ercvd: " + _framesReceived);
		if (_closed && _framesReceived >= _framesSent) _ffmpeg.closeInput();
		if(!_isWindows) { _frameQueue.shift(); sendNextFrame(); }
	}
	
	private override function onStdinProgress(_) : Void {
		_framesReceived++;
		//trace("Prcvd: " + _framesReceived);
		if (_closed && _framesReceived >= _framesSent) _ffmpeg.closeInput();
		if(!_isWindows) { _frameQueue.shift(); sendNextFrame(); }
	}
	
	private override function onStdOutData(_) : Void {
		if(_isWindows) { _frameQueue.shift(); sendNextFrame(); }
	}
}
