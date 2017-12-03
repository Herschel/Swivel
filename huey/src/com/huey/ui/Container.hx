package com.huey.ui;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Container extends Component
{
	public var numChildren(getNumChildren, never) : Int;

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
	
	private function getNumChildren() : Int {
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