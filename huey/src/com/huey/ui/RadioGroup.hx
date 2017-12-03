package com.huey.ui;
import com.huey.events.Dispatcher;

class RadioGroup extends com.huey.binding.Binding.Bindable {
	public function new() {
		onChange = new Dispatcher();
		super();
		items = new Array();
	}
	
	public var onChange : Dispatcher<Dynamic>;
	
	public var items : Array<RadioButton>;
	@bindable public var selectedItem(default, set_selectedItem) : Null<RadioButton> = null;
	private inline function set_selectedItem(v) {
		selectedItem = v;
		onChange.dispatch(null);
		return v;
	}
}