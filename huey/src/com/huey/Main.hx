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

package com.huey;

import com.huey.assets.Asset;
import com.huey.assets.AssetManager;
import com.huey.assets.AssetSource;
import com.huey.assets.AssetTests;
import com.huey.binding.BindingTests;
import com.huey.core.Application;
import com.huey.core.ApplicationTests;
import com.huey.ui.Image;
import com.huey.ui.Label;
import com.huey.utils.AssertTests;
import com.huey.events.EventTests;
import com.huey.tests.TestRunner;
import com.huey.tests.TestSuite;
import com.huey.ui.UITests;
import com.huey.macros.MacroTests;
import com.huey.utils.WeakRefTest;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

class Main
{
	
	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		var test : TestSuite = new TestSuite();
		test.add(new AssertTests());
		test.add(new EventTests());
		test.add(new WeakRefTest());
		test.add(new MacroTests());
		test.add(new BindingTests());
		test.add(new UITests());
		test.add(new ApplicationTests());
		test.add(new AssetTests());
		
		var testRunner : TestRunner = new TestRunner();
		testRunner.run(test);
		
		//_app = new TestApplication();
	}
	private static var _app : Application;
}

class TestApplication extends Application {
	public function new() {
		super();
		
		assetManager.registerAsset( new Asset("shadow", External("h:/Swivel/assets/SHADOW.PNG")) );
		assetManager.onAssetsLoaded.add(onAssetsLoaded);
		assetManager.preloadAssets();
	}
	
	public function onAssetsLoaded(e) : Void {
		var label : Label = uiFactory.createLabel();
		label.text = "Foo";
		ui.add(label);
		label.x = 100;
		label.onClick.add(function(e) { trace("FOO"); } );
		
		var image : Image = uiFactory.createImage();
		image.source = assetManager.getAsset("shadow");
		ui.add(image);
	}
}