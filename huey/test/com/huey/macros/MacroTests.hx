package com.huey.macros;
import com.huey.tests.TestSuite;
import haxe.macro.Expr;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class MacroTests extends TestSuite
{
	private var _builder : ClassBuilder;
	
	override public function setUp() {
		_builder = new ClassBuilder();
		
		var pos : Position = { min: 0, max: 1, file: "Test.hx" };
		
		var field = new FieldInfo("field1");
		field.addMeta("meta1");
		
		_builder.addField( field );
	}
	
	@test private function testMetaHelpers() : Void {
		assertNotNull( _builder.getField("foo") );
		
		var fields = _builder.getFieldsWithMeta("meta1");
		assertEqual(1, fields.length);
		assertEqual(fields[0].name, "foo");
	}
	
	@test private function testForward() : Void {
		var obj = new BuildTest();
		assertEqual(obj.x, 1, "Property forwarding getter failed.");
		obj.x = 2;
		assertEqual(obj.sub.x, 2, "Property forwarding setter failed.");
		
		assertEqual(obj.y, 1, "Property forwarding getter failed.");
		obj.y = 2;
		assertEqual(obj.sub.x, 2, "Property forwarding setter failed.");
	}
	
	
	/*@test private function testInjectMethod() : Void {
		var test = new BuildTest2();
		assertEqual(1, test.x, "Method injection failed.");
		test.foo();
		assertEqual(2, test.x, "Method injection failed.");
	}*/

}


@:build(com.huey.macros.Macros.build())
private class BuildTest
{
	public var sub : Subcomponent;
	public var sub2 : Subcomponent;
	
	@forward(sub) public var x : Int;
	@forward(sub2.x) public var y : Int;
	
	public function new() {
		sub = new Subcomponent();
		sub2 = new Subcomponent();
	}
}

private class Subcomponent
{
	public var x : Int = 1;
	
	public function new() { }
}