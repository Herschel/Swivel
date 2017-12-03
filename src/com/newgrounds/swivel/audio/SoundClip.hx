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