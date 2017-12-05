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

package com.huey.ui;
import com.huey.tests.TestSuite;
import com.huey.ui.Component;
import com.huey.ui.UIContainer;
import com.huey.ui.UIFactory;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class UITests extends TestSuite
{
	private var _factory : UIFactory;
	
	override public function setUp() {
		_factory = new UIFactory();
	}
	
	/** Tests Component instantiation and interface. */
	public function testComponentDefaults(component : Component) {
		assertNull(component.parent, "Parent should be null on instantiation.");
		assertTrue(component.visible, "Component should default to visible.");
		assertEqual(0.0, component.x, "Position should default to (0, 0).");
		assertEqual(0.0, component.y, "Position should default to (0, 0).");
		assertEqual(0.0, component.depth, "Depth should default to 0.");
	}
	
	/** Tests UIContainer instantiation and add/remove children. */
	@test public function testUIContainer() {
		var parent : UIContainer = _factory.createContainer();
		testComponentDefaults(parent);
		
		var child : Component = _factory.createContainer();
		testComponentDefaults(child);
		
		assertEqual(0, parent.numChildren, "Parent should start with no children.");
		parent.add(child);
		assertEqual(1, parent.numChildren, "numChildren did not update after add.");
		assertEqual(parent, child.parent, "Child's parent was not updated after add.");
		
		var removed = parent.remove(child);
		assertTrue(removed, "Child was not successfully removed.");
		assertEqual(0, parent.numChildren, "numChildren did not update after remove.");
	}
	
	/** Tests Label control instantiation and properties. */
	@test public function testLabel() {
		var label = _factory.createLabel();
		assertEqual("", label.text, "Label text should default to ''.");
	}
	
	/** Tests Image control instantiation and properties. */
	@test public function testImage() {
		var button = _factory.createImage();
	}
}