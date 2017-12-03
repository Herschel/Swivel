package com.huey.utils;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Assert
{
	inline public static function assertNull<T>(v : T, ?message : String) : Void {
		if (v != null) {
			throw Std.format("assertNull failed!\n$message");
		}
	}
	
	inline public static function assertNotNull<T>(v : T, ?message : String) : Void {
		if (v == null) {
			throw Std.format("assertNotNull failed!\n$message");
		}
	}
	
	inline public static function assertTrue(b : Bool, ?message : String) : Void {
		if (!b) {
			throw Std.format("assertTrue failed! $message");
		}
	}
	
	inline public static function assertFalse(b : Bool, ?message : String) : Void {
		if (b) {
			throw Std.format("assertFalse failed! $message");
		}
	}
	
	inline public static function assertEqual<T>(expected : T, actual : T, ?message : String) : Void {
		if (expected != actual) {
			throw Std.format("assertEqual failed! $expected != $actual\n$message");
		}
	}
	
	inline public static function assertNotEqual<T>(expected : T, actual : T, ?message : String) : Void {
		if (expected == actual) {
			throw Std.format("assertNotEqual failed! $expected == $actual\n$message");
		}
	}
}