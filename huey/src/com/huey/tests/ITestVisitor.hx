package com.huey.tests;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

interface ITestVisitor
{
	function preVisitTestSuite(suite : TestSuite) : Void;
	function postVisitTestSuite(suite : TestSuite) : Void;
	function visitTestCase(test : TestCase) : Void;
	function visitAsyncTestCase(test : AsyncTestCase) : Void;
}