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
import com.huey.tests.TestSuite;

class AssertTests extends TestSuite
{
	#if debug
	
	@test public function testAssertNull() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertNull(null) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNull threw for null.";
		
		threw = false;
		try Assert.assertNull(true) catch (_ : Dynamic) threw = true;
		if (!threw) throw "assertNull didn't throw for non-null.";
		
		threw = false;
		try Assert.assertNull(0) catch (_ : Dynamic) threw = true;
		if (!threw) throw "assertNull didn't throw for 0.";
		
		threw = false;
		try Assert.assertNull(false, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertNull didn't throw with the supplied message.";
		}
		if (!threw) throw "assertNull didn't throw for false.";
	}
	
	@test public function testAssertNotNull() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertNotNull(null, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertNotNull didn't throw with the supplied message.";
		}
		if (!threw) throw "assertNotNull didn't throw for null.";
		
		threw = false;
		try Assert.assertNotNull(true) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNotNull threw for non-null.";
		
		threw = false;
		try Assert.assertNotNull(0) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNotNull threw for 0.";
		
		threw = false;
		try Assert.assertNotNull(false, msg) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNotNull threw for false.";
	}
	
	@test public function testAssertTrue() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertTrue(false, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertTrue didn't throw with the supplied message.";
		}
		if (!threw) throw "assertTrue didn't throw for false.";
		
		threw = false;
		try Assert.assertTrue(true) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertTrue threw for true.";
	}
	
	@test public function testAssertFalse() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertFalse(false) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertFalse threw for true.";
		
		threw = false;
		try Assert.assertFalse(true, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertFalse didn't throw with the supplied message.";
		}
		if (!threw) throw "assertFalse didn't throw for false.";
	}
	
	@test public function testAssertEqual() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertEqual(0, 0) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertEqual threw with equal ints.";
		
		threw = false;
		try Assert.assertEqual(0, 1) catch (_ : Dynamic) threw = true;
		if (!threw) throw "assertEqual didn't throw with non-equal ints.";
		
		var a = {x: 1};
		
		threw = false;
		try Assert.assertEqual(a, a) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertEqual threw with equal objects.";
		
		threw = false;
		try Assert.assertEqual(a, {x: 1}, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertEqual didn't throw with the supplied message.";
		}
		if (!threw) throw "assertEqual didn't throw with different objects.";
	}
	
	@test public function testAssertNotEqual() : Void {
		var threw : Bool;
		var msg : String = "msg";
		
		threw = false;
		try Assert.assertNotEqual(0, 0) catch (_ : Dynamic) threw = true;
		if (!threw) throw "assertNotEqual didn't throw with equal ints.";
		
		threw = false;
		try Assert.assertNotEqual(0, 1) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNotEqual threw with non-equal ints.";
		
		var a = {x: 1};
		
		threw = false;
		try Assert.assertNotEqual(a, a, msg) catch (error : Dynamic) {
			threw = true;
			if (Std.string(error).indexOf(msg) == -1) throw "assertNotEqual didn't throw with the supplied message.";
		}
		if (!threw) throw "assertNotEqual did not throw with equal objects.";
				
		threw = false;
		try Assert.assertNotEqual(a, {x: 1}, msg) catch (_ : Dynamic) threw = true;
		if (threw) throw "assertNotEqual threw with different objects.";
	}
	
	#end
}