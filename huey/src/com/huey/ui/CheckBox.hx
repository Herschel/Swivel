package com.huey.ui;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class CheckBox extends Button
{
	@bindable public var selected(default, setSelected) : Bool;
	private function setSelected(v : Bool) : Bool {
		selected = v;
		updateState();
		return selected;
	}

	public var selectedUpState(default, setSelectedUpState) : Component;
	public var selectedOverState(default, setSelectedOverState) : Component;
	public var selectedDownState(default, setSelectedDownState) : Component;

	inline private function setSelectedUpState(v : Component) : Component {
		if(v != null)
			_states.set("selectedUp", [v]);
		return v;
	}

	inline private function setSelectedOverState(v : Component) : Component {
		if(v != null)
			_states.set("selectedOver", [v]);
		return v;
	}

	inline private function setSelectedDownState(v : Component) : Component {
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