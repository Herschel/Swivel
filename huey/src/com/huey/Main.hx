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

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

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