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

package com.huey.tests;
import com.huey.events.Dispatcher;
import com.huey.utils.Assert;
import haxe.macro.Expr;
import haxe.Stack;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

/**
 * TestSuite groups test cases together.
 */
@:autoBuild(com.huey.tests.TestBuilder.buildTestSuite())
class TestSuite implements ITest {
	
	public var name(default, null)		: String;
	
	private var _tests					: List<ITest>;

	public function new() {
		name = Type.getClassName( Type.getClass(this) );
		_tests = new List<ITest>();
	}
		
	public function add(test : ITest) : Void {
		_tests.add(test);
	}
		
	public function accept(visitor : ITestVisitor) : Void {
		visitor.preVisitTestSuite(this);
			
		for (test in _tests)
			test.accept(visitor);
		
		visitor.postVisitTestSuite(this);
	}

	public function iterator() : Iterator<ITest> {
		return _tests.iterator();
	}
	
	public function setUp() : Void {
		
	}

	public function tearDown() : Void {
		
	}
	
	inline private function assertNull<T>(v : T, ?message : String) : Void {
		Assert.assertNull(v, message);
	}
	
	inline private function assertNotNull<T>(v : T, ?message : String) : Void {
		Assert.assertNotNull(v, message);
	}
	
	inline private function assertTrue(b : Bool, ?message : String) : Void {
		Assert.assertTrue(b, message);
	}
	
	inline private function assertFalse(b : Bool, ?message : String) : Void {
		Assert.assertFalse(b, message);
	}
	
	inline private function assertEqual<T>(expected : T, actual : T, ?message : String) : Void {
		Assert.assertEqual(expected, actual, message);
	}
	
	inline private function assertNotEqual<T>(unexpected : T, actual : T, ?message : String = "") : Void {
		Assert.assertNotEqual(unexpected, actual, message);
	}
	
	private function pass() : Void {
		throw TestStatus.passed;
	}
	
	private function fail(error : Dynamic) : Void {
		throw error;
	}
}