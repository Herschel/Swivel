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

package com.newgrounds.swivel.swf;
import com.huey.events.Dispatcher;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.UncaughtErrorEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.LoaderContext;
import flash.system.System;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class SWFRecorder {
	private static inline var DEFAULT_WIDTH : Int	= 1920;
	private static inline var DEFAULT_HEIGHT : Int	= 1080;
	
	private static inline var WATERMARK_MARGIN : Int = 2;
	
	public var outputWidth	: Int;
	public var outputHeight	: Int;
	public var scaleMode 	: ScaleMode;
	
	public var transparentBackground : Bool;
	
	public var renderQuality : RenderQuality;
	
	public var watermark : Null<Watermark>;
	public var showWindow : Bool = false;
	
	public var currentFrame(default, null) : Int;
	
	public var onFrameCaptured : Dispatcher<BitmapData>;
	
	public var recording(default, null) : Bool;
	
	public function new() {
		outputWidth = DEFAULT_WIDTH;
		outputHeight = DEFAULT_HEIGHT;
		scaleMode = crop;
		renderQuality = High;
		
		recording = false;
		
		transparentBackground = false;
		
		onFrameCaptured = new Dispatcher();
		
		_maxFrameRate = switch( flash.system.Capabilities.os.split(" ")[0] ) {
			case "Windows":	1000;
			default:		30;
		}
	}
	
	private var _swf			: SwivelSwf;
	private var _window			: NativeWindow;
	private var _loader			: Loader;
	private var _mask			: Bitmap;
	
	private var _drawMatrix 	: Matrix;
	private var _watermarkMatrix: Matrix;
	private var _watermarkColorTransform : ColorTransform;
	private var _letterBoxRect0	: Rectangle;
	private var _letterBoxRect1	: Rectangle;
	
	private var _frame			: BitmapData;
	
	// TODO:
	private var _maxFrameRate	: Int;
	
	private function createWindow() {
		var opts = new NativeWindowInitOptions();
		opts.maximizable = false;
		opts.resizable = false;
		_window = new NativeWindow(opts);
		_window.addEventListener(flash.events.Event.CLOSING, function(e) e.preventDefault());
		_window.stage.align = StageAlign.TOP_LEFT;
		_window.stage.scaleMode = StageScaleMode.NO_SCALE;
		_window.title = "Swivel Interactive Window";
	}
	
	public function startPlayback(swf : SwivelSwf, ?parameters : Dynamic) : Void {
		currentFrame = 0;
				
		createWindow();
		_swf = swf;
		_window.width = _swf.width;
		_window.height = _swf.height;
		_window.stage.stageWidth = _swf.width;
		_window.stage.stageHeight = _swf.height;
		_window.stage.frameRate = if(showWindow) _swf.frameRate else _maxFrameRate;

		_frame = new BitmapData(outputWidth, outputHeight, transparentBackground);
		
		var scaleX = outputWidth / _swf.width;
		var scaleY = outputHeight / _swf.height;
		
		// create scaling matrix and letterboxes for drawing SWF
		_drawMatrix = new Matrix();
		_letterBoxRect0 = _letterBoxRect1 = null;
		switch(scaleMode) {
			case stretchToFit:
				_drawMatrix.scale(scaleX, scaleY);
				
			case crop:
				if (scaleX > scaleY) {
					_drawMatrix.scale(scaleX, scaleX);
					_drawMatrix.translate(0, (outputHeight - scaleX * _swf.height) / 2);
				} else if (scaleY > scaleX) {
					_drawMatrix.scale(scaleY, scaleY);
					_drawMatrix.translate((outputWidth - scaleY * _swf.width) / 2, 0);
				} else _drawMatrix.scale(scaleX, scaleY);
				
			case letterbox:
				if (scaleX < scaleY) {
					_drawMatrix.scale(scaleX, scaleX);
					var letterBoxSize = (outputHeight - scaleX * _swf.height) / 2;
					_drawMatrix.translate(0, letterBoxSize);
					_letterBoxRect0 = new Rectangle(0, 0, outputWidth, letterBoxSize);
					_letterBoxRect1 = new Rectangle(0, outputHeight-letterBoxSize, outputWidth, letterBoxSize);
				} else if (scaleY < scaleX) {
					_drawMatrix.scale(scaleY, scaleY);
					var letterBoxSize = (outputWidth - scaleY * _swf.width) / 2;
					_drawMatrix.translate(letterBoxSize, 0);
					if(!transparentBackground) {
						_letterBoxRect0 = new Rectangle(0, 0, letterBoxSize, outputHeight);
						_letterBoxRect1 = new Rectangle(outputWidth-letterBoxSize, 0, letterBoxSize, outputHeight);
					}
				} else _drawMatrix.scale(scaleX, scaleY);
		}
		
		if(watermark != null && watermark.image != null) {
			_watermarkMatrix = new Matrix();
			var watermarkW = watermark.scale * watermark.image.width;
			var watermarkH = watermark.scale * watermark.image.height;
			_watermarkMatrix.translate(-watermark.image.width/2, -watermark.image.height/2);
			_watermarkMatrix.scale(watermark.scale, watermark.scale);
			_watermarkMatrix.translate(watermarkW/2, watermarkH/2);
			switch(watermark.align) {
				case bottomLeft:	_watermarkMatrix.translate(WATERMARK_MARGIN, outputHeight - watermarkH - WATERMARK_MARGIN);
				case bottomCenter:	_watermarkMatrix.translate(outputWidth/2 - watermarkW/2, outputHeight - watermarkH - WATERMARK_MARGIN);
				case bottomRight:	_watermarkMatrix.translate(outputWidth - watermarkW - WATERMARK_MARGIN, outputHeight - watermarkH - WATERMARK_MARGIN);
				case middleLeft:	_watermarkMatrix.translate(WATERMARK_MARGIN, (outputHeight - watermarkH)/2);
				case center:		_watermarkMatrix.translate((outputWidth - watermarkW)/2, (outputHeight - watermarkH)/2);
				case middleRight:	_watermarkMatrix.translate(outputWidth - watermarkW - WATERMARK_MARGIN, (outputHeight - watermarkH)/2);
				case topLeft:		_watermarkMatrix.translate(WATERMARK_MARGIN, WATERMARK_MARGIN);
				case topCenter:		_watermarkMatrix.translate((outputWidth - watermarkW)/2, WATERMARK_MARGIN);
				case topRight:		_watermarkMatrix.translate(outputWidth - watermarkW - WATERMARK_MARGIN, WATERMARK_MARGIN);
			}
			
			_watermarkColorTransform = new ColorTransform(1, 1, 1, watermark.alpha);
		}
				
		var loaderContext : LoaderContext = new LoaderContext();
		loaderContext.allowCodeImport = true;
		if(parameters != null) loaderContext.parameters = parameters;
		
		_loader = new Loader();
		// start recording after Event.INIT (first frame is loaded)
		_loader.contentLoaderInfo.addEventListener(Event.INIT, onSWFLoaded);
		_loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e) {
			trace(e.error);
			e.preventDefault();
		});
		_loader.loadBytes(_swf.getBytes().getData(), loaderContext);
		_window.stage.addChild(_loader);
		
		// Flash would crash from exceptionally large frames/filters
		// Masking the loader to output dimensions seems to fix the problem
		_mask = new Bitmap( new BitmapData(_swf.width, _swf.height, false, 0) );
		_window.stage.addChild(_mask);
		
		_window.x = (_window.stage.fullScreenWidth-_window.width)/2;
		_window.y = 0;
		if(showWindow) _window.activate();
	}
	
	public function startRecording() {
		recording = true;
	}

	public function stop() : Void {
		recording = false;
				
		if (_loader != null) {
			_loader.content.mask = null;
			_loader.contentLoaderInfo.removeEventListener(flash.events.Event.INIT, onSWFLoaded);
			_loader.removeEventListener(flash.events.Event.RENDER, onSWFRender);
			_loader.removeEventListener(flash.events.Event.ENTER_FRAME, onSWFFrame);
			_loader.unloadAndStop(true);
			if (_loader.parent != null) _window.stage.removeChild(_loader);
			_loader = null;
		}
		
		if(_mask != null && _mask.parent != null) _mask.parent.removeChild(_mask);
		_mask = null;
		
		if(_window != null) {
			while(_window.stage.numChildren > 0) _window.stage.removeChildAt(0);
			
			if(showWindow) _window.close();
			_window.stage.frameRate = 30;
			_window = null;
		}

		_frame = null;
	}
	
	private function onSWFLoaded(event : Dynamic) : Void {
		_loader.content.mask = _mask;
		
		_loader.contentLoaderInfo.removeEventListener(flash.events.Event.INIT, onSWFLoaded);
		_loader.addEventListener(flash.events.Event.ENTER_FRAME, onSWFFrame);
		_loader.addEventListener(flash.events.Event.RENDER, onSWFRender);
		
		// The first frame of the movie is already visible, and the events above won't fire
		// until next frame, so manually trigger a render immediately (#2).
		onSWFFrame(null);
	}
	
	function onSWFFrame(_) _window.stage.invalidate();
	
	private function onSWFRender(_) : Void {
		_window.stage.align = StageAlign.TOP_LEFT;
		_window.stage.scaleMode = StageScaleMode.NO_SCALE;

		if(recording) {
			onFrameCaptured.dispatch( drawFrame() );
		}
		currentFrame++;
	}
	
	private function drawFrame() : BitmapData {
		if (_loader == null) throw "F";

		_frame.lock();
		_frame.fillRect(_frame.rect, transparentBackground ? 0x00000000 : _swf.backgroundColor);
		
		// There are some weird bugs in Flash causing artifacts when drawing at high resolutions
		// Readding loader to stage seems to fix it (forces redraw???)
		_window.stage.addChild(_loader);
		
		// TODO: StageQuality.HIGH_8X8/16X16 and better seems to cause artifacts on some content. :(
		// If they fix this in the Flash Player, readd them to settings screen
		var quality = switch(renderQuality) {
			case Low:			StageQuality.LOW;
			case Medium:		StageQuality.MEDIUM;
			case High:			StageQuality.BEST;
			case Higher:		StageQuality.HIGH_8X8_LINEAR;
			case Highest:		StageQuality.HIGH_16X16_LINEAR;
		}
		// this might need to draw loader instead of _window.stage
		_frame.drawWithQuality(_window.stage, _drawMatrix, null, null, null, true, quality);
		
		if (_letterBoxRect0 != null) _frame.fillRect(_letterBoxRect0, 0xff000000);
		if (_letterBoxRect1 != null) _frame.fillRect(_letterBoxRect1, 0xff000000);
		
		// draw watermark
		if(watermark != null && watermark.image != null)
			_frame.draw(watermark.image, _watermarkMatrix, _watermarkColorTransform, null, null, true);
		_frame.unlock();
		return _frame;
	}
}

enum ScaleMode
{
	crop;
	stretchToFit;
	letterbox;
}