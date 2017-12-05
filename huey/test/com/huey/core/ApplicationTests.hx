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

package com.huey.core;
import com.huey.tests.TestSuite;
import com.huey.core.Application;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class ApplicationTests extends TestSuite
{
	@test private function testApplication() : Void {
		var app : Application = new SimpleApplication();
		
		assertNotNull(app.buildTime);
		assertNotNull(app.ui, "UI should be initialized.");
	}
}

@layout("layout.xml")
private class SimpleApplication extends Application {
	public function new() {
		super();
	}
}