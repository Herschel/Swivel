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

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Slider extends Container {
	@bindable public var value(default, set) : Float;
	private function set_value(v : Float) : Float {
		if (step != 0) v = Math.round(v / step) * step;
		if (v < minimum) v = minimum;
		if (v > maximum) v = maximum;
		value = v;
		label.text = if(labelFunc != null) labelFunc(value) else Std.string(value);
		updateNub();
		return value;
	}
	
	public var minimum(default, set) : Float;
	private inline function set_minimum(v : Float) : Float {
		minimum = v;
		set_value( value );
		return minimum;
	}
	
	public var maximum(default, set) : Float;
	private inline function set_maximum(v : Float) : Float {
		maximum = v;
		set_value( value );
		return maximum;
	}
	
	public var step(default, set) : Float;
	private inline function set_step(v : Float) : Float {
		if (v < 0 || Math.isNaN(v)) v = 0;
		step = v;
		set_value( value );
		return step;
	}
	
	@forward(label) public var font : String;
	@forward(label) public var size : Float;
	@forward(label) public var color : Int;
	@forward(label) public var bold : Bool;
	
	public var nubMinimum : Float = 5.0;
	public var nubMaximum : Float = 200.0;
	
	public var nub : Component;
	
	public var label : Label;
	
	public var labelFunc(default, set) : Float -> String;
	private function set_labelFunc(v) {
		labelFunc = v;
		label.text = if (labelFunc != null) labelFunc(value) else Std.string(value);
		return labelFunc;
	}
	
	public function new() {
		super();
		label = new Label();
		add(label);
		
		value = minimum = 0.0;
		maximum = 1.0;
		step = 0;
		
		onMouseDown.add(mouseDownHandler);
		onMouseUp.add(mouseUpHandler);
		
		untyped _implComponent.buttonMode = true;
	}
	
	private function updateNub() : Void {
		if(nub != null) nub.x = (nubMaximum - nubMinimum) * (value - minimum) / (maximum - minimum) + nubMinimum - nub.width / 2;
	}
	
	private function mouseDownHandler(_) : Void {
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
		mouseMoveHandler(null);
	}
	
	private function mouseUpHandler(_) : Void {
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
	}
	
	private function mouseMoveHandler(e) : Void {
		value = untyped { minimum + (maximum - minimum) * (_implComponent.mouseX - nubMinimum) / (nubMaximum-nubMinimum); };
		if(e != null) e.updateAfterEvent();
	}
}