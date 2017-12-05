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