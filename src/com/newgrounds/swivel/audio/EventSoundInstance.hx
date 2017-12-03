package com.newgrounds.swivel.audio;
import format.swf.Data.EnvelopePoint;
import format.swf.Data.SoundInfo;
import haxe.Int32;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class EventSoundInstance extends SoundInstance {
	private static inline var MAX_VOLUME : Int = 32768;
		
	public function new(sound : SoundClip, info : SoundInfo) {
		super(sound, if(info.inPoint != null) Int32.toNativeInt(info.inPoint) else null, if(info.outPoint != null) Int32.toNativeInt(info.outPoint) else null, info.loops);
		_envelope = if(info.envelope != null) info.envelope else new Array();
	}
	
	override private function applyTransforms(sample : SoundSample) {
		if(_envelopeIndex < _envelope.length) {
			_volumeLeft += _dVolumeLeft;
			_volumeRight += _dVolumeRight;
		
			var point : EnvelopePoint = _envelope[_envelopeIndex];
			if(_sampleCount >= haxe.Int32.toNativeInt(point.position)) {
				_volumeLeft = point.leftLevel / MAX_VOLUME;
				_volumeRight = point.rightLevel / MAX_VOLUME;
				
				_envelopeIndex++;
				if(_envelopeIndex < _envelope.length) {
					point = _envelope[_envelopeIndex];
					var dp : Int = Int32.toNativeInt(point.position) - _sampleCount;
					_dVolumeLeft = (point.leftLevel / MAX_VOLUME - _volumeLeft) / dp;
					_dVolumeRight = (point.rightLevel / MAX_VOLUME - _volumeRight) / dp;
				}
			}
		}
		
		sample.left *= _volumeLeft;
		sample.right *= _volumeRight;
	}
	
	private var _dVolumeLeft : Float	= 0.0;
	private var _dVolumeRight : Float	= 0.0;
	private var _volumeLeft : Float		= 1.0;
	private var _volumeRight : Float	= 1.0;
	private var _envelope : Array<EnvelopePoint>;
	private var _envelopeIndex : Int;
}