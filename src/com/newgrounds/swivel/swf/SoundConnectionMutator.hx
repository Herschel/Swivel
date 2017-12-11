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

package com.newgrounds.swivel.swf;
import com.newgrounds.swivel.audio.AudioTracker;
import format.as1.Data;
import format.swf.Data;
import haxe.Int32;
import haxe.ds.IntMap;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

/**
 * Tracks sounds playing in an SWF using LocalConnection.
 */
class SoundConnectionMutator implements ISWFMutator
{
	public var connectionName : String;
	
	private var _audioTracker : AudioTracker;
	private var _streamId : Int;
	private var _clipClasses : IntMap<String>;
	
	public function new(connectionName : String, audioTracker : AudioTracker) {
		this.connectionName = connectionName;
		_audioTracker = audioTracker;
		_streamId = 0;
		_clipClasses = new IntMap();
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
					format:			stream.streamFormat,
					is16bit:		stream.streamIs16bit,
					isStereo:		stream.streamIsStereo,
					sampleRate:		stream.streamRate,
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
						numSamples:		sound.samples,
						latencySeek: 	switch(sound.data) {
							case SDMp3(seek, _):	seek;
							default:				0;
						},
						data:			switch(sound.data) {
							case SDMp3(_, d):	[d];
							case SDRaw(d):		[d];
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

				case TSoundStreamBlock(data):
					if(streamData == null || lastStreamData < frame-1) {
						finalizeStream();
						streamData = [];
					}
										
					lastStreamData = frame;
					
					switch(stream.streamFormat) {
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
	
	private function handleStartSound(clipId : Int, frame : Int, soundId : Int, infos : StartSoundInfo) : SWFTag {
		var envelope = [];
		var len = 0;
		if(infos.envelope != null) {
			for (point in infos.envelope) {
				envelope.push( PInt(point.pos) );
				envelope.push( PInt(point.leftVolume) );
				envelope.push( PInt(point.rightVolume) );
				len += 3;
			}
		}
		envelope.reverse();
		envelope.push( PInt( len ) );
		
		var sync = if( infos.stop ) 2 else if( infos.noMultiple ) 1 else 0;
		return TDoActions( SwivelSwf.getAvm1Bytes([
			APush( envelope ),
			AInitArray,
			APush([
				PInt( infos.numLoops ),
				if( infos.endPos != null ) PInt( infos.endPos ) else PNull,
				if( infos.startPos != null ) PInt( infos.startPos ) else PNull,
				PInt( sync ),
				PInt( soundId ),
				PInt( 0 ),
				PString("__getFrame"),
			]),
			ACall,
			APush( [PString("startSound"), PInt(8), PString("__swivel")] ),
			ACall,
			APop
		]) );
	}

	private function handleStreamFrame(clipId : Int, clipFrame : Int, streamId : Int, streamFrame : Int) : SWFTag {
		return TDoActions( SwivelSwf.getAvm1Bytes([
			APush([
				PInt( streamFrame ),
				PInt( streamId ),
				PInt( 0 ),
				PString("__getFrame"),
			]),
			ACall,
			APush( [PString("streamSound"), PInt(4), PString("__swivel")] ),
			ACall,
			APop,
		]) );
	}
	
	private function finalize(swf : SwivelSwf) {
		swf.prepend(SwfUtils.getAs2Tag("AS2SoundLogger"));
	}
}