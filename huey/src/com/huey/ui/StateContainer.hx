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
import haxe.ds.StringMap;

class StateContainer extends Container {
	public var state(default, set) : String;
	private function set_state(v : String) : String {
		var oldState = _states.get(state);
		if (oldState != null) {
			for(child in oldState)
				remove(child);
		}
		
		var newState = _states.get(v);
		if (newState != null) {
			for (comp in newState) add(comp);
		}

		return state = v;
	}
	
	
	private var _states : StringMap<UIState>;
	
	public function addToState(component : Component, state : String) : Void {
		if (!_states.exists(state)) _states.set(state, new UIState());
		_states.get(state).push(component);
		if (this.state == null) this.state = state;
		else if (state == this.state) add(component);
	}

	public function new() {
		super();
		_states = new StringMap();
	}
}

typedef UIState = Array<Component>;