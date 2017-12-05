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

package com.newgrounds.swivel.audio;

import com.huey.events.Dispatcher;
import com.huey.utils.Logger;
import flash.filesystem.FileStream;
import haxe.Int32;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import com.newgrounds.swivel.swf.SwivelConnection.ISwivelConnection;
import haxe.io.Eof;
import format.swf.Data;
import com.newgrounds.swivel.audio.SoundClip.SoundClipId;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AudioTracker
{
	public var onSoundsDecoded : Dispatcher<Dynamic>;
	public var onMixingComplete : Dispatcher<Dynamic>;
		
	private var _sounds : List<SoundClip>;
	private var _eventSounds : IntMap<SoundClip>;
	private var _streamSounds : IntMap<SoundClip>;
	private var _asSounds : StringMap<SoundClip>;
	private var _decodeIterator : Iterator<SoundClip>;
	
	private var _soundLog : Array<SoundLogEntry>;
	private var _activeStreams : IntMap<SoundLogEntry>;
	
	private var _soundInstances : List<SoundInstance>;
	private var _asSoundInstances : List<ActionScriptSoundInstance>;
	private var _as2Transforms : IntMap<SoundTransform>;
	private var _globalTransform : SoundTransform;
	public function new() {
		_sounds = new List();
		
		_eventSounds = new IntMap();
		_streamSounds = new IntMap();
		_asSounds = new StringMap();
		
		_soundLog = new Array();
		_activeStreams = new IntMap();
		
		_soundInstances = new List();
		_asSoundInstances = new List();
		_as2Transforms = new IntMap();
		_globalTransform = {
			volume:			1.0,
			leftToLeft:		1.0,
			leftToRight:	0.0,
			rightToLeft:	0.0,
			rightToRight:	1.0,
		};
		
		onSoundsDecoded = new Dispatcher();
		onMixingComplete = new Dispatcher();
		
		_sample = {left: 0, right: 0};
	}
	
	public function listen(connection : ISwivelConnection) : Void {
		connection.client = {
			startSound:		startSoundHandler,
			streamSound:	streamSoundHandler,
			asStart:		asStartHandler,
			asStop:			asStopHandler,
			asSetVolume:	asSetVolumeHandler,
			asSetPan:		asSetPanHandler,
			asSetTransform:	asSetTransformHandler,
		};
	}
	
	public function registerSound(clip : SoundClip) : Void {
		_sounds.push(clip);
		switch(clip.id) {
			case SoundClipId.event(id):				_eventSounds.set(id, clip);
			case SoundClipId.stream(id):			_streamSounds.set(id, clip);
			case SoundClipId.actionScript(name):	_asSounds.set(name, clip);
		}
	}

	public function decodeSounds() {
		_decodeIterator = _sounds.iterator();
		decodeNextSound();
	}
	
	function decodeNextSound() {
		if (_decodeIterator.hasNext()) {
			var clip = _decodeIterator.next();
			var decoder = new Decoder(clip);
			switch(clip.id) {
				//case SoundClipId.actionScript(_):
//						decodeNextSound();
				default:
				decoder.onComplete.add( function(e) decodeNextSound() );
				decoder.start();
			}
		} else {
			_decodeIterator = null;
			onSoundsDecoded.dispatch();
		}
	}

	private function startSoundHandler(frame : Int, soundId : Int, sync : Int, ?startPos : Int32, ?endPos: Int32, ?numLoops : Int, ?envelopeData : Array<Dynamic>) : Void {
		Logger.log("AudioTrackLog", '$frame: StartSound id: $soundId\n');
		var envelope = null;
		if (envelopeData != null && envelopeData.length > 0) {
			envelope = [];
			var i = 0;
			while (i < envelopeData.length) {
				envelope.push( {
					pos: envelopeData[i],
					leftVolume: envelopeData[i + 1],
					rightVolume: envelopeData[i+2]
				} );
				i += 3;
			}
		}

		_soundLog.push( {
			soundId:	event(soundId),
			frame:		frame,
			type:		event({
				stop:		sync == 2,
				noMultiple:	sync == 1,
				envelope:	envelope,
				numLoops:	numLoops,
				startPos:	startPos,
				endPos:		endPos,
			}),
		} );
	}

	private function streamSoundHandler(movieFrame : Int, streamId : Int, streamFrame : Int) : Void {
		Logger.log("AudioTrackLog", '$movieFrame: StreamSound id: $streamId streamFrame: $streamFrame\n');
		var streamLog = _activeStreams.get(streamId);
		if (streamLog != null) {
			switch(streamLog.type) {
				case stream(frames):
					if (frames.endFrame == streamFrame - 1 && streamLog.frame + (frames.endFrame - frames.startFrame) == movieFrame - 1)
						frames.endFrame = streamFrame;
					else
						streamLog = null;
						
				default: throw("Event sound in activeStreams");
			}
		}

		if (streamLog == null) {
			streamLog = {
				soundId:	stream(streamId),
				frame:		movieFrame,
				type:		stream({startFrame: streamFrame, endFrame: streamFrame})
			}
			_activeStreams.set(streamId, streamLog);
			_soundLog.push(streamLog);
		}
	}
	
	private function asStartHandler(movieFrame : Int, instanceNum : Int, soundName : String, offsetSeconds : Null<Float>, loops : Null<Int>) {
		var soundId = SoundClipId.actionScript(soundName);
		var sound = getSound(soundId);
		_soundLog.push( {
			soundId:	soundId,
			frame:		movieFrame,
			type:		asStart(instanceNum, if(offsetSeconds != null) Std.int(offsetSeconds*SAMPLE_RATE) else null, if(loops != null) loops else 1),
		} );
	}
	
	private function asStopHandler(movieFrame : Int, instanceNum : Int) {
		_soundLog.push( {
			soundId:	null,
			frame:		movieFrame,
			type:		asStop(instanceNum),
		} );
	}
	
	private function asSetVolumeHandler(movieFrame : Int, instanceNum : Int, volume : Float) {
		_soundLog.push( {
			soundId:	null,
			frame:		movieFrame,
			type:		asSetVolume(instanceNum, volume),
		} );
	}
	
	private function asSetPanHandler(movieFrame : Int, instanceNum : Int, pan : Float) {
		_soundLog.push( {
			soundId:	null,
			frame:		movieFrame,
			type:		asSetPan(instanceNum, pan),
		} );
	}
	
	private function asSetTransformHandler(movieFrame : Int, instanceNum : Int, ll : Float, lr : Float, rr : Float, rl : Float) {
		_soundLog.push( {
			soundId:	null,
			frame:		movieFrame,
			type:		asSetTransform(instanceNum, ll, lr, rl, rr),
		} );
	}
	
	public function getSound(id : SoundClipId) : SoundClip {
		if(id == null) return null;
		
		return switch(id) {
			case SoundClipId.event(soundId):		_eventSounds.get(soundId);
			case SoundClipId.stream(clipId):		_streamSounds.get(clipId);
			case SoundClipId.actionScript(name):	_asSounds.get(name);
		}
	}
	
	private static inline var TIME_SLICE : Float = 0.25;
	public var sample : Int;
	private var _audioOutput : FileStream;
	private var frameRate : Float;
	private var startFrame : Int;
	public  var numFrames : Int;
	public var numSamples : Int;
	
	private var _sample : SoundSample;
	
	private static inline var BYTES_PER_SAMPLE = 4;
	private static inline var SAMPLE_RATE = 44100;
	
	public function mixTrack(output : FileStream, frameRate : Float, startFrame : Int, numFrames : Int) {
		sample = 0;
		this.startFrame = startFrame;
		this.numFrames = numFrames;
		this.frameRate = frameRate;
		numSamples = Std.int(numFrames * SAMPLE_RATE / frameRate);
		_audioOutput = output;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, mixTrackWork);
	}
	
	private function mixTrackWork(_) {
		var samplesPerFrame : Int = Std.int(frameRate * BYTES_PER_SAMPLE);
		var length : Int32;// = 1;// Int32.ofInt(numFrames).mul(samplesPerFrame);
		
		var startTime = haxe.Timer.stamp();
		while(sample < numSamples && haxe.Timer.stamp() - startTime < TIME_SLICE) {
			var frame = sample * frameRate / SAMPLE_RATE + startFrame;

			// check if any new sound logs occurred this frame
			while (_soundLog.length > 0 && _soundLog[0].frame <= frame) {
				var e = _soundLog.shift();
				var soundClip : SoundClip = getSound(e.soundId);
				
				switch(e.type) {
					case event(info):
						if (soundClip == null) continue;
						
						// Sync: "event"
						var play = true;
						
						if ( info.stop ) {
							// Sync: "stop"
							// Stop any active instances of this sound.
							for(sound in _soundInstances) {
								if (Type.enumEq(sound.id, e.soundId))
									_soundInstances.remove(sound);
							}
							play = false;
						} else if ( info.noMultiple ) {
							// Sync: "start"
							// Only play if there are no instances of this sound already playing.
							var found = false;
							for (sound in _soundInstances) {
								if (Type.enumEq(sound.id, e.soundId)) {
									found = true;
									break;
								}
							}
							play = !found;
						}

						if (play) {
							_soundInstances.add( new EventSoundInstance(soundClip, info) );
						}
						
					case stream(frames):
						if(soundClip == null) continue;
						_soundInstances.add( new SoundInstance(soundClip, Std.int(frames.startFrame * SAMPLE_RATE / frameRate), Std.int(frames.endFrame * SAMPLE_RATE / frameRate), 0) );
						
					case asStart(i, secs, loops):
						if(soundClip == null) continue;
						var soundInst = new ActionScriptSoundInstance(soundClip, i, secs * SAMPLE_RATE, loops);
						var transform = _as2Transforms.get(i);
						if(transform == null) {
							transform = {volume: _globalTransform.volume, leftToLeft: _globalTransform.leftToLeft, leftToRight: _globalTransform.leftToRight, rightToLeft: _globalTransform.rightToLeft, rightToRight: _globalTransform.rightToRight};
							_as2Transforms.set(i, transform);
						}
						soundInst.volume = transform.volume;
						soundInst.leftToLeft = transform.leftToLeft;
						soundInst.leftToRight = transform.leftToRight;
						soundInst.rightToRight = transform.rightToRight;
						soundInst.rightToLeft = transform.rightToLeft;
						_asSoundInstances.add(soundInst);
					
					case asStop(i):
						for (sound in _asSoundInstances)
							if(sound.instance == i) _asSoundInstances.remove(sound);
							
					case asSetVolume(i, v):
						var transform;
						if(i==-1) {
							transform = _globalTransform;
							_as2Transforms = new IntMap();
						} else {
							transform = _as2Transforms.get(i);
							if(transform == null) {
								transform = {volume: _globalTransform.volume, leftToLeft: _globalTransform.leftToLeft, leftToRight: _globalTransform.leftToRight, rightToLeft: _globalTransform.rightToLeft, rightToRight: _globalTransform.rightToRight};
								_as2Transforms.set(i, transform);
							}
						}
						
						transform.volume = v;
						for (sound in _asSoundInstances)
							if(i == -1 || sound.instance == i) sound.volume = v;
							
					case asSetPan(i, p):
						var transform;
						if(i==-1) {
							transform = _globalTransform;
							_as2Transforms = new IntMap();
						} else {
							transform = _as2Transforms.get(i);
							if(transform == null) {
								transform = {volume: _globalTransform.volume, leftToLeft: _globalTransform.leftToLeft, leftToRight: _globalTransform.leftToRight, rightToLeft: _globalTransform.rightToLeft, rightToRight: _globalTransform.rightToRight};
								_as2Transforms.set(i, transform);
							}
						}
						transform.leftToRight = 0;
						transform.rightToLeft = 0;
						transform.leftToLeft = 1.0 - p;
						transform.rightToRight = 1.0 + p;
						if(transform.leftToLeft > 1.0) transform.leftToLeft = 1.0;
						if(transform.rightToRight > 1.0) transform.rightToRight = 1.0;
						for (sound in _asSoundInstances)
							if(i==-1 || sound.instance == i) {
								sound.leftToRight = 0;
								sound.rightToLeft = 0;
								sound.leftToLeft = transform.leftToLeft;
								sound.rightToRight = transform.rightToRight;
							};
							
					case asSetTransform(i, ll, lr, rr, rl):
						var transform;
						if(i==-1) {
							transform = _globalTransform;
							_as2Transforms = new IntMap();
						} else {
							transform = _as2Transforms.get(i);
							if(transform == null) {
								transform = {volume: _globalTransform.volume, leftToLeft: _globalTransform.leftToLeft, leftToRight: _globalTransform.leftToRight, rightToLeft: _globalTransform.rightToLeft, rightToRight: _globalTransform.rightToRight};
								_as2Transforms.set(i, transform);
							}
						}
						transform.leftToRight = rl;
						transform.rightToRight = rr;
						transform.leftToLeft = ll;
						transform.rightToLeft = lr;
						for (sound in _asSoundInstances)
							if(i==-1 || sound.instance == i) {
								sound.leftToLeft = ll;
								sound.rightToLeft = lr;
								sound.leftToRight = rl;
								sound.rightToRight = rr;
							}
				}
			}
			
			// mix all active sounds together
			_sample.left = 0;
			_sample.right = 0;
			for (sound in _soundInstances) {
				if( sound.step(_sample) ) {
					_soundInstances.remove(sound);
				}
			}
			for (sound in _asSoundInstances) {
				if( sound.step(_sample) ) {
					_soundInstances.remove(sound);
				}
			}
			
			// clamp result
			if (_sample.left > 32767) _sample.left = 32767;
			if (_sample.left < -32768) _sample.left = -32768;
			if (_sample.right > 32767) _sample.right = 32767;
			if (_sample.right < -32768) _sample.right = -32768;
			
			// output
			_audioOutput.writeShort(Std.int(_sample.left));
			_audioOutput.writeShort(Std.int(_sample.right));
			
			sample++;
		}
		
		if(sample >= numSamples) {
			stop();
			onMixingComplete.dispatch();
		}
	}
	
	public function stop() {
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, mixTrackWork);
	}
}

// TODO: this nomenclature is getting confusing...
enum SoundLogType {
	event(info : StartSoundInfo);
	stream(frames : {startFrame : Int, endFrame : Int});
	asStart(instance : Int, offsetSeconds : Null<Int>, loops : Int);
	asSetVolume(instance : Int, volume : Float);
	asSetPan(instance : Int, pan : Float);
	asSetTransform(instance : Int, ll : Float, lr : Float, rl : Float, rr : Float);
	asStop(instance : Int);
}

typedef SoundLogEntry = {
	var frame : Int;
	var soundId : SoundClipId;
	var type : SoundLogType;
}

typedef SoundTransform = {
	var volume : Float;
	var leftToLeft : Float;
	var leftToRight : Float;
	var rightToLeft : Float;
	var rightToRight : Float;
}