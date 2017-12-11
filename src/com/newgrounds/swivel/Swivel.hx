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

import com.newgrounds.swivel.ffmpeg.AudioCodec;
import com.newgrounds.swivel.ffmpeg.VideoPreset;
import com.newgrounds.swivel.swf.Watermark;
import com.newgrounds.swivel.SwivelController.SwivelTask;
import com.newgrounds.swivel.SwivelController.SwivelProgressEvent;
import com.newgrounds.swivel.SwivelJob.RecordingDuration;
import com.huey.assets.Asset;
import com.huey.assets.AssetSource;
import com.huey.core.Application;
import com.huey.binding.Binding;
import com.huey.binding.BindableArray;
import com.huey.utils.Thread;
import com.huey.ui.Component.HitArea;
import com.huey.ui.*;
import com.newgrounds.swivel.SwivelController.AudioSource;
import com.newgrounds.swivel.swf.SwivelSwf;
import com.newgrounds.swivel.swf.RenderQuality;
import com.newgrounds.swivel.swf.SWFRecorder.ScaleMode;
import com.newgrounds.swivel.swf.Watermark.WatermarkAlign;
import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.Lib;
import flash.net.FileFilter;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.TextField;
import format.swf.Reader;
import format.swf.Data;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Input;

@:xml("SwivelHuey.xml") @:version("1.11")
class Swivel extends Application
{
	@bindable private var _controller : SwivelController;
	private var _browseFile : File;
	
	private var _fileListBox : ListBox;
		
	private var _settingsContainer : StateContainer;

	private var _previewImage : ScaledImage;
	public var busySpinner : Component;
	
	public var sourceButton : Button;
	public var videoButton : Button;
	public var audioButton : Button;
	public var overlayButton : Button;
	
	public var outputFileBox : TextBox;

	public var removeButton : Button;
	public var convertButton : Button;
	public var cancelButton : Button;
	
	public var qualitySlider : Slider;

	public var widthStepper : NumericStepper;
	public var heightStepper : NumericStepper;
	
	private var _aspectRatio : Null<Float>	= 16.0 / 9.0;
	public var lockAspectCheckBox : CheckBox;
	
	public var frameStepperImage : Image;
	public var startFrameStepper : NumericStepper;
	public var endFrameStepper : NumericStepper;
	
	private var _previewGenerator : PreviewGenerator;
	
	public var setupGroup : RadioGroup;
	@bindable public var durationGroup : RadioGroup;
	
	public var scaleModeGroup : RadioGroup;
	public var cropButton : RadioButton;
	public var letterboxButton : RadioButton;
	public var exactFitButton : RadioButton;
	public var transparentBgCheckBox : CheckBox;
	public var codecSelectBox : SelectBox;
	public var videoBitrateSlider : Slider;
	
	@bindable public var audioGroup : RadioGroup;
	
	public var frameRangeButton : RadioButton;
	public var manualButton : RadioButton;
	
	public var noAudioButton : RadioButton;
	public var swfAudioButton : RadioButton;
	public var externalAudioButton : RadioButton;
	public var externalAudioFileBox : TextBox;
	public var externalAudioContainer : Component;
	public var externalAudioFile : File;
	public var audioChannelGroup : RadioGroup;
	public var monoRadioButton : RadioButton;
	public var audioCodecSelectBox : SelectBox;
	public var audioBitrateSlider : Slider;

	private var _watermark : Watermark;
	private var _watermarkFile : File;
	public var watermarkEnabledCheckBox : CheckBox;
	public var watermarkFileBox : TextBox;
	public var watermarkAlphaSlider : Slider;
	public var watermarkSizeSlider : Slider;
	public var watermarkSettingsContainer : Component;
	@bindable private var bitmapSmoothingCheckBox : CheckBox;
	
	private var progressText : Label;
	
	private var timeText : Label;
	private var videoNameText : Label;
	private var videoNameButton : Button;
	private var fileSizeText : Label;
	
	private var aboutBox : Container;
	public var versionText : Label;
	public var creditsText : Label;
	
	private var swfSetupContainer : Container;
	private var frameContainer : Container;
	private var mainContainer : StateContainer;
	
	public var progressBar : Slider;
	
