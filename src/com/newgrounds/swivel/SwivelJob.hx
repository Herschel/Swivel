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

package com.newgrounds.swivel;
import com.huey.binding.Binding;
import com.newgrounds.swivel.swf.SwivelSwf;
import com.newgrounds.swivel.swf.RenderQuality;
import flash.filesystem.File;

class SwivelJob extends Binding.Bindable
{
	@bindable public var swf : SwivelSwf;
	public var file : File;

	@bindable public var duration : RecordingDuration;
	@bindable public var renderQuality : RenderQuality;
	@bindable public var forceBitmapSmoothing : Bool;
	public var parameters : Dynamic;
	
	public function new(file : File, swf : SwivelSwf) {
		super();
		renderQuality = High;
		forceBitmapSmoothing = true;
		this.file = file;
		this.swf = swf;
		duration = frameRange(1,swf.numFrames);
	}
	
	public function toString() : String { return file.nativePath; }
}


enum RecordingDuration {
	frameRange(startFrame : Int, endFrame : Int);
	manual;
}
