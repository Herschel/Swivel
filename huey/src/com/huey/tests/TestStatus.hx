package com.huey.tests;
import haxe.Stack;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

enum TestStatus
{
	passed;
	failed(message : String, stackTrace : Array<StackItem>);
}