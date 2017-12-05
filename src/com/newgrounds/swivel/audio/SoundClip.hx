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
import haxe.io.Bytes;
import format.swf.Data;

typedef SoundClip = {
	var id : SoundClipId;
	var format : SoundFormat;
	var isStereo : Bool;
	var is16bit : Bool;
	var sampleRate : SoundRate;
	var latencySeek : Int;
	var numSamples : Null<Int>;
	var data : Array<Bytes>;
};

enum SoundClipId {
	event(soundId : Int);
	stream(clipId : Int);
	actionScript(soundName : String);
}