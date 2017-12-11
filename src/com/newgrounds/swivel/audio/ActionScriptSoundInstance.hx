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

class ActionScriptSoundInstance extends SoundInstance {
	public function new(sound : SoundClip, instance : Int, inPoint : Int, loops : Int) : Void {
		super(sound, inPoint, null, loops);
		this.instance = instance;
	}
	
	public var instance(default, null) : Int;
	
	public var volume : Float			= 1.0;
	public var leftToLeft : Float		= 1.0;
	public var leftToRight : Float		= 0.0;
	public var rightToLeft : Float		= 0.0;
	public var rightToRight : Float		= 1.0;
	
	override private function applyTransforms(sample : SoundSample) {
		var l : Float = sample.left;
		var r : Float = sample.right;
		sample.left = volume * (leftToLeft * l + rightToLeft * r);
		sample.right = volume * (leftToRight * l + rightToRight * r);
	}
}