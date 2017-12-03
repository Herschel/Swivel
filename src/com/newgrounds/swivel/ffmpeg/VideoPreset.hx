package com.newgrounds.swivel.ffmpeg;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

typedef VideoPreset = {
	var label : String;
	var fileFormat : String;
	var codec : String;
	var supportsBitRate : Bool;
	var extraParameters : Null<Array<String>>;
	var supportedAudioCodecs : Null<Array<AudioCodec>>;
}