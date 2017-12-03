package com.huey.assets;
import com.huey.tests.TestSuite;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AssetTests extends TestSuite
{
	@test public function testAsset() : Void {
		var asset : Asset = new Asset("myAsset", Internal("Foo"));
	}
	
	@test public function testAssetManager() : Void {
		var assetManager : AssetManager = new AssetManager();
		assetManager.registerAsset( new Asset("myAsset", Internal("Foo")) );
	}
	
	/** Tests AssetSource. */
	@test public function testInternalAssetSource() {
		var asset : AssetSource;
		asset = Internal("Foo");
	}
	
	@test public function testExternalAssetSource() {
		var asset : AssetSource;
		asset = External("Foo");
	}
}