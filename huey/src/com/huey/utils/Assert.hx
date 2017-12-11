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

class Assert
{
	inline public static function assertNull<T>(v : T, ?message : String) : Void {
		if (v != null) {
			throw 'assertNull failed!\n$message';
		}
	}
	
	inline public static function assertNotNull<T>(v : T, ?message : String) : Void {
		if (v == null) {
			throw 'assertNotNull failed!\n$message';
		}
	}
	
	inline public static function assertTrue(b : Bool, ?message : String) : Void {
		if (!b) {
			throw 'assertTrue failed! $message';
		}
	}
	
	inline public static function assertFalse(b : Bool, ?message : String) : Void {
		if (b) {
			throw 'assertFalse failed! $message';
		}
	}
	
	inline public static function assertEqual<T>(expected : T, actual : T, ?message : String) : Void {
		if (expected != actual) {
			throw 'assertEqual failed! $expected != $actual\n$message';
		}
	}
	
	inline public static function assertNotEqual<T>(expected : T, actual : T, ?message : String) : Void {
		if (expected == actual) {
			throw 'assertNotEqual failed! $expected == $actual\n$message';
		}
	}
}