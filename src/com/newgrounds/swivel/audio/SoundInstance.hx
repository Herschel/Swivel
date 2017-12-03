package com.newgrounds.swivel.audio;
import com.newgrounds.swivel.audio.AudioTracker;
import format.swf.Data;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Eof;
import com.newgrounds.swivel.audio.SoundClip.SoundClipId;

class SoundInstance {
	private static var _workSample : SoundSample = {left: 0, right: 0};

	public var id(default, null) : SoundClipId;
	
	public function new(sound : SoundClip, inPoint : Null<Int>, outPoint : Null<Int>, loops : Int) {
		_bytes = sound.data[0];
		id = sound.id;
		_input = new BytesInput(_bytes);
		
		_inPosition = if(inPoint != null) inPoint*4 else 0;
		_outPosition = if(outPoint != null) outPoint*4 else _bytes.length;
		_loops = loops;
		
		_dataPosition = _inPosition;
		_sampleCount = 0;
	}
	
	inline public function step(sample : SoundSample) : Bool {
		var done = false;
				
		try {
			_bytes.getData().position = _dataPosition;
			_workSample.left = _input.readInt16();
			_workSample.right = _input.readInt16();
			
			applyTransforms(_workSample);
			
			sample.left += _workSample.left;
			sample.right += _workSample.right;
			
			_dataPosition += 4;
			_sampleCount++;
			
			if(_dataPosition >= _outPosition) {
				_loops--;
				if(_loops > 0) _dataPosition = _inPosition;
				else done = true;
			}
		} catch(e : Eof) {
			done = true;
		}
		
		return done;
	}
	
	private var _bytes : Bytes;
	private var _input : BytesInput;
	private var _dataPosition : Int;
	private var _sampleCount : Int;
	
	private var _inPosition : Int;
	private var _outPosition : Int;
	private var _loops : Int;
	
	private function applyTransforms(sample : SoundSample) {
		
	}
}
