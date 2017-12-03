package com.huey.ui;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Rectangle extends Component {
	public function new(color : Int, width : Float, height : Float) {
		var shape = new flash.display.Shape();
		shape.graphics.beginFill(color, (color >>> 24) / 255.0);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.endFill();
		super(shape);
	}
}