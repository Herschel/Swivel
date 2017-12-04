package com.huey.ui;
import com.huey.events.Dispatcher;
import com.huey.binding.Binding;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

@:autoBuild(com.huey.macros.Macros.build())
interface UIBase {
	
}

class Component extends Binding.Bindable implements UIBase {
	public var parent(default, null) : Container;
	public var root(get_root, null) : Container;
	private function get_root() {
		var c = this;
		while (c.parent != null) c = c.parent;
		return c.root;
	}
	
	@bindable public var enabled(default, set_enabled) : Bool;
	private function set_enabled(v) {
		if (Std.is(_implComponent, flash.display.InteractiveObject)) {
			untyped _implComponent.mouseEnabled = v;
			untyped _implComponent.tabEnabled = v;
			untyped _implComponent.mouseChildren = v;
		}

		_implComponent.alpha = if (v) 1.0 else 0.5;
		return enabled = v;
	}
	
	@forward(_implComponent) public var visible : Bool;
		
	@forward(_implComponent) public var x : Float;
	
	@forward(_implComponent) public var y : Float;
	
	@forward(_implComponent) public var alpha : Float;
	
	public var depth(default, set_depth) : Float;
	private function set_depth(v) {
		depth = v;
		//if(parent != null) parent.needDepthSort();
		return depth;
	}

	public var hitArea(default, set_hitArea) : HitArea;
	public function set_hitArea(v) {
		hitArea = v;
		if(Std.is(_implComponent, flash.display.Sprite))
		{
			untyped { _implComponent.graphics.clear(); }
			switch(hitArea) {
				case Self:
						untyped{ _implComponent.hitArea = null; }

				case Rectangle(x, y, width, height):
					untyped {
						_implComponent.graphics.beginFill(0, 0);
						_implComponent.graphics.drawRect(x, y, width, height);
						_implComponent.graphics.endFill();
					}
			}
		}
		return hitArea;
	}

	public var width(get_width, set_width) : Float;
	private function get_width() return _implComponent.width;
	private function set_width(v) return _implComponent.width = v;
	
	public var height(get_height, set_height) : Float;
	private function get_height() return _implComponent.height;
	private function set_height(v) return _implComponent.height = v;
	
	
	// ===== EVENTS =====
	public var onClick : Dispatcher<UIEvent>;
	public var onMouseOver : Dispatcher<UIEvent>;
	public var onMouseOut : Dispatcher<UIEvent>;
	public var onMouseDown(default, null) : Dispatcher<UIEvent>;
	public var onMouseUp(default, null) : Dispatcher<UIEvent>;
	
	public function new(implComponent : flash.display.DisplayObject) {
		super();
		_implComponent = implComponent;
		
		visible = true;
		x = 0.0;
		y = 0.0;
		depth = 0.0;

		hitArea = Self;
		
		onClick = new Dispatcher();
		_implComponent.addEventListener(flash.events.MouseEvent.CLICK, function(_) onClick.dispatch( { source: this } ) );
		
		onMouseOver = new Dispatcher();
		_implComponent.addEventListener(flash.events.MouseEvent.ROLL_OVER, function(e) {
			onMouseOver.dispatch( { source: this } );
			e.updateAfterEvent();
		} );
		
		onMouseOut = new Dispatcher();
		_implComponent.addEventListener(flash.events.MouseEvent.ROLL_OUT, function(e) {
			onMouseOut.dispatch( { source: this } );
			e.updateAfterEvent();
		} );
		
		onMouseDown = new Dispatcher();
		_implComponent.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDownInternalHandler );
		
		onMouseUp = new Dispatcher();
	}
	
	private var _implComponent : flash.display.DisplayObject;
	
	private function mouseDownInternalHandler(e) {
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, mouseUpInternalHandler, false, 0, true);
		onMouseDown.dispatch({source: this});
	//	e.updateAfterEvent();
	}
	
	private function mouseUpInternalHandler(e) {
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, mouseUpInternalHandler);
		onMouseUp.dispatch({source: this});
		//e.updateAfterEvent();
	}
}


enum HitArea {
	Self;
	Rectangle(x : Float, y : Float, width : Float, height : Float);
}