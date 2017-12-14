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

package com.huey.ui;

class ScaledImage extends Container {
	public var scaleMode(default, set_scaleMode) : ScaleMode;
	private function set_scaleMode(v) {
		scaleMode = v;
		updateSize();
		return v;
	}
	
	private var _width : Int;
	private var _height : Int;
	
	private function updateSize() {
		if((untyped _image._implImage) == null) return;
		_implComponent.scrollRect = new flash.geom.Rectangle(0, 0, _width, _height);
		var desiredAspect = _width / _height;
		var actualAspect = untyped _image._implImage.width / _image._implImage.height;
		switch(scaleMode) {
			case crop:
				if(actualAspect > desiredAspect) {
					_image.height = _height;
					_image.width = _height * actualAspect;
					_image.x = (_height * actualAspect - _width)/2;
					_image.y = 0;
				} else {
					_image.width = _width;
					_image.height = _implComponent.width / actualAspect;
					_image.x = 0;
					_image.y = (_width / actualAspect - _height)/2;
				}
			case letterbox:
				if(actualAspect > desiredAspect) {
					_image.width = _width;
					_image.height = _width / actualAspect;
					_image.x = 0;
					_image.y = (_height - _width / actualAspect)/2;
				} else {
					_image.height = _height;
					_image.width = _height * actualAspect;
					_image.x = (_width - _height * actualAspect)/2;
					_image.y = 0;
				}
			case stretch:
				_image.width = _width;
				_image.height = _height;
				_image.x = _image.y = 0;
		}
	}
	
	private var _width : Float;
	private var _height : Float;
	
	override  private function set_width(v) {
		_width = v;
		updateSize();
		return v;
	}
	override private function set_height(v) {
		_height = v;
		updateSize();
		return v;
	}
	
	public function new(source : com.huey.assets.Asset) {
		super();
		_image = new Image(source);
		add(_image);
		scaleMode = letterbox;
	}
	
	private var _image : Image;
}

enum ScaleMode {
	crop;
	letterbox;
	stretch;
}