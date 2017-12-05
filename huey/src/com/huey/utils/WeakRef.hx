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

package com.huey.utils;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

#if flash9

class WeakRef<T>
{
	private var _dictionary : flash.utils.TypedDictionary<T, Int>;
	
	public function new(object : T) {
		_dictionary = new flash.utils.TypedDictionary(true);
		if (object != null)
			_dictionary.set(object, 1);
	}
	
	public function get() : Null<T> {
		for (key in _dictionary.keys())
			if (key != null) return key;
		return null;
	}
}

#else

class WeakRef<T>
{
	private var _object : T;
	
	public function new(object : T) {
		_object = t;
	}
	
	inline public function get() : Null<T> {
		return _object;
	}
}

#end