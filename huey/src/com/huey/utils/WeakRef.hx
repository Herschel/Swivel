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