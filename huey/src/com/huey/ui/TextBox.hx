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
import com.huey.events.Dispatcher;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class TextBox extends Container {
	@forward(_text) public var text : String;
	@forward(_text) public var font : String;
	@forward(_text) public var size : Float;
	@forward(_text) public var color : Int;
	@forward(_text) public var allowedCharacters : String;
	
	public var textX(default, set_textX) : Float;
	private function set_textX(v : Float) : Float {
		return textX = _text.x = v;
	}

	public var textY(default, set_textY) : Float;
	private function set_textY(v : Float) : Float {
		return textY = _text.y = v;
	}
	
	override private function set_width(v : Float) {
		_text.width = v - textX*2;
		return v;
	}
	
	override private function set_height(v : Float) {
		_text.height = v - textY*2;
		return v;
	}
	
	public var onUserEdited(default, null) : Dispatcher<UIEvent>;
	
	public function new() {
		onUserEdited = new Dispatcher();
		super();
		_text = new Label();
		_text.autoSize = false;
		_text.editable = true;
		add(_text);
		_text.onUserEdited.add(function(_) onUserEdited.dispatch());
	}
	
	private var _text : Label;
}