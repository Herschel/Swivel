/**
 * ...
 * @author Newgrounds.com, Inc.
 * Tracks sound events over LocalConnection
 */

package com.newgrounds.swivel.swf;
import com.newgrounds.swivel.audio.AudioTracker;
import format.as1.Data;
import format.swf.Data;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class SoundConnectionMutator implements ISWFMutator
{
	public var connectionName : String;
	
	private var _audioTracker : AudioTracker;
	private var _streamId : Int;
	private var _clipClasses : IntHash<String>;
	
	public function new(connectionName : String, audioTracker : AudioTracker) {
		this.connectionName = connectionName;
		_audioTracker = audioTracker;
		_streamId = 0;
		_clipClasses = new IntHash();
	}
	
	public function mutate(swf : SwivelSwf) : Void {
		swf.mapClips(injectSoundLogging);
		finalize(swf);
	}
	
	private function injectSoundLogging(id : Int, tags : Array<SWFTag>) : Array<SWFTag> {
		var stream : SoundStream = null;
		var streamFrame : Int = 0;
		var i : Int = 0;
		
		var streamData : Array<Bytes> = null;
		var currentStreamPacket : BytesOutput = null;
		var frame : Int = 0;
		var lastStreamData : Int = 0;
		
		
		function finalizeStream() {
			if(stream == null || streamData == null) return;
			
			if (currentStreamPacket != null) streamData.push(currentStreamPacket.getBytes());
			
			// FIX for dolphinn.swf
			if(streamData[0].length > 0) {
				_audioTracker.registerSound({
					id:				com.newgrounds.swivel.audio.SoundClip.SoundClipId.stream(_streamId),
					format:			stream.format,
					is16bit:		stream.soundIs16bit,
					isStereo:		stream.soundIsStereo,
					sampleRate:		stream.soundRate,
					numSamples:		null, // stream.samples, MIKE: stream sounds were getting truncated weirdly!?
					latencySeek: 	stream.seek,
					data:			streamData
				});
			}
			
			_streamId++;
			currentStreamPacket = null;
			streamData = null;
			streamFrame = 0;
		}
	
		while(i < tags.length) {
			var tag = tags[i];
			switch(tag) {
				case TSound(sound):
					_audioTracker.registerSound( {
						id:				event(sound.sid),
						format:			sound.format,
						is16bit:		sound.is16bit,
						isStereo:		sound.isStereo,
						sampleRate:		sound.rate,
						numSamples:		Int32.toNativeInt(sound.samples),
						latencySeek: 	switch(sound.data) {
							case SDMp3(seek, _):	seek;
							default:				0;
						},
						data:			switch(sound.data) {
							case SDMp3(_, d):	[d];
							case SDOther(d):	[d];
						},
					});
					
				case TStartSound(soundId, infos):
					var newTag = handleStartSound(id, frame, soundId, infos);
					if(newTag != null) tags[i] = newTag;
				
				case TSoundStream(streamInfo):
					stream = streamInfo;

				case TSymbolClass(links):
					for(link in links) {
						_clipClasses.set(link.cid, link.className);
						var sound = _audioTracker.getSound(event(link.cid));
						if(sound != null) {
							_audioTracker.registerSound({
								id:				actionScript(link.className),
								format:			sound.format,
								is16bit:		sound.is16bit,
								isStereo:		sound.isStereo,
								sampleRate:		sound.sampleRate,
								latencySeek: 	sound.latencySeek,
								numSamples:		sound.numSamples,
								data:			sound.data,
							});
						}
					}
					
				case TExport(exports):
					for(e in exports) {
						var sound = _audioTracker.getSound(event(e.cid));
						if(sound != null) {
							_audioTracker.registerSound({
								id:				actionScript(e.name),
								format:			sound.format,
								is16bit:		sound.is16bit,
								isStereo:		sound.isStereo,
								sampleRate:		sound.sampleRate,
								latencySeek: 	sound.latencySeek,
								numSamples:		sound.numSamples,
								data:			sound.data,
							});
						}
					}
					
				case TShowFrame:
					if(stream != null && streamData != null && lastStreamData >= frame-4) {
						var newTag = handleStreamFrame(id, frame, _streamId, streamFrame);
						if(newTag != null) {
							tags.insert(i, newTag);
							i++;
						}
						streamFrame++;
					}
					frame++;

				case TSoundStreamData(data):
					if(streamData == null || lastStreamData < frame-1) {
						finalizeStream();
						streamData = [];
					}
										
					lastStreamData = frame;
					
					switch(stream.format) {
						case SFMP3:		if (currentStreamPacket == null) currentStreamPacket = new BytesOutput();  if(data.length >= 4) currentStreamPacket.writeBytes(data, 4, data.length - 4);
						case SFADPCM:	streamData.push(data);
						default:		if (currentStreamPacket == null) currentStreamPacket = new BytesOutput(); currentStreamPacket.write(data);
					}

				default:
			};

		i++;
		}
		
		finalizeStream();
		
		return tags;
	}
	
	private function handleStartSound(clipId : Int, frame : Int, soundId : Int, infos : SoundInfo) : SWFTag {
		var envelope = [];
		var len = 0;
		if(infos.envelope != null) {
			for (point in infos.envelope) {
				envelope.push( PInt(point.position) );
				envelope.push( PInt(Int32.ofInt(point.leftLevel)) );
				envelope.push( PInt(Int32.ofInt(point.rightLevel)) );
				len += 3;
			}
		}
		envelope.reverse();
		envelope.push( PInt( Int32.ofInt(len) ) );
		
		return TDoActions( SwivelSwf.getAvm1Bytes([
			APush( envelope ),
			AInitArray,
			APush([
				PInt( Int32.ofInt(infos.loops) ),
				if( infos.outPoint != null ) PInt( infos.outPoint ) else PNull,
				if( infos.inPoint != null ) PInt( infos.inPoint ) else PNull,
				PInt( Int32.ofInt(Type.enumIndex(infos.sync)) ),
				PInt( Int32.ofInt(soundId) ),
				PInt( Int32.ofInt(0) ),
				PString("__getFrame"),
			]),
			ACall,
			APush( [PString("startSound"), PInt(Int32.ofInt(8)), PString("__swivel")] ),
			ACall,
			APop
		]) );
	}

	private function handleStreamFrame(clipId : Int, clipFrame : Int, streamId : Int, streamFrame : Int) : SWFTag {
		return TDoActions( SwivelSwf.getAvm1Bytes([
			APush([
				PInt( Int32.ofInt(streamFrame) ),
				PInt( Int32.ofInt(streamId) ),
				PInt( Int32.ofInt(0) ),
				PString("__getFrame"),
			]),
			ACall,
			APush( [PString("streamSound"), PInt(Int32.ofInt(4)), PString("__swivel")] ),
			ACall,
			APop,
		]) );
	}
	
	private function finalize(swf : SwivelSwf) {
		swf.prepend(SwfUtils.getAs2Tag("AS2SoundLogger"));
	}
}