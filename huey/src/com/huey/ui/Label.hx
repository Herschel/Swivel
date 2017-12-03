package com.huey.ui;
import com.huey.events.Dispatcher;
import flash.text.TextFormat;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Label extends Component {
	public var text(default, set_text) : String;
	private function set_text(v : String) : String {
		if (v == null) v = "";
		text = _implText.text = v;
		return v;
	}
	
	@forward(_implText) public var wordWrap : Bool;
	
	public var color(get_color, set_color) : Int;
	private function get_color() return _textFormat.color
	private function set_color(v) {
		_textFormat.color = v;
		updateTextFormat();
		return v;
	}
	
	public var font(get_font, set_font) : String;
	private function get_font() return _textFormat.font
	private function set_font(v) {
		_textFormat.font = v;
		updateTextFormat();
		return v;
	}
	
	public var size(get_size, set_size) : Float;
	private function get_size() return _textFormat.size
	private function set_size(v) {
		_textFormat.size = v;
		updateTextFormat();
		return v;
	}
	
	public var bold(get_bold, set_bold) : Bool;
	private function get_bold() return _textFormat.bold
	private function set_bold(v) {
		_textFormat.bold = v;
		updateTextFormat();
		return v;
	}
	
	public var editable(get_editable, set_editable) : Bool;
	private function get_editable() return _implText.type == flash.text.TextFieldType.INPUT
	private function set_editable(v) {
		_implText.selectable = v;
		_implText.type = v ? flash.text.TextFieldType.INPUT : flash.text.TextFieldType.DYNAMIC;
		return v;
	}
	
	public var autoSize(get_autoSize, set_autoSize) : Bool;
	private function get_autoSize() return _implText.autoSize != flash.text.TextFieldAutoSize.NONE
	private function set_autoSize(v) {
		_implText.autoSize = if(v) flash.text.TextFieldAutoSize.LEFT else flash.text.TextFieldAutoSize.NONE;
		if(v == false) {
			_implText.width = 100;
			_implText.height = 20;
		}
		return v;
	}
	
	public var align(get_align, set_align) : TextAlign;
	private function get_align() {
		return switch(_textFormat.align) {
			case flash.text.TextFormatAlign.LEFT:		TextAlign.left;
			case flash.text.TextFormatAlign.CENTER:		TextAlign.center;
			case flash.text.TextFormatAlign.RIGHT:		TextAlign.right;
			case flash.text.TextFormatAlign.JUSTIFY:	TextAlign.justify;
			default:									TextAlign.left;
		}
	}
	private function set_align(v) {
		_textFormat.align = switch(v) {
			case TextAlign.left:	flash.text.TextFormatAlign.LEFT;
			case TextAlign.center:	flash.text.TextFormatAlign.CENTER;
			case TextAlign.right:	flash.text.TextFormatAlign.RIGHT;
			case TextAlign.justify:	flash.text.TextFormatAlign.JUSTIFY;
		}
		updateTextFormat();
		return v;
	}
	
	public var letterSpacing(get_letterSpacing, set_letterSpacing) : Float;
	private function get_letterSpacing() return _textFormat.letterSpacing
	private function set_letterSpacing(v) {
		_textFormat.letterSpacing = v;
		updateTextFormat();
		return v;
	}
	
	@forward(_implText.restrict) public var allowedCharacters : String;
	
	public var onUserEdited(default, null) : Dispatcher<UIEvent>;

	public function new(?text = "") {
		onUserEdited = new Dispatcher();
		_implText = new flash.text.TextField();
		_implText.width = 100;
		_implText.height = 20;
		_implText.addEventListener(flash.events.Event.CHANGE, textChangeHandler);
		_implText.addEventListener(flash.events.FocusEvent.FOCUS_OUT, function(_) dispatchChange());
		
		autoSize = true;
		_implText.embedFonts = true;
		_implText.selectable = false;
		_textFormat = new TextFormat("Arial", 12, 0x000000, false, false, false);
		updateTextFormat();
		super(_implText);
		this.text = text;
	}

	private var _implText : flash.text.TextField;
	private var _textFormat : flash.text.TextFormat;
	private var _changeTimer : haxe.Timer;
	
	private inline function updateTextFormat() {
		_implText.defaultTextFormat = _textFormat;
		_implText.setTextFormat(_textFormat);
	}
	
	private function textChangeHandler(_) {
		if(_changeTimer != null) {
			_changeTimer.stop();
		}
		
		_changeTimer = new haxe.Timer(750);
		_changeTimer.run = dispatchChange;
	}
	
	private function dispatchChange() {
		if(this.text != _implText.text) {
			this.text = _implText.text;
			onUserEdited.dispatch({source: this});
		}
		if(_changeTimer != null) {
			_changeTimer.stop();
			_changeTimer = null;
		}
	}
}