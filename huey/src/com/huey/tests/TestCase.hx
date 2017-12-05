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
import haxe.Stack;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class TestCase implements ITest
{
	public var name(default, null) : String;
	
	private var _testMethod : Void -> Void;
	
	public function new(name : String, testMethod : Void -> Void)
	{
		this.name = name;
		_testMethod = testMethod;
	}
	
	public function accept(visitor : ITestVisitor) : Void
	{
		visitor.visitTestCase(this);
	}
	
	public function run() : TestStatus {
		try {
			_testMethod();
		} catch (error : Dynamic) {
			if (error != TestStatus.passed) return TestStatus.failed(error, Stack.exceptionStack());
		}
		
		return TestStatus.passed;
	}
}