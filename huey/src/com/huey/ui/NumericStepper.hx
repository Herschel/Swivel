package com.huey.ui;
import com.huey.events.Dispatcher;

class NumericStepper extends Container {
	@forward(_textBox) public var font : String;
	@forward(_textBox) public var size : Float;
	@forward(_textBox) public var color : Int;
	
	public var minimum : Float;
	public var maximum : Float;
	public var step : Float = 1;

	public var onChange(default, null) : Dispatcher<UIEvent>;
	public var onUserChange(default, null) : Dispatcher<UIEvent>;
	
	@bindable public var value(default, set) : Float;
	private function set_value(v : Float) : Float {
		value = v;
		if(Math.isNaN(value)) value = 0;
		
		if(value < minimum) value = minimum;
		else if(value > maximum) value = maximum;

		if(_textBox != null) _textBox.text = Std.string(value);
		
		onChange.dispatch({source: this});
		
		return value;
	}
	
	public function new() {
		super();
		onChange = new Dispatcher();
		onUserChange = new Dispatcher();
		value = 0;
		minimum = Math.NEGATIVE_INFINITY;
		maximum = Math.POSITIVE_INFINITY;
	}

	public var textX(default, set) : Float;
	private function set_textX(v : Float) : Float { return _textBox.x = v; }
	
	public var textY(default, set) : Float;
	private function set_textY(v : Float) : Float { return _textBox.y = v; }
	
	public var _textBox(default, set) : TextBox;
	private function set__textBox(v) {
		_textBox = v;
		_textBox.onUserEdited.add(function(_) { value = Std.parseFloat(_textBox.text); onUserChange.dispatch({source: this});});
		value = value;
		_textBox.allowedCharacters = "0123456789";
		
		return _textBox;
	}

	public var incButton(default, set) : Button;
	private function set_incButton(v : Button) : Button {
		add(v);
		v.onClick.add(function(_) {value+=step; onUserChange.dispatch({source: this});} );
		return incButton = v;
	}
	public var decButton(default, set) : Button;
	private function set_decButton(v : Button) : Button {
		add(v);
		v.onClick.add(function(_) {value-=step; onUserChange.dispatch({source: this});} );
		return decButton = v;
	}
}