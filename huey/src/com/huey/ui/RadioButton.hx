package com.huey.ui;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class RadioButton extends CheckBox {
	public var group : RadioGroup;
	
	public function new() {
		super();
	}
	
	private override function clickHandler(e) : Void {
		if(group != null && group.selectedItem != null) group.selectedItem.selected = false;
		selected = true;
		if(group != null) group.selectedItem = this;
		updateState();
	}
}