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
import com.huey.binding.BindableArray;
import com.huey.events.Dispatcher;
import com.huey.utils.Logger;
import com.newgrounds.swivel.audio.AudioTracker;
import com.newgrounds.swivel.ffmpeg.FfmpegProcess;
import com.newgrounds.swivel.ffmpeg.VideoPreset;
import com.newgrounds.swivel.ffmpeg.AudioCodec;
import com.newgrounds.swivel.swf.*;
import com.newgrounds.swivel.swf.SWFRecorder.ScaleMode;
import flash.display.BitmapData;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import format.swf.Reader;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import com.newgrounds.swivel.swf.SwivelConnection.ISwivelConnection;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

@:autoBuild(com.huey.macros.Macros.build())
interface ControllerBase { }

class SwivelController extends com.huey.binding.Binding.Bindable implements ControllerBase {
	public var onProgress(default, null)		: Dispatcher<SwivelProgressEvent>;
	public var onStateChange(default, null) 	: Dispatcher<Dynamic>;
	public var onComplete(default, null)		: Dispatcher<Dynamic>;
	
	@bindable public var jobs : BindableArray<SwivelJob>; // TODO

	private var _recorder : SWFRecorder;

	@bindable @forward(_recorder) public var outputWidth : Int;
	@bindable @forward(_recorder) public var outputHeight : Int;
	@bindable @forward(_recorder) public var scaleMode : ScaleMode;
	@bindable @forward(_recorder) public var transparentBackground : Bool;

	public var stereoAudio : Bool = true;
	public var audioSource : AudioSource;
	
	@forward(_recorder) public var watermark : Null<Watermark>;

	private var _videoFile : File;
	private var _audioFile : File;
	private var _audioOutput : FileStream;
	@bindable public var outputFile : File;
	@bindable public var videoPreset : VideoPreset;
	public var videoBitRate : Null<Int>;
	@bindable public var audioCodec : AudioCodec;
	public var audioBitRate : Null<Int>;
	
	private var _parsedSwf : SwivelSwf;
		
	private var _ffmpeg : FfmpegProcess;
	private var _connection : ISwivelConnection;
	
	private var _recordingStartFrame : Int;
	private var _recordingNumFrames : Int;
	private var _totalNumFrames : Int;
	
	private var _audioTracker : AudioTracker;

	private var _startTime : Float;
	
	private var _taskList : List<SwivelTask>;
	public var currentTask(default, null) : SwivelTask;
	private var _currentJob : SwivelJob;
	
	public function new() {
		super();
		jobs = new BindableArray();
		
		onProgress = new Dispatcher();
		onStateChange = new Dispatcher();
		onComplete = new Dispatcher();
	
		_recorder = new SWFRecorder();
		_recorder.onFrameCaptured.add(onFrameCaptured);
		
		audioSource = swf;
		
		videoPreset = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.PRESETS[0];
		audioCodec = com.newgrounds.swivel.ffmpeg.FfmpegProcess.FfmpegEncoder.AUDIO_CODECS[0];
	}
	
	public function start() : Void {
		_startTime = haxe.Timer.stamp();
		
		_progress = 0;
		_totalNumFrames = 0;
		
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, dispatchProgress);
		
		if(outputFile.name.split(".").length < 2) outputFile = outputFile.resolvePath('../${outputFile.name}.mp4');
		
		var usesSwfAudio = switch(audioSource) {
			case swf:
				_audioFile = File.applicationStorageDirectory.resolvePath("temp_audio.raw");
				if(_audioFile.exists) try _audioFile.deleteFile() catch(e:Dynamic) {}
				true;
				
			case external(source):
				_audioFile = source;
				false;
				
			default:
				_audioFile = null;
				false;
		}
		
		_videoFile = if(usesSwfAudio) {
			var nameParts = outputFile.name.split(".");
			var name = if(nameParts.length > 1) "temp_video." + nameParts[nameParts.length-1] else "temp_video.mp4";
			File.applicationStorageDirectory.resolvePath(name);
		} else {
			outputFile;
		}
				
		_taskList = new List();
		_taskList.add( StartEncoder(_videoFile, if(!usesSwfAudio) _audioFile else null) );
		for(job in jobs) {
			_taskList.add( ParseSwf(job) );
			_taskList.add( MutateSwf(job) );
			if(usesSwfAudio) {
				_taskList.add( EncodeSwf(job) );
				_taskList.add( DecodeAudio );
				_taskList.add( MixAudio );
			} else {
				_taskList.add( EncodeSwf(job) );
			}
		}
		_taskList.add( StopEncoder );
		if(usesSwfAudio) {
			_taskList.add( EncodeAudio );
		}
		_taskList.add( DeleteTempFiles );
		
