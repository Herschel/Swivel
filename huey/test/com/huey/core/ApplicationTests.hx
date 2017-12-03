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