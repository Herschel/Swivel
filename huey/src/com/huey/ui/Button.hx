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

class Button extends StateContainer
{
	public var label : String;
		
	public var upState(default, set) : Component;
	public var overState(default, set) : Component;
	public var downState(default, set) : Component;
	
	private var _isOver : Bool;

	inline private function set_upState(v : Component) : Component {
		_states.set("up", []);
		if(v != null) addToState(v, "up");
		return upState = v;
	}

	inline private function set_overState(v : Component) : Component {
		if(v != null) {
			_states.set("over", []);
			addToState(v, "over");
		}
		return overState = v;
	}

	inline private function set_downState(v : Component) : Component {
		if(v != null) {
			_states.set("down", []);
			addToState(v, "down");
		}
		return downState = v;
	}
	
	public function new() {
		super();
		
		_implContainer.buttonMode = true;
		_isOver = false;
		state = "up";

		onMouseOver.add(mouseOverHandler);
		onMouseDown.add(mouseDownHandler);
		onMouseUp.add(mouseUpHandler);
		onMouseOut.add(mouseOutHandler);
	}
	
	private function mouseOverHandler(e) : Void {
		if (state != "down") {
			if(_states.exists("over")) state = "over";
		}

		_isOver = true;
	}
	
	private function mouseOutHandler(e) : Void {
		if(state != "down") {
			state = "up";
		}
		
		_isOver = false;
	}
	
	private function mouseDownHandler(e) : Void {
		if(_states.exists("down")) state = "down";
	}
	
	private function mouseUpHandler(e) : Void {
		if (_isOver && _states.exists("over"))
			state = "over";
		else
			state = "up";
	}
}