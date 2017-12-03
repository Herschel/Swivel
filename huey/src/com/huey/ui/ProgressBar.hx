package com.huey.ui;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class ProgressBar extends Slider {
	public function new()  {
		super();
		minimum = 0;
		maximum = 100;
		untyped _implComponent.mouseEnabled = _implComponent.tabEnabled = false;
	}
	
	override private function updateNub() : Void {
		untyped {
			_implComponent.scrollRect = new flash.geom.Rectangle(0, 0, 567 * (value - minimum) / (maximum - minimum), 13);
		}
	}

	
}