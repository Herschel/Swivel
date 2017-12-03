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