package com.huey.ui;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

@:macro class UIMacros
{

	public static function buildComponent() : Array<Field> {
		var cl : ClassType = Context.getLocalClass();
		var fields : Array<Field> = Context.getBuildFields();
	}
	
}