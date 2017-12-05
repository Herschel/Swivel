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
import haxe.Stack;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AsyncTestCase implements ITest
{
	public var onTestComplete(default, null) : Dispatcher<TestStatus>;
	
	public var name(default, null) : String;
	
	private var _testMethod : AsyncTestCase -> Void;
	private var _timer : haxe.Timer;
	
	public function new(name : String, testMethod : AsyncTestCase -> Void, ?timeout : Int = 1000)
	{
		this.name = name;
		_testMethod = testMethod;
		onTestComplete = new Dispatcher();
		_timer = new haxe.Timer(timeout);
	}
	
	public function accept(visitor : ITestVisitor) : Void
	{
		visitor.visitAsyncTestCase(this);
	}
	
	public function run() : TestStatus {
		_timer.run = timeout;
		try {
			_testMethod(this);
		} catch (error : Dynamic) {
			_timer.stop();
			if (error != TestStatus.passed)
				onTestComplete.dispatch(TestStatus.failed(error, Stack.exceptionStack()));
			else
				onTestComplete.dispatch(TestStatus.passed);
		}
		
		return null;
	}
	
	public function wrapAsync(f : Void -> Void) : Void -> Void {
		return function() {
			try {
				f();
			} catch (error : Dynamic) {
				_timer.stop();
				if (error != TestStatus.passed)
					onTestComplete.dispatch(TestStatus.failed(error, Stack.exceptionStack()));
				else
					onTestComplete.dispatch(TestStatus.passed);
			}
		}
	}
	
	private function timeout() : Void {
		onTestComplete.dispatch(TestStatus.failed("Timed out", Stack.callStack()));
		_timer.stop();
	}
}