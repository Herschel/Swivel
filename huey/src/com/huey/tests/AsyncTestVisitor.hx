package com.huey.tests;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AsyncTestVisitor implements ITestVisitor
{
	private var _visitor : ITestVisitor;
	private var _visits : List<Void -> Void>;
	
	public function new(visitor : ITestVisitor)
	{
		_visitor = visitor;
		_visits = new List();
	}

	public function preVisitTestSuite(suite : TestSuite) : Void {
		_visits.add( function() _visitor.preVisitTestSuite(suite) );
	}
	
	public function postVisitTestSuite(suite : TestSuite) : Void {
		_visits.add( function() _visitor.postVisitTestSuite(suite) );
	}
	
	public function visitTestCase(test : TestCase) : Void {
		_visits.add( function() _visitor.visitTestCase(test) );
	}
	
	public function visitAsyncTestCase(test : AsyncTestCase) : Void {
		_visits.add( function() _visitor.visitAsyncTestCase(test) );
	}
	
	public function hasNext() : Bool {
		return !_visits.isEmpty();
	}
	
	public function visitNext() : Void {
		var f = _visits.pop();
		f();
	}
	
}