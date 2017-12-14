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

class CheckBox extends Button
{
	@bindable public var selected(default, set) : Bool;
	private function set_selected(v : Bool) : Bool {
		selected = v;
		updateState();
		return selected;
	}

	public var selectedUpState(default, set) : Component;
	public var selectedOverState(default, set) : Component;
	public var selectedDownState(default, set) : Component;

	inline private function set_selectedUpState(v : Component) : Component {
		if(v != null)
			_states.set("selectedUp", [v]);
		return v;
	}

	inline private function set_selectedOverState(v : Component) : Component {
		if(v != null)
			_states.set("selectedOver", [v]);
		return v;
	}

	inline private function set_selectedDownState(v : Component) : Component {
		if(v != null)
			_states.set("selectedDown", [v]);
		return v;
	}

	public function new() {
		super();
		onClick.add(clickHandler);
	}

	override private function mouseOverHandler(e) : Void {
		if (state != "down" && state != "selectedDown") {
			if(selected) {
				if (_states.exists("selectedOver")) state = "selectedOver";
			} else {
				if (_states.exists("over")) state = "over";
			}
		}

		_isOver = true;
	}
	
	override private function mouseOutHandler(e) : Void {
		if(state != "down" && state != "selectedDown") {
			state = if(selected) "selectedUp" else "up";
		}
		
		_isOver = false;
	}
	
	override private function mouseDownHandler(e) : Void {
		if(selected) {
			if (_states.exists("selectedDown")) state = "selectedDown";
		} else {
			if (_states.exists("down")) state = "down";
		}
	}
	
	override private function mouseUpHandler(e) : Void {
		if (_isOver) {
			if (!selected) {
				if (_states.exists("over")) state = "over";
			} else {
				if (_states.exists("selectedOver")) state = "selectedOver";
			}
		} else {
			state = if (selected) "selectedUp" else "up";
		}
	}
	
	private function updateState() : Void {
		if (_isOver) {
			if (!selected) {
				if (_states.exists("over")) state = "over";
			} else {
				if (_states.exists("selectedOver")) state = "selectedOver";
				else state = "selectedUp";
			}
		} else {
			state = if (selected) "selectedUp" else "up";
		}
	}
	
	private function clickHandler(e) : Void {
		selected = !selected;
	}
}