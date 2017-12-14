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

package com.huey.events;

/**
 * The Dispatcher class allows observers to listen for events.
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