		runNextTask();
	}
	
	private function runNextTask() {
		currentTask = _taskList.pop();
		if(currentTask == null) {
			finish();
			return;
		}
		
		flash.ui.Mouse.show();
		
		_frame = null;
		
		_waitCount = 0;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, runTaskDelay);
	}
	
	private function runTaskDelay(_) {
		_waitCount++;
		if(_waitCount >= 2) {
			flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, runTaskDelay);
			runTask(currentTask);
		}
	}
	
	private function runTask(task : SwivelTask) {
		_currentJob = null;
		switch(task) {
			case StartEncoder(outputFile, inputAudioFile):
				var ffmpeg = new FfmpegEncoder(videoPreset, videoBitRate, outputFile, _recorder.outputWidth, _recorder.outputHeight, jobs.array[0].swf.frameRate, if(inputAudioFile != null) inputAudioFile.nativePath else null, audioCodec, audioBitRate, if(stereoAudio) 2 else 1);
				ffmpeg.onComplete.add(onEncodingComplete);
				_ffmpeg = ffmpeg;
				runNextTask();
				
			case ParseSwf(job):
				_currentJob = job;
				job.swf.parseSwf();
				_parsedSwf = job.swf;
				runNextTask();

			case MutateSwf(job):
				_currentJob = job;
				_swfMutators = new List();
				
				var startFrame = switch( job.duration ) {
					case frameRange(start,_): start - 1;
					default: 0;
				}

				_swfMutators.add( new SwivelMutator(startFrame) );
				if(job.forceBitmapSmoothing) _swfMutators.add( new BitmapSmoothingMutator() );
				if(job.swf.version >= 8) _swfMutators.add( new ScaleFilterMutator(_recorder.outputWidth / job.swf.width) );
				if(Type.enumEq(audioSource, swf)) { // TODO
					_audioTracker = new AudioTracker();
					switch(_parsedSwf.avmVersion) {
						case AVM1: _swfMutators.add( new SoundConnectionMutator("__swivel", _audioTracker) );
						case AVM2: _swfMutators.add( new AS3SoundConnectionMutator("__swivel", _audioTracker) );
					}
				}
				_swfMutators.add( new SilenceSoundMutator() );
				for (mutator in _swfMutators) mutator.mutate(job.swf);
				runNextTask();

			case EncodeSwf(job):
				_currentJob = job;
				
				if(_connection != null) _connection.close();
				if(Type.enumEq(audioSource, swf)) {
					if(Type.enumEq(_currentJob.swf.avmVersion, AVM1)) {
						_connection = new SwivelConnection();
					} else _connection = new AS3SwivelConnection();
				}
				
				_recordingStartFrame = 0;
				_recordingNumFrames = 0;
				_recorder.showWindow = Type.enumEq(job.duration, manual);
				_recorder.renderQuality = _currentJob.renderQuality;

				_recorder.startPlayback(_parsedSwf, _currentJob.parameters);
				if(!_recorder.showWindow) startRecording();
				
				_parsedSwf.disposeTags();
				flash.system.System.gc();
				
			case DecodeAudio:
				_audioTracker.onSoundsDecoded.add( function(_) runNextTask() );
				_audioTracker.decodeSounds();
				
			case MixAudio:
				_audioOutput = new FileStream();
				_audioOutput.endian = flash.utils.Endian.LITTLE_ENDIAN;
				_audioOutput.open(_audioFile, FileMode.APPEND);
		
				_audioTracker.onMixingComplete.add(audioMixCompleteHandler);
				_audioTracker.mixTrack(_audioOutput, _parsedSwf.frameRate, _recordingStartFrame, _recordingNumFrames);
				
			case StopEncoder:
				if(_ffmpeg != null) {
					_ffmpeg.close();
				}
				if(_connection != null) _connection.close();
			
			case EncodeAudio:
				var params = [
					"-y",
					
					"-i",		_videoFile.nativePath,
					
					"-c:a", 	"pcm_s16le",
					"-f",		"s16le",
					"-ar",		"44100",
					"-ac",		"2",
					"-i",		_audioFile.nativePath,

					"-c:v",		"copy",
					"-c:a",		audioCodec.codec,
					"-strict",
					"-2",
					"-ar",		"44100",
					"-ac",		if(stereoAudio) "2" else "1",
				];
				if(audioBitRate != null) {
					params.push("-b:a");
					params.push(Std.string(audioBitRate));
				}
				params.push( outputFile.nativePath );
				
				_ffmpeg =  new FfmpegProcess(params);
				_ffmpeg.onComplete.add(onEncodingComplete);
				
			case DeleteTempFiles:
				var dirList = File.applicationStorageDirectory.getDirectoryListing();
				for(f in dirList) {
					if(StringTools.startsWith(f.name, "temp_")) {
						try f.deleteFile() catch(e:Dynamic) {}
					}
				}
				runNextTask();
		}
	}
	
	public function startRecording() {
		_recordingStartFrame = _recorder.currentFrame;
		_recorder.startRecording();
		if(_audioTracker != null) _audioTracker.listen(_connection);
	}
	
	public function stopRecording() {
		_recorder.stop();
		runNextTask();
	}
	
	private var _waitCount : Int = 0;
			
	private var _swfMutators : List<ISWFMutator>;
	
	public function audioMixCompleteHandler(_) {
		_audioOutput.close();
		runNextTask();
	}
	
	public function stop() : Void {
		if(_ffmpeg != null) {
			_ffmpeg.onComplete.removeAll();
			_ffmpeg.close(true);
			_ffmpeg = null;
		}
		
		if(_connection != null) {
			_connection.close();
			_connection = null;
		}
		
		if(_recorder != null) {
			_recorder.stop();
		}
		
		if(_audioTracker != null) {
			_audioTracker.onSoundsDecoded.removeAll();
			_audioTracker.onMixingComplete.removeAll();
			_audioTracker.stop();
			_audioTracker = null;
		}
		
		try _audioOutput.close() catch(error:Dynamic) {}
		
		_taskList = null;
		
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, dispatchProgress);
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, runTaskDelay);
	}

	private function onEncodingComplete(exitCode) : Void {
		if(exitCode != 0) {
			var log = Logger.getLog("FfmpegLog");
			if(~/Permission denied/.match(log)) {
				throw('The output file ${outputFile.nativePath} cannot be accessed.\n\nIf it is open in another program, please close the program before converting.\n\nIf the problem persists, reboot your computer and try saving the output video in a different folder.');
			} else {
				throw('FFmpeg exited with exit code $exitCode\n\n$log');
			}
		}
		runNextTask();
	}
	
	private var _progress : Float;
	private var _frame : flash.display.BitmapData;
	
	private function onFrameCaptured(frame : flash.display.BitmapData) {
		if(_ffmpeg != null) _ffmpeg.send( frame.getPixels(frame.rect) );
	
		_recordingNumFrames++;
		_totalNumFrames++;
		_frame = frame;
		_progress = 0;
		switch(_currentJob.duration) {
			case frameRange(startFrame, endFrame):
				var currentFrame = try Std.int(flash.net.SharedObject.getLocal("__swivel").data.frame) catch(e:Dynamic) 0;
				_progress =  (currentFrame - startFrame) / (endFrame - startFrame + 1);
				if (currentFrame == endFrame) {
					_recorder.stop();
					runNextTask();
				}
				
			case manual:
				
			default:
		}
	}
	
	private function dispatchProgress(_) {
		onProgress.dispatch({
			frame:		_frame,
			progress:	if(Type.enumEq(currentTask, MixAudio)) _audioTracker.sample / _audioTracker.numSamples else _progress,
			task:		currentTask,
			job:		_currentJob,
		});
	}
	
	private function finish() {
		var time = haxe.Timer.stamp() - _startTime;
		stop();
		onComplete.dispatch( {
			time:			time,
			outputFile:		outputFile,
			fileSize:		outputFile.size,
		} );
	}
}

typedef SwivelProgressEvent = {
	var frame : Null<BitmapData>;
	var progress : Float;
	var task : SwivelTask;
	var job : SwivelJob;
};

typedef FileData = {
	var file : File;
	var swf : SwivelSwf;
}

enum SwivelTask {
	StartEncoder(outputVideo : File, ?inputAudio : File);
	ParseSwf(job : SwivelJob);
	MutateSwf(swf : SwivelJob);
	EncodeSwf(swf : SwivelJob);
	DecodeAudio;
	MixAudio;
	EncodeAudio;
	StopEncoder;
	DeleteTempFiles;
}

enum AudioSource {
	none;
	swf;
	external(source : File);
}