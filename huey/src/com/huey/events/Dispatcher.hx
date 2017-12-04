package com.huey.events;

 /**
 * The Dispatcher class allows observers to listen for events.
 * @author Newgrounds.com, Inc.
 */
class Dispatcher<T>
{
	private var _listeners : List<T -> Void>;
	
	public var numListeners(get, null) : Int;
	private function get_numListeners() : Int {
		return _listeners.length;
	}
	
	/**
	* Creates a new Dispatcher.
	*/
	public function new() {
		_listeners = new List();
	}
	
	/**
	 * Attaches a listener method to this dispatcher.
	 * The listener will be called when the event is dispatched
	 * @param	listener
	 */
	public function add(listener : T -> Void) : Void {
		if(!Lambda.has(_listeners, listener)) _listeners.add(listener);
	}
	
	/**
	 * Dispatches the event and calls all registered listeners.
	 */
	public function dispatch(?event : T) : Void {
		for (listener in _listeners)
			listener(event);
	}
	
	/**
	 * Unregisters a listener from this dispatcher.
	 */
	public function remove(listener : T -> Void) : Void {
		_listeners.remove(listener);
	}
	
	/**
	 * Unregisters all listener from this dispatcher.
	 */
	public function removeAll() : Void {
		_listeners.clear();
	}
	
	/**
	 * Returns whether a listener is registered to this dispatcher.
	 */
	public function has(listener : T -> Void) : Bool {
		return Lambda.has(_listeners, listener);
	}
}