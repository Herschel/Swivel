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
import format.swf.Data.SoundEnvelopePoint;
import format.swf.Data.StartSoundInfo;
import haxe.Int32;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class EventSoundInstance extends SoundInstance {
	private static inline var MAX_VOLUME : Int = 32768;
		
	public function new(sound : SoundClip, info : StartSoundInfo) {
		super(
			sound,
			if (info.startPos != null) info.startPos else null,
			if (info.endPos != null) info.endPos else null,
			if (info.numLoops != null) info.numLoops else 1
		);
		_envelope = if(info.envelope != null) info.envelope else new Array();
	}
	
	override private function applyTransforms(sample : SoundSample) {
		if(_envelopeIndex < _envelope.length) {
			_volumeLeft += _dVolumeLeft;
			_volumeRight += _dVolumeRight;
		
			var point : SoundEnvelopePoint = _envelope[_envelopeIndex];
			if(_sampleCount >= point.pos) {
				_volumeLeft = point.leftVolume / MAX_VOLUME;
				_volumeRight = point.rightVolume / MAX_VOLUME;
				
				_envelopeIndex++;
				if(_envelopeIndex < _envelope.length) {
					point = _envelope[_envelopeIndex];
					var dp : Int = point.pos - _sampleCount;
					_dVolumeLeft = (point.leftVolume / MAX_VOLUME - _volumeLeft) / dp;
					_dVolumeRight = (point.rightVolume / MAX_VOLUME - _volumeRight) / dp;
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
	private var _envelope : Array<SoundEnvelopePoint>;
	private var _envelopeIndex : Int;
}