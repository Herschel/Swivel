package com.huey.tests;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

interface ITest
{
	var name(default, null)	: String;
	function accept(visitor : ITestVisitor) : Void;
}