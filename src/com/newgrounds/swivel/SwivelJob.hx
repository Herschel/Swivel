package com.newgrounds.swivel;
import com.huey.binding.Binding;
import com.newgrounds.swivel.swf.SwivelSwf;
import com.newgrounds.swivel.swf.RenderQuality;
import flash.filesystem.File;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

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
