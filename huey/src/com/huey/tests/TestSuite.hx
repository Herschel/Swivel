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