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