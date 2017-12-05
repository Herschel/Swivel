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

class Container extends Component
{
	public var numChildren(get, never) : Int;

	private var _children : List<Component>;
	private var _implContainer : flash.display.Sprite;
	
	private var _needsDepthSorting : Bool;
	
	public function new() {
		_implContainer = new flash.display.Sprite();
		super(_implContainer);
		_children = new List();
	}
	
	public function add(child : Component) : Void {

		_children.add(child);
		child.parent = this;
		_implContainer.addChild(child._implComponent);
	}
	
	public function remove(child : Component) : Bool {
		var removed : Bool = _children.remove(child);
		_implContainer.removeChild(child._implComponent);
		child.parent = null;
		return removed;
	}

	public function removeAll() : Void {
		for(child in _children) {
			_implContainer.removeChild(child._implComponent);
			child.parent = null;
		}
		_children.clear();
	}
	
	private function get_numChildren() : Int {
		return _children.length;
	}
	
	public function needDepthSort() : Void {
		_needsDepthSorting = true;
		flash.Lib.current.stage.addEventListener(flash.events.Event.EXIT_FRAME, depthSort, false, 0, true);
	}
	
	private function depthSort(_) {
		// TODO: merge sort linked list
		if(_needsDepthSorting) {
			flash.Lib.current.stage.removeEventListener(flash.events.Event.EXIT_FRAME, depthSort);
			var a = [];
			for (child in _children) a.push(child);
			a.sort( function(a, b) { return if (a.depth < b.depth) -1 else if(a.depth > b.depth) 1 else 0; } );
			var i = 0;
			for (child in a) _implContainer.setChildIndex(child._implComponent, i++);
			_needsDepthSorting = false;
		}
	}

}