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

class ListBox extends Container {
	@bindable public var selectedItem(get_selectedItem, set_selectedItem) : Dynamic;
	private function get_selectedItem() : Dynamic {
		return if(selectedIndex >= 0) _items[selectedIndex].data else null;
	}
	private function set_selectedItem(v : Dynamic) : Dynamic {
		var i = 0;
		for (item in _items) {
			if ( item.data == v ) {
				set_selectedIndex(i);
				break;
			}
			i++;
		}
		
		return selectedItem;
	}
	
	public var onChange(default, null) : Dispatcher<UIEvent>;
	
	@bindable public var selectedIndex(default, set_selectedIndex) : Int = -1;
	private function set_selectedIndex(v : Int) : Int {
		_selectedRect.visible = false;
		
		selectedIndex = v;
		
		if (selectedIndex < 0) selectedIndex = -1;
		if (selectedIndex > _items.length - 1) selectedIndex = _items.length - 1;
		
		if (selectedIndex >= 0) {
			_selectedRect.visible = true;
			_selectedRect.y = _items[selectedIndex].view.y + 4;
		}
		
		dispatchBinding("selectedItem");
		onChange.dispatch({source: this});
		return selectedIndex;
	}
	
	public function new() {
		onChange = new Dispatcher();
		
		super();
		_items = new Array();
		
		_scrollRect = new flash.geom.Rectangle(0, 0, 290, 70);
		_itemContainer = new Container();
		_itemContainer.x = 9;
		_itemContainer.y = 2;
		_itemContainer._implComponent.scrollRect = _scrollRect;
		add(_itemContainer);
		
		_selectedRect = new Rectangle(0xccf3e728, 287, 15);
		_itemContainer.add(_selectedRect);
		_selectedRect.x = -2;
		_selectedRect.visible = false;
		
		_scrollButton = new Button();
		_scrollButton.add(new Image(com.huey.assets.AssetManager.instance.getAsset("btnDragger")));
		_scrollButton.x = 295;
		_scrollButton.y = 5;
		_scrollButton.visible = false;
		_scrollButton.onMouseDown.add(function(_) {
			flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			mouseMoveHandler(null);
		});
		_scrollButton.onMouseUp.add(function(_) {
			flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		});
		_implComponent.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		add(_scrollButton);
	}
	
	private function mouseWheelHandler(e) {
		if(_items.length <= 4) return;
		_scrollButton.y -= e.delta;
		updateScrollRect();
		e.updateAfterEvent();
	}
	
	private function mouseMoveHandler(e) {
		_scrollButton.y = _implComponent.mouseY;
		updateScrollRect();
		if(e != null) e.updateAfterEvent();
	}

	private function updateScrollRect() {
		if(_scrollButton.y < 5) _scrollButton.y = 5;
		if(_scrollButton.y > 55) _scrollButton.y = 55;
		_scrollRect.y = 16 * (_items.length - 4) * (_scrollButton.y - 4) / 50;
		_itemContainer._implComponent.scrollRect = _scrollRect;
	}
	
	private function updateScroll() {
		_scrollButton.visible = _items.length > 4;
		_scrollButton.y = 5 + (_scrollRect.y * 50) / (16 * (_items.length - 4));
		if(_scrollButton.y < 5) _scrollButton.y = 5;
		if(_scrollButton.y > 55) { _scrollButton.y = 55; updateScrollRect(); }
	}
	
	public function addItem(item : Dynamic, ?label : String) : Void {
		var comp = new Container();
		var labelComp = new Label();
		labelComp.text = if(Reflect.hasField(item, "label")) Reflect.getProperty(item, "label") else Std.string(item);
		comp.x = 0;
		comp.y = _items.length * 14;
		// TODO
		labelComp.x = 15;
		labelComp.font = "AdvoCut_10pt_st";
		labelComp.size = 10;
		labelComp.color = 0x425137;
		labelComp.autoSize = false;
		labelComp.width = 266;
		comp.add(labelComp);
		untyped comp._implComponent.buttonMode = true;
		untyped comp._implComponent.mouseChildren = false;
		comp.onClick.add( function(i) {return function(e) selectedIndex = i;}(_items.length) );
		var str = Std.string(_items.length + 1);
		if(str.length < 2) str = "0" + str;
		labelComp = new Label(str);
		labelComp.font = "AdvoCut_10pt_st";
		labelComp.size = 10;
		labelComp.color = 0xD16436;
		labelComp.width = 20;
		labelComp.x = 0;
		comp.add(labelComp);
		_itemContainer.add(comp);
		_items.push( { data : item, label: comp, view: comp, number: labelComp} );
		
		updateScroll();
	}

	public function removeItemAt(i : Int) : Void {
		var item = _items[i];
		if(item != null) {
			_itemContainer.remove(item.label);
			_items.splice(i, 1);
			items.splice(i, 1);
			
			for(j in i..._items.length) {
				var str = Std.string(j + 1);
				if(str.length < 2) str = "0" + str;
				_items[j].view.y = j * 14;
				_items[j].number.text = str;
			}
			
			if(i == selectedIndex) {
				if(i > _items.length - 1) i = _items.length - 1;
				selectedIndex = i;
			}
			
			updateScroll();
		}
	}

	public var items(default, set) : Array<Dynamic>;
	private function set_items( v : Array<Dynamic> ) : Array<Dynamic> {
		for (item in _items)
			_itemContainer.remove(item.label);
		
		_items = [];
		
		for (item in v)
			addItem(item);
			
		if (selectedIndex >= _items.length) {
			selectedIndex = _items.length - 1;
		}
			
		return items = v;
	}
	
	private var _items : Array<ListItem>;
	private var _selectedRect : Rectangle;
	private var _itemContainer : Container;
	private var _scrollRect : flash.geom.Rectangle;
	private var _scrollButton : Button;
}

typedef ListItem = { label : Container, data : Dynamic, view : Container, number : Label };