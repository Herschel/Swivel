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

package com.huey.binding;

class BindableArray<T> extends Binding.Bindable {
	private var _array : Array<T>;

	public static function fromArray<T>(a : Array<T>) : BindableArray<T> {
		var ba = new BindableArray();
		ba._array = a;
		ba.dispatchBindings();
		return ba;
	}

	public function new() {
		super();
		_array = [];
		dispatchBinding("length");
		dispatchBinding("_array");
	}

	public var length(get_length, null) : Int;
	private function get_length() : Int						{ return _array.length; }

	public var array(get_array, never) : Array<T>;
	public function get_array() : Array<T>					{ return _array; }
	public function concat(a : Array<T>) : Array<T>			{ return _array.concat(a); }
	public function copy() : Array<T>						{ return _array.copy(); }
	public function insert(pos : Int, x : T) : Void			{ _array.insert(pos, x); dispatchBindings(); }
	public function iterator() : Iterator<T>				{ return _array.iterator(); }
	public function join(sep : String) : String				{ return _array.join(sep); }
	public function pop() : Null<T>							{ var ret = _array.pop(); dispatchBindings(); return ret; }
	public function push(x : T) : Int						{
		var ret = _array.push(x); dispatchBindings(); return ret;
		}
	public function remove(x : T) : Bool					{ var ret = _array.remove(x); dispatchBindings(); return ret; }
	public function reverse() : Void						{ _array.reverse(); dispatchBindings(); }
	public function shift() : Null<T>						{ var ret = _array.shift(); dispatchBindings(); return ret; }
	public function sort(f : T->T->Int) : Void				{ _array.sort(f); dispatchBindings(); }
	public function splice(pos : Int, len : Int) : Array<T>	{ var ret = _array.splice(pos, len); dispatchBindings(); return ret; }
	public function toString() : String						{ return _array.toString(); }
	public function unshift(x : T) : Void					{ _array.unshift(x); dispatchBindings(); }

	private function dispatchBindings() : Void {
		dispatchBinding("length");
		dispatchBinding("_array");
	}
}