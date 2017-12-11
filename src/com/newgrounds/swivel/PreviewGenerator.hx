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
import com.huey.events.Dispatcher;
import com.newgrounds.swivel.swf.SWFRecorder;
import com.newgrounds.swivel.swf.SwfUtils;
import com.newgrounds.swivel.swf.SwivelSwf;
import format.abc.Context;

using com.newgrounds.swivel.swf.AbcUtils;

class PreviewGenerator {

	public var onPreviewReady(default, null) : Dispatcher<flash.display.BitmapData>;

	public function new() {
		onPreviewReady = new Dispatcher();
		
		_recorder = new SWFRecorder();
		_recorder.outputWidth = 133;
		_recorder.outputHeight = 75;
		_recorder.renderQuality = High;
		_recorder.scaleMode = letterbox;
		_recorder.onFrameCaptured.add( frameCapturedHandler );
	}
	
	public function getPreview(swf : SwivelSwf, frame : Int) {
		stop();
		
		var previewSwf = swf.clone();
		previewSwf.compression = SCUncompressed;
		swf.prepend(SwfUtils.getAs2Tag("AS2Basics", {width: swf.width, height: swf.height, frameRate: swf.frameRate}));
		if(swf.version < 5) swf.version = 5;
		previewSwf.avmVersion = AVM1;	// TODO: allow AS3 support
		switch(previewSwf.avmVersion) {
			case AVM1:
				previewSwf.prepend( TDoActions( SwivelSwf.getAvm1Bytes( [
					APush( [PString("__swivelInit")] ),
					AEval,
					ACondJump(5),
					AGotoFrame(frame+1),
					AStop,
					AStopSounds,
					APush( [PString("__swivelInit"), PInt(1)] ),
					ASet,
				] ) ) );
				previewSwf.prepend( TShowFrame );
				previewSwf.prepend( TShowFrame );
			
			case AVM2:
				var context = new Context();
				var cl = context.beginClass("__SwivelPreview");
				cl.isSealed = false;
				cl.superclass = context.type("flash.display.MovieClip");
				var f = context.beginConstructor([]);
				f.maxStack = f.maxScope = 4;
				context.ops([
					OThis,
					OConstructSuper(0),
					OThis,
					OInt(frame),
					OCallPropVoid( context.type("gotoAndPlay"), 1),
					ORetVoid,
				]);
				context.finalize();
				
				var o = new haxe.io.BytesOutput();
				new format.abc.Writer(o).write(context.getData());
				
				previewSwf.prepend(TActionScript3(o.getBytes(), null));
				previewSwf.prepend(TSymbolClass([{className: "__SwivelPreview", cid: 0}] ));
		}

		flash.media.SoundMixer.soundTransform = new flash.media.SoundTransform(0);
		
		_recorder.startPlayback(previewSwf);
		_recorder.startRecording();
	}
	
	public function stop() {
		_recorder.stop();
	}

	private var _recorder : SWFRecorder;
	
	private function frameCapturedHandler(frame : flash.display.BitmapData) {
		onPreviewReady.dispatch(frame);
		flash.media.SoundMixer.soundTransform = new flash.media.SoundTransform(1.0);
		stop();
	}
	
}