	public var alignmentGroup : RadioGroup;

	public var watermarkPreview : Component;
	public var recordingButton : CheckBox;
	public var errorText : Label;
	
	private var cmdLineArguments : Array<String>;
	
	public function new() : Void {
		super();
		
		_controller = new SwivelController();
		_watermarkFile = new File();
		_watermark = {image : null, alpha: 1.0, scale: 1.0, align: bottomLeft};
		
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, function(e : InvokeEvent) {
			if(!_isCmdLine && e.arguments != null && e.arguments.length > 0) {
				_isCmdLine = true;
				cmdLineArguments = e.arguments;
				_cmdLineDirectory = e.currentDirectory;
			}
		});
		
		/*_isCmdLine = true;
		cmdLineArguments = (["dealer-warranty.swf","-s","640x480","-o","cmd.mp4","-ab","64k","-vb","1.5M"]);
		_cmdLineDirectory = new File("d:\\Swiveltest");*/
	}
	
	private var _isCmdLine : Bool;
	private var _cmdLineFile : File;
	private var _cmdLineParams : Dynamic;
	private var _cmdLineDirectory : File;
	
	private function handleCommandLineArguments(args : Array<String>) {
		if(args.length == 0) return;
		
		while(args.length > 0) parseNextArgument(args);
		
		if(_cmdLineFile == null) throw("No input file specified");
		if(!_cmdLineFile.exists) throw('${_cmdLineFile.nativePath} does not exist');
		
		if(_controller.outputFile == null) {
			_controller.outputFile = _cmdLineFile.parent.resolvePath( _cmdLineFile.name.split(".")[0] + ".mp4" );
		}
		
		_cmdLineFile.addEventListener(Event.COMPLETE, function(_) {
			var job = new SwivelJob(_cmdLineFile, new SwivelSwf(Bytes.ofData(_cmdLineFile.data)) );
			job.parameters = _cmdLineParams;
			_controller.jobs.push( job );
			convertClickHandler(null);
		} );
		_cmdLineFile.load();
	}
	
	private function parseNextArgument(args : Array<String>) {
		var arg = StringTools.trim(args.shift());
		if(arg.charAt(0) == "-") {
			var sw = arg.substr(1);
			switch(sw) {
				case "s":
					var parts = args.shift().split("x");
					_controller.outputWidth = Std.parseInt(parts[0]);
					_controller.outputHeight = Std.parseInt(parts[1]);
				
				case "vb":
					var arg = StringTools.trim(args.shift());
					var bitRate : Null<Float> = switch( arg.charAt(arg.length-1).toLowerCase() ) {
						case "k":	1024 * Std.parseFloat( arg.substr(0,arg.length-1) );
						case "m":	1024 * 1024 * Std.parseFloat( arg.substr(0,arg.length-1) );
						default:	Std.parseFloat( arg.substr(0,arg.length-1) );
					}
					
					if(bitRate != null && bitRate > 0) _controller.videoBitRate = Std.int(bitRate);
				
				case "ab":
					var arg = StringTools.trim(args.shift());
					var bitRate : Null<Float> = switch( arg.charAt(arg.length-1).toLowerCase() ) {
						case "k":	1024 * Std.parseFloat( arg.substr(0,arg.length-1) );
						case "m":	1024 * 1024 * Std.parseFloat( arg.substr(0,arg.length-1) );
						default:	Std.parseFloat( arg );
					}
					
					if(bitRate != null && bitRate > 0) _controller.audioBitRate = Std.int(bitRate);
					
				case "sm":
					switch(args.shift()) {
						case "letterbox": _controller.scaleMode = letterbox;
						case "crop": _controller.scaleMode = crop;
						case "stretch": _controller.scaleMode = stretchToFit;
						default: throw("Invalid scale mode");
					}
					
				case "a":
					var arg = StringTools.trim(args.shift());
					switch(arg) {
						case "none":	_controller.audioSource = none;
						case "swf":		_controller.audioSource = swf;
						default:
							var audioFile = _cmdLineDirectory.resolvePath(arg);
							if(!audioFile.exists) throw("Audio file ${audioFile.nativePath} does not exist");
							_controller.audioSource = external( audioFile );
					}
					
				case "t":
					_controller.transparentBackground = true;
					
				case "o":
					_controller.outputFile = _cmdLineDirectory.resolvePath( StringTools.trim(args.shift()) );
					
				default: throw('Invalid switch $sw');
			}
		} else {
			if(_cmdLineFile != null) {
				throw("Only one input file may be specified");
			}
			
			var fileParts = arg.split("?");
			if(fileParts.length > 1) {
				_cmdLineParams = {};
				for(param in StringTools.urlDecode(fileParts[1]).split("&")) {
					var paramParts = param.split("=");
					Reflect.setField(_cmdLineParams, paramParts[0], paramParts[1]);
				}
			}
			
			_cmdLineFile = _cmdLineDirectory.resolvePath(fileParts[0]);
		}
	}

	private override function init() : Void {
		#if !debug
			if(!_isCmdLine) ui.add(new SplashScreen());
		#end

		_previewGenerator = new PreviewGenerator();
		_previewGenerator.onPreviewReady.add(previewReadyHandler);
				
		// SOURCE
		Binding.bind( removeButton.enabled, _controller.jobs.length > 0 );
		Binding.bind( convertButton.enabled, _controller.jobs.length > 0 && _controller.outputFile != null);
		Binding.bind( swfSetupContainer.enabled, _fileListBox.selectedItem != null );
		Binding.bind( _fileListBox.items, _controller.jobs.array );
		Binding.bind( qualitySlider.value, _fileListBox.selectedItem.renderQuality.getIndex());
		untyped qualitySlider._implComponent.addEventListener(MouseEvent.MOUSE_DOWN, qualitySecretHandler );
		Binding.bind( _fileListBox.selectedItem.renderQuality, Type.createEnumIndex(RenderQuality, Std.int(qualitySlider.value)) );
		Binding.bind( outputFileBox.text, _controller.outputFile.nativePath );
		outputFileBox.onUserEdited.add(outputFileEditHandler);
		
		Binding.bind( frameContainer.enabled, !swfSetupContainer.enabled || durationGroup.selectedItem == frameRangeButton  );
		
		Binding.bindTwoWay( bitmapSmoothingCheckBox.selected, _fileListBox.selectedItem.forceBitmapSmoothing );
		_fileListBox.onChange.add(fileChangedHandler);
		Binding.bind( startFrameStepper.maximum, _fileListBox.selectedItem.swf.numFrames );
		Binding.bind( endFrameStepper.maximum, _fileListBox.selectedItem.swf.numFrames );
		startFrameStepper.onUserChange.add(showPreview);
		endFrameStepper.onUserChange.add(showPreview);
		startFrameStepper.onChange.add(function(_) changeDuration(false));
		endFrameStepper.onChange.add(function(_) changeDuration(true));
		durationGroup.onChange.add(function(_) changeDuration(false));
		
		codecSelectBox.items = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.PRESETS;
		codecSelectBox.selectedIndex = 0;
		codecSelectBox.onChange.add(codecChangeHandler);
		
		// VIDEO
		Binding.bind( widthStepper.value, _controller.outputWidth );
		Binding.bind( heightStepper.value, _controller.outputHeight );
		Binding.bind( widthStepper.step, if(lockAspectCheckBox.selected) Std.int(Math.max(Math.round(widthStepper.value/heightStepper.value)*2,2)) else 2 );
		Binding.bind( heightStepper.step, if(lockAspectCheckBox.selected) Std.int(Math.max(Math.round(heightStepper.value/widthStepper.value)*2,2)) else 2 );
		widthStepper.onUserChange.add(function(_) updateOutputSize(Std.int(widthStepper.value), null));
		heightStepper.onUserChange.add(function(_) updateOutputSize(null, Std.int(heightStepper.value)));
		lockAspectCheckBox.onClick.add(function(_) {
			_aspectRatio = if(lockAspectCheckBox.selected) widthStepper.value / heightStepper.value else null;
			updateOutputSize(null, null);
		});
		
		Binding.bind( _controller.scaleMode, {
			if(lockAspectCheckBox.selected || scaleModeGroup.selectedItem == cropButton) crop;
			else if(scaleModeGroup.selectedItem == letterboxButton) letterbox;
			else stretchToFit;
		} );
		
		Binding.bindTwoWay( _controller.transparentBackground, transparentBgCheckBox.selected );
		transparentBgCheckBox.onClick.add( function(_) {
			if(transparentBgCheckBox.selected) {
				codecSelectBox.items = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.TRANSPARENT_PRESETS;
				codecSelectBox.selectedIndex = 0;
			} else {
				codecSelectBox.items = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.PRESETS;
				codecSelectBox.selectedIndex = 1;
			}
		} );
		
		// AUDIO
		Binding.bind( _controller.audioSource, {
			if(audioGroup.selectedItem == noAudioButton) none;
			else if(audioGroup.selectedItem == swfAudioButton) swf;
			else external(externalAudioFile);
		} );
		Binding.bind( externalAudioContainer.enabled, externalAudioButton.selected );
		audioCodecSelectBox.items = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.AUDIO_CODECS;
		audioCodecSelectBox.selectedIndex = 0;
		audioCodecSelectBox.onChange.add(audioCodecChangeHandler);
		Binding.bind( _controller.stereoAudio, {!monoRadioButton.selected;} );
		
		codecChangeHandler(null);

		// WATERMARK
		watermarkFileBox.onUserEdited.add(watermarkFileEditHandler);
		Binding.bind( _controller.watermark, if(watermarkEnabledCheckBox.selected) _watermark else null );
		Binding.bind( _watermark.alpha, {drawWatermarkPreview(); watermarkAlphaSlider.value;} );
		Binding.bind( _watermark.scale, {drawWatermarkPreview(); watermarkSizeSlider.value;} );
		Binding.bind( watermarkSettingsContainer.enabled, watermarkEnabledCheckBox.selected );
		Binding.bind( _watermark.align, {
			drawWatermarkPreview();
			if(alignmentGroup.selectedItem.y == 299) {
				if(alignmentGroup.selectedItem.x == 438)		topLeft;
				else if(alignmentGroup.selectedItem.x == 468)	topCenter;
				else											topRight;
			} else if(alignmentGroup.selectedItem.y == 321) {
				if(alignmentGroup.selectedItem.x == 438)		middleLeft;
				else if(alignmentGroup.selectedItem.x == 468)	center;
				else 											middleRight;
			} else {
				if(alignmentGroup.selectedItem.x == 438)		bottomLeft;
				else if(alignmentGroup.selectedItem.x == 468)	bottomCenter;
				else											bottomRight;
			}
		} );
		
		versionText.text = 'v$VERSION - $BUILD_TIME';
		
		if(!flash.system.Capabilities.isDebugger) {
			mainContainer.state = "error";
			errorText.text = 'Please restart your computer before using Swivel for the first time.\n\nIf this error persists, please e-mail mike@newgrounds.com.';
		} else if(_isCmdLine) handleCommandLineArguments(cmdLineArguments);
	}
	

	private function dragWindowHandler(e) NativeApplication.nativeApplication.activeWindow.startMove();
	private function closeClickHandler(e) if(aboutBox.visible) aboutCloseHandler(null) else exit();
	private function minClickHandler(e) minimize();
	private function aboutClickHandler(_) {
		aboutBox.visible = true;
		untyped creditsText._implComponent.scrollRect = new flash.geom.Rectangle(0, -230, 300, 225);
		flash.Lib.current.stage.frameRate = 25;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, aboutFrameHandler);
	}
	private function aboutFrameHandler(_) {
		untyped creditsText._implComponent.scrollRect = new flash.geom.Rectangle(0, creditsText._implComponent.scrollRect.y+1, 300, 225);
	}
	
	private function helpClickHandler(_) flash.Lib.getURL(new flash.net.URLRequest("http://www.newgrounds.com/swivel"));
	private function ngUpsellClickHandler(_) flash.Lib.getURL(new flash.net.URLRequest("http://www.newgrounds.com/projects/movies/submit"));
	
	private function addClickHandler(e) : Void {
		// TODO: create File class
		_browseFile = new File();
		_browseFile.addEventListener(flash.events.Event.SELECT, fileSelectHandler);
		_browseFile.browseForOpen("Import SWF", [new FileFilter("SWF Files (*.swf)", "*.swf")]);
	}

	private function removeClickHandler(e) : Void {
		_controller.jobs.splice(_fileListBox.selectedIndex, 1);
	}

	private function spinBusyIcon() untyped busySpinner._implComponent.rotation -= 40;
	private function fileSelectHandler(e) {
		busySpinner.visible = true;
		flash.Lib.current.mouseChildren = flash.Lib.current.tabEnabled = false;
		var spinTimer = new haxe.Timer(33);
		spinTimer.run = spinBusyIcon;
		
		_browseFile.addEventListener(flash.events.Event.COMPLETE, function(e) {
			try {
				var swf = new SwivelSwf(Bytes.ofData(_browseFile.data));
				var job = new SwivelJob( _browseFile, swf );
				_controller.jobs.push(job);
				if(_controller.jobs.length == 1) {
					_controller.outputFile = _browseFile.parent.resolvePath( _browseFile.name.split(".")[0] + ".mp4" );
					
					_fileListBox.selectedIndex = 0;
					
					var swfAspectRatio = swf.width / swf.height;
					if(_aspectRatio != null) _aspectRatio = swfAspectRatio;
					
					var w : Float = 1920.0;
					var h : Float = 1080.0;
					if(swfAspectRatio > w/h)
						h = swf.height * (w/swf.width);
					else
						w = swf.width * (h/swf.height);
						
					updateOutputSize(Std.int(w), Std.int(h));
				}
			} catch(error : Dynamic) {}
			busySpinner.visible = false;
			flash.Lib.current.mouseChildren = flash.Lib.current.tabEnabled = true;
			spinTimer.stop();
			spinTimer = null;
		});
		_browseFile.load();
	}
	
	private function fileChangedHandler(_) {
		var job : SwivelJob = _fileListBox.selectedItem;
		if(job != null) {
			switch(job.duration) {
				case frameRange(s,e):
					startFrameStepper.value = s;
					endFrameStepper.value = e;
					manualButton.selected = false;
					frameRangeButton.selected = true;
					durationGroup.selectedItem = frameRangeButton;
				case manual:
					startFrameStepper.value = 1;
					endFrameStepper.value = _fileListBox.selectedItem.swf.numFrames;
					manualButton.selected = true;
					frameRangeButton.selected = false;
					durationGroup.selectedItem = manualButton;
			}
		}
		showPreview();
	}
	
	private function changeDuration(isEndFrame : Bool) : Void {
		if(startFrameStepper.value > endFrameStepper.value)
			if(isEndFrame) startFrameStepper.value = endFrameStepper.value;
			else endFrameStepper.value = startFrameStepper.value;
			
		_fileListBox.selectedItem.duration =
			if(durationGroup.selectedItem == frameRangeButton)
				frameRange(Std.int(startFrameStepper.value), Std.int(endFrameStepper.value));
		else
			manual;
	}
	
	private function showPreview(?e : UIEvent) {
		if(_fileListBox.selectedItem != null) {
			var swf : SwivelSwf = _fileListBox.selectedItem.swf;
			if(swf != null) {
				var frame = if(e != null) untyped(e.source).value else Std.int(startFrameStepper.value);
				_previewGenerator.getPreview(swf, frame);
			}
		}
	}

	private function previewReadyHandler(frame) {
		frameStepperImage.visible = true;
		untyped frameStepperImage._implComponent.smoothing = true;
		untyped frameStepperImage._implComponent.bitmapData = frame;
		untyped frameStepperImage._implImage = frame;
	}
	
	private function convertClickHandler(e) : Void {
		mainContainer.state = "converting";

		if(e != null) {
			var videoCodec : VideoPreset = codecSelectBox.selectedItem;
			if(videoCodec.supportsBitRate && videoBitrateSlider.value != videoBitrateSlider.maximum) {
				_controller.videoBitRate = Std.int(videoBitrateSlider.value);
			} else {
				_controller.videoBitRate = null;
			}
			
			var audioCodec : AudioCodec = audioCodecSelectBox.selectedItem;
			_controller.audioBitRate = if(audioCodec.supportsBitRate) Std.int(audioBitrateSlider.value) else null;
		}
		
		_recording = false;
		recordingButton.selected = false;
		recordingButton.visible = false;
		
		_controller.onProgress.add(convertProgressHandler);
		_controller.onComplete.add(convertCompleteHandler);
		_controller.start();
		
		cancelButton.visible = false;
		haxe.Timer.delay( function() cancelButton.visible = true, 2000);
	}
		
	// VIDEO tab
	private function outputBrowseClickHandler(e) : Void {
		var outputFile = new File();
		outputFile.addEventListener(flash.events.Event.SELECT, function(_) _controller.outputFile = outputFile );
		outputFile.browseForSave("Set Output Video File");
	}
	
	private function outputFileEditHandler(_) {
		try _controller.outputFile = new File(outputFileBox.text)
		catch(error:Dynamic) _controller.outputFile = null;
	}
	
	private function updateOutputSize(w : Null<Int>, h : Null<Int>) : Void {
		var _w : Float = if(w != null) w else _controller.outputWidth;
		var _h : Float = if(h != null) h else _controller.outputHeight;
		
		if(_aspectRatio != null) {
			if(w == null) _w = _h * _aspectRatio;
			else if(h == null) _h = _w / _aspectRatio;
		}
				
		var forceEven = true;
		if(forceEven) {
			_w = Std.int(_w/2)*2;
			_h = Std.int(_h/2)*2;
		}
				
		if(_w < 2) _w = 2;
		if(_h < 2) _h = 2;
		
		_controller.outputWidth = Std.int(_w);
		_controller.outputHeight = Std.int(_h);
	}
	
	private function codecChangeHandler(_) {
		var preset : VideoPreset = codecSelectBox.selectedItem;
		
		if(_controller.outputFile != null) {
			var nameParts = _controller.outputFile.name.split(".");
			nameParts.pop();
			nameParts.push( preset.fileFormat );
			_controller.outputFile = _controller.outputFile.parent.resolvePath( nameParts.join(".") );
		}
		
		_controller.videoPreset = preset;
		
		if(preset.supportsBitRate) {
			videoBitrateSlider.enabled = true;
		} else {
			videoBitrateSlider.enabled = false;
			videoBitrateSlider.value = videoBitrateSlider.maximum;
		}
		
		audioCodecSelectBox.items = if(preset.supportedAudioCodecs != null) preset.supportedAudioCodecs else com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.AUDIO_CODECS;
		audioCodecSelectBox.selectedIndex = 0;
	}
	
	private function videoBitrateLabelFunc(v : Float) {
		if(codecSelectBox != null && codecSelectBox.selectedItem != null && v == videoBitrateSlider.maximum) return "Lossless";
		if(v < 1024*1024) return Math.round(v/1024*10)/10 + " kbps";
		else return Math.round(v/1024/1024*10)/10 + " Mbps";
	}
	
	private function audioBitrateLabelFunc(v : Float) {
		if(v < 1024*1024) return Math.round(v/1024*10)/10 + " kbps";
		else return Math.round(v/1024/1024*10)/10 + " Mbps";
	}
	
	// === AUDIO ===
	private function audioBrowseClickHandler(e) : Void {
		externalAudioFile = new File();
		externalAudioFile.addEventListener(flash.events.Event.SELECT, function(_) {
			_controller.audioSource = external(externalAudioFile);
			externalAudioFileBox.text = externalAudioFile.nativePath;
		} );
		externalAudioFile.browseForOpen("Set Audio Track", [new FileFilter("Audio Files (*.mp3, *.wav, *.ogg, *.aac)", "*.mp3;*.wav;*.ogg;*.aac")]);
	}
	
	private var _bitmap : flash.display.Bitmap;
	
	private var _recording : Bool;
	private function convertProgressHandler(progress : SwivelProgressEvent) {
		// TODO
		progressBar.value = progress.progress;
		var text;
		text = switch(progress.task) {
			case StartEncoder(_, _):	"Starting video encoder...";
			case ParseSwf(job):			'Parsing SWF... (${job.file.name})';
			case MutateSwf(job):		'Tweaking SWF... (${job.file.name})';
			case EncodeSwf(job):
				recordingButton.visible = Type.enumEq(progress.job.duration,manual);
				'Encoding SWF to video... (${job.file.name})';
			case DecodeAudio:			'Decoding audio clips...';
			case MixAudio:				'Mixing audio track...';
			case StopEncoder:			'Finishing video encode...';
			case EncodeAudio:			'Encoding audio track...';
			case DeleteTempFiles:		'Cleaning up temporary files...';
		}
		progressText.text = text;
		
		if(progress.frame != null) {
			untyped {
				_previewImage._image._implComponent.bitmapData = progress.frame;
				_previewImage._image._implImage = progress.frame;
				//_previewImage._implComponent.width = 702;
				//_previewImage._implComponent.height = 395;
				if(_previewImage.visible == false) {
					_previewImage.visible = true;
					_previewImage.updateSize();
				}
			}
		} else _previewImage.visible = false;
	}
	
	private function audioCodecChangeHandler(_) {
		var codec : AudioCodec = audioCodecSelectBox.selectedItem;
		
		_controller.audioCodec = codec;
		
		if(codec.supportsBitRate) {
			audioBitrateSlider.enabled = true;
		} else {
			audioBitrateSlider.enabled = false;
			audioBitrateSlider.value = audioBitrateSlider.maximum;
		}
	}
	
	private function toggleRecordingHandler(_) {
		if(!_recording) {
			_controller.startRecording();
			_recording = true;
		} else {
			_controller.stopRecording();
			_recording = false;
			recordingButton.visible = false;
		}
	}
	
	// === OVERLAY TAB ===
	private function alphaSliderFunc(v : Float) return Std.string(Std.int(v * 100)) + "%";
	
	private function overlayBrowseClickHandler(e) : Void {
		_watermarkFile = new File();
		_watermarkFile.addEventListener(flash.events.Event.SELECT, watermarkSelectHandler );
		_watermarkFile.browseForOpen("Choose Watermark", [new FileFilter("Image Files (*.png, *.jpg, *.jpeg, *.gif)", "*.png;*.jpg;*.jpeg;*.gif")]);
	}
	
	private function watermarkFileEditHandler(_) {
		_watermark.image = null;
		try {
			_watermarkFile = new File(watermarkFileBox.text);
			watermarkSelectHandler(null);
		}
		catch(error:Dynamic) _watermarkFile = null;
	}
	
	private function watermarkSelectHandler(_) {
		_watermark.image = null;
		drawWatermarkPreview();
		watermarkFileBox.text = _watermarkFile.nativePath;
		var asset = new com.huey.assets.Asset("watermark", External(_watermarkFile.nativePath));
		asset.onLoaded.add(function(_) { _watermark.image = asset.data; asset.onLoaded.removeAll(); drawWatermarkPreview(); asset = null; } );
		asset.load();
	}
		
	private function drawWatermarkPreview() {
		if(_settingsContainer.state != "overlay") return;
		var g : flash.display.Graphics = untyped watermarkPreview._implComponent.graphics;
		g.clear();

		var w : Float = 108.0;
		var h : Float = 61.0;
		var scale : Float;
		var aspect = _controller.outputWidth / _controller.outputHeight;
		if(aspect > w/h){
			scale = w/_controller.outputWidth;
			h = w / aspect;
		} else {
			scale = h/_controller.outputHeight;
			w = h * aspect;
		}
		
		g.lineStyle();
		g.beginFill(0x425137, .35);
		g.drawRect(-2, -2, w+2, h+2);
		g.endFill();
		g.beginFill(0x425137);
		g.drawRect(0, 0, w, h);
		g.endFill();
		g.lineStyle(1, 0, 0.5);
		g.moveTo(0, 0);
		g.lineTo(w, h);
		g.moveTo(w, 0);
		g.lineTo(0, h);
		g.lineStyle();
		
		if(_watermark.image == null) return;
		var iw : Float = _watermark.image.width * _watermark.scale * scale;
		var ih : Float = _watermark.image.height * _watermark.scale * scale;
		var m = 2.0 * scale;
		g.beginFill(0xe98a4b, _watermark.alpha);
		switch(_watermark.align) {
			case topLeft:		g.drawRect(m, m, iw, ih);
			case topCenter:		g.drawRect((w-iw)/2, m, iw, ih);
			case topRight:		g.drawRect(w-iw-m, m, iw, ih);
			case middleLeft:	g.drawRect(m, (h-ih)/2, iw, ih);
			case center:		g.drawRect((w-iw)/2, (h-ih)/2, iw, ih);
			case middleRight:	g.drawRect(w-iw-m, (h-ih)/2, iw, ih);
			case bottomLeft:	g.drawRect(m, h-ih-m, iw, ih);
			case bottomCenter:	g.drawRect((w-iw)/2, h-ih-m, iw, ih);
			case bottomRight:	g.drawRect(w-iw-m, h-ih-m, iw, ih);
		}
		g.endFill();
		untyped watermarkPreview._implComponent.scrollRect = new flash.geom.Rectangle(0, 0, w, h);
	}
	
	// === ABOUT BOX ===
	private function aboutCloseHandler(_) {
		aboutBox.visible = false;
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, aboutFrameHandler);
		flash.Lib.current.stage.frameRate = 30;
	}
	private function contactClickHandler(_) flash.Lib.getURL(new flash.net.URLRequest("mailto:mike@newgrounds.com"));
	private function licenseClickHandler(_) File.applicationDirectory.resolvePath("license.txt").openWithDefaultApplication();
	
	// === ENCODING ===
	
	private function convertCompleteHandler(e) : Void {
		_controller.onProgress.removeAll();	// TODO: add once
		_controller.onComplete.removeAll();
		
		if(!_isCmdLine) {
			mainContainer.state = "complete";
			var time : Int = Std.int(e.time);
			var secs = Std.string(time % 60);
			time = Std.int(time/60);
			var mins = Std.string(time % 60);
			time = Std.int(time/60);
			var hours = Std.string(time);
			if(hours.length < 2) hours = "0" + hours;
			if(mins.length < 2) mins = "0" + mins;
			if(secs.length < 2) secs = "0" + secs;
			timeText.text = hours + ":" + mins + ":" + secs;
			fileSizeText.text = (Std.int(e.fileSize / (1024*1024) * 10)/ 10) + " MB";
			videoNameText.text = e.outputFile.name;
			
			new CompleteSound().play();
			orderToFront();
		} else {
			NativeApplication.nativeApplication.exit(0);
		}
	}
	
	private function navClickHandler(e) : Void {
		if(e.source==sourceButton) _settingsContainer.state = "source";
		else if(e.source==videoButton) _settingsContainer.state = "video";
		else if(e.source==audioButton) _settingsContainer.state = "audio";
		else if(e.source==overlayButton) {
			_settingsContainer.state = "overlay";
			drawWatermarkPreview();
		}
	}
	
	private function qualitySecretHandler(e) {
		if(e.controlKey) qualitySlider.maximum = 4;
		untyped qualitySlider.mouseMoveHandler(null);
	}
	
	private function qualitySliderFunc(v : Float) return ["Low", "Medium", "High", "Higher", "Highest"][Std.int(v)];
	
	private function cancelClickHandler(e) : Void {
		if(Type.enumConstructor(_controller.currentTask) == "EncodeSwf") {
			_controller.stopRecording();
			_recording = false;
			recordingButton.visible = false;
		} else {
			_controller.stop();
			mainContainer.state = "setup";
			
			convertButton.visible = false;
			haxe.Timer.delay( function() convertButton.visible = true, 2000);
			
			if(_isCmdLine) NativeApplication.nativeApplication.exit(-1);
		}
	}
	
	// === ENCODING COMPLETE ===
	private function videoNameClickHandler(_) _controller.outputFile.openWithDefaultApplication();
	private function backClickHandler(_) mainContainer.state = "setup";
	
	override private function uncaughtErrorHandler(e) {
		e.preventDefault();
		if(!_isCmdLine ) {
			mainContainer.state = "error";
			errorText.text = 'Whoa! Something bad happened, and the program blew up. Sorry about that!\nPlease copy and paste this junk and send it to mike@newgrounds.com along with the SWF you were converting:\n\n${Std.string(e.error)}\n${haxe.CallStack.exceptionStack().join("\n")}';
		} else {
			NativeApplication.nativeApplication.exit(-1);
		}
	}
}
