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