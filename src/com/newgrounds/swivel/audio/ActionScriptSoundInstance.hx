package com.newgrounds.swivel.audio;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

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