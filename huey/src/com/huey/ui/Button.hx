package com.huey.ui;
/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Button extends StateContainer
{
	public var label : String;
		
	public var upState(default, setUpState) : Component;
	public var overState(default, setOverState) : Component;
	public var downState(default, setDownState) : Component;
	
	private var _isOver : Bool;

	inline private function setUpState(v : Component) : Component {
		_states.set("up", []);
		if(v != null) addToState(v, "up");
		return upState = v;
	}

	inline private function setOverState(v : Component) : Component {
		if(v != null) {
			_states.set("over", []);
			addToState(v, "over");
		}
		return overState = v;
	}

	inline private function setDownState(v : Component) : Component {
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