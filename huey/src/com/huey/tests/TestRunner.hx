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

class TestRunner implements ITestVisitor
{
	public var numTestsRun(default, null)		: Int;
	public var numTestsPassed(default, null)	: Int;
	public var numTestsFailed(default, null)	: Int;
	public var numSuitesRun(default, null)		: Int;
	
	private var _asyncAdapter : AsyncTestVisitor;
	private var _waiting : Bool;
	
	public function new() {
		numTestsRun = numTestsPassed = numTestsFailed = numSuitesRun = 0;
		_asyncAdapter = new AsyncTestVisitor(this);
		_waiting = false;
	}
	
	public function run(test : ITest) : Void {
		test.accept(_asyncAdapter);
		runLoop();
	}
	
	private function runLoop() : Void {
		_waiting = false;
		while (_asyncAdapter.hasNext()) {
			if (_waiting) return;
			_asyncAdapter.visitNext();
		}
			
		complete();
	}
	
	public function preVisitTestSuite(suite : TestSuite) : Void {
		log(Std.format("Running test suite ${suite.name}..."));
		numSuitesRun++;
		
		suite.setUp();
	}
	
	public function postVisitTestSuite(suite : TestSuite) : Void {
		suite.tearDown();
		
		log(Std.format("Finished test suite ${suite.name}."));
	}
	
	public function visitTestCase(test : TestCase) : Void {
		log(Std.format("Running test ${test.name}..."));
		numTestsRun++;
					
		switch(test.run()) {
			case passed:
				log("Passed!");
				numTestsPassed++;
				
			case failed(message, stack):
				log(Std.format("Failed! $message\n$stack"));
				//_failedTests.add(test);
				numTestsFailed++;
				
			default:
		}
	}
	
	public function visitAsyncTestCase(test : AsyncTestCase) : Void {
		log(Std.format("Running test ${test.name}..."));
		numTestsRun++;
		test.onTestComplete.add(onAsyncTestCompleted);
		test.run();
		
		_waiting = true;
	}
	
	private function onAsyncTestCompleted(status : TestStatus) : Void {
		switch(status) {
			case passed:
				log("Passed!");
				numTestsPassed++;
				
			case failed(message, stack):
				log(Std.format("Failed! $message\n$stack"));
				//_failedTests.add(test);
				numTestsFailed++;
				
			default:
		}
		
		runLoop();
	}
	
	
	private function complete() : Void {
		log("Testing complete.");
		log(Std.format("$numTestsPassed / $numTestsRun tests passed."));
		log(Std.format("$numTestsFailed / $numTestsRun tests failed."));
	}
	
	public dynamic function log(message : String) : Void {
		trace(message);
	}
}