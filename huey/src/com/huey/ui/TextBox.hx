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