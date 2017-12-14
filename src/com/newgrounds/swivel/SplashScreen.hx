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
import com.huey.ui.Component;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;

class SplashScreen extends Component {
	public function new() {
		_anim = new SplashAnim();
		_anim.addEventListener(flash.events.Event.ENTER_FRAME, enterFrameHandler);
		_anim.addEventListener(flash.events.Event.ADDED_TO_STAGE, addedToStageHandler, true);
		super(_anim);
	}
	
	private var _anim : MovieClip;
	
	private function enterFrameHandler(e) {
		if (_anim.currentFrame == _anim.totalFrames) {
			_anim.stop();
			_anim.removeEventListener(flash.events.Event.ENTER_FRAME, enterFrameHandler);
			if (parent != null) parent.remove(this);
		}
	}
	
	private function addedToStageHandler(e) {
		var url =
		switch(e.target.name) {
			case "swivelButton":	"http://www.newgrounds.com/swivel";
			case "ngButton":		"http://www.newgrounds.com";
			case "haxeButton":		"http://www.haxe.org";
			case "ffmpegButton":	"http://www.ffmpeg.org";
			default:				null;
		}
		if (url != null) {
			e.target.addEventListener(MouseEvent.CLICK, function(e) Lib.getURL(new URLRequest(url)) );
		}
	}
	
}