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

package com.huey.binding;
import com.huey.tests.TestSuite;
import com.huey.binding.Binding;


/**
 * Tests the data binding framework.
 * @author Newgrounds.com, Inc.
 */
class BindingTests extends TestSuite
{
	/** Tests binding to a member variable. */
	@test public function testBindingVariable() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bind(b.foo, a.foo);
		a.foo = 10;
		assertEqual(10, b.foo, "Variable change did not propogate.");
	}
	
	/** Tests binding to a property. */
	@test public function testBindingProperty() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bind(b.bar, a.bar);
		a.bar = "blah";
		assertEqual("blah", b.bar, "Property change did not propogate.");
	}
	
	/** Tests binding to a property with a setter. */
	@test public function testBindingPropertySetter() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bind(b.baz, a.baz);
		a.baz = 2.1;
		assertEqual(2.1, b.baz, "Property change with setter did not propogate.");
		assertTrue(b.setterCalled, "Setter was not called on property change.");
	}
	
	/**
	 * Tests two-way binding to a variable.
	 * Watch out for infinite recursions here.
	 */
	@test public function testTwoWayBindingVariable() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bindTwoWay(b.foo, a.foo);
		
		a.foo = 10;
		assertEqual(10, b.foo, "Variable change did not propogate.");

		b.foo = 20;
		assertEqual(20, a.foo, "Variable change did not propogate.");
	}
	
	@test public function textExpressionBinding() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bind(b.foo, a.foo * 2);
		
		a.foo = 2;
		assertEqual(4, b.foo, "Variable change did not propogate");
	}
	
	/** Test deep binding. */
	@test public function testDeepBinding() {
		var a = new BindObject();
		var b = new BindObject();
		Binding.bindTwoWay(b.baz, a.child.x);
		
		a.child.x = -1.0;
		a.child = new BindObject2();
		assertEqual(0.0, b.baz, "Subcomponent variable change did not propogate.");
		a.child.x = 1.0;
		assertEqual(1.0, b.baz, "Subcomponent variable change did not propogate.");
	}

	/** Test bindable arrays. */
	@test public function testBindableArray() {
		var a = new BindObject();
		var b = new BindObject2();
		Binding.bind(b.array, a.array);
		a.array = BindableArray.fromArray([1, 2]);
		assertEqual(1, b.array.array[0]);
		assertEqual(2, b.array.array[1]);
		assertEqual(2, b.array.length);
		assertEqual(3, b.sum);
		
		a.array.push(3);
		assertEqual(3, b.array.array[2]);
		assertEqual(3, b.array.length);
		assertEqual(6, b.sum);
	}
}

private class BindObject extends Binding.Bindable
{
	@bindable public var foo : Int;
	@bindable public var bar(default, default) : String;
	@bindable public var baz(getBaz, setBaz) : Float;
	@bindable public var child : BindObject2;
	@bindable public var array : BindableArray<Int>;
	
	public var setterCalled : Bool;
	
	public function new() {
		super();
		child = new BindObject2();
		setterCalled = false;
	}
	
	private function getBaz()	{ return baz; }
	private function setBaz(x)	{ setterCalled = true;  return baz = x; }
}

private class BindObject2 extends Binding.Bindable
{
	public var array(default, set_array) : BindableArray<Int>;
	private function set_array(v) {
		array = v;
		sum = 0;
		if (array != null)
			for (i in array) sum += i;
		return array;
	}
	
	public function new() {
		super();
		x = 0.0;
	}
	
	@bindable public var x : Float;
	public var sum : Int;
}