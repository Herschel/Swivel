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
import com.huey.tests.TestSuite;
import com.huey.events.Dispatcher;

/**
 * Tests the event handling system.
 */
class EventTests extends TestSuite {
	
	/** Tests dispatch instantiation and default values. */
	@test public function testDispatcher() {
		var dispatcher = new Dispatcher();
		assertEqual(0, dispatcher.numListeners, "A dispatcher should start with 0 listeners.");
	}
	
	/**
	 * Tests listener registration and dispatch.
	 * Verifies that the listener is called when an event is dispatched.
	 */
	@test public function testDispatch() {
		var dispatcher = new Dispatcher();
		var called = false;
		var eventArg = { x: 3 };
		function listener(e) {
			called = true;
			assertEqual(eventArg, e, "Event parameter was not dispatched");
		}
		
		dispatcher.add(listener);
		dispatcher.dispatch(eventArg);
		assertTrue(called, "Listener was not called after dispatch().");
	}
	
	/** Tests removal of a listener */
	@test public function testRemove() {
		var dispatcher = new Dispatcher();
		var calls = 0;
		function listener(e) { throw "Listener remains after remove()."; }
		dispatcher.add(listener);
		dispatcher.remove(listener);
		
		dispatcher.dispatch();
		assertEqual(calls, 0);
	}
	
	/** Test numListeners count */
	@test public function testNumListeners() {
		var dispatcher = new Dispatcher();
		
		function listener(e) { }
		assertEqual(0, dispatcher.numListeners);
		dispatcher.add(listener);
		assertEqual(1, dispatcher.numListeners);
		dispatcher.remove(listener);
		assertEqual(0, dispatcher.numListeners);
		
		dispatcher.add(listener);
		dispatcher.add(function (event) { } );
		assertEqual(2, dispatcher.numListeners);
	}
	
	/**
	 * Tests that a listener may only be added once
	 * Subsequent adds fail silently
	 */
	@test public function testAddOnlyOnce() {
		var dispatcher = new Dispatcher();
		var calls = 0;
		function listener(e) { calls++; }
		
		dispatcher.add(listener);
		dispatcher.add(listener);
		dispatcher.dispatch();
		assertEqual(1, calls, "A listener should not be added to a dispatcher twice.");
	}
	
	/** Tests dispatcher.removeAll(). */
	@test public function testRemoveAll() {
		function listener1(e) { throw "Listener remains after removeAll()."; }
		function listener2(e) { throw "Listener remains after removeAll()."; }
		var dispatcher = new Dispatcher();
		dispatcher.add(listener1);
		dispatcher.add(listener2);
		dispatcher.removeAll();
		dispatcher.dispatch();
	}
	
	/** Tests dispathcer.has(). */
	@test public function testHas() {
		function listener(e) { }
		
		var dispatcher = new Dispatcher();
		assertFalse( dispatcher.has(listener) );
		dispatcher.add( listener );
		assertTrue( dispatcher.has(listener) );
	}
}