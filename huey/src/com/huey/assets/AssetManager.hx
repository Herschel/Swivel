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
import com.huey.events.Dispatcher;
import haxe.ds.StringMap;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AssetManager
{
	private static var _instance : AssetManager;
	
	public static var instance(get, null) : AssetManager;
	
	inline private static function get_instance() : AssetManager {
		if (_instance == null) _instance = new AssetManager();
		return _instance;
	}
	
	public var onAssetsLoaded : Dispatcher<Dynamic>;
	
	private var _assets : StringMap<Asset>;
	private var _loaderIterator : Iterator<Asset>;
	
	public function new() {
		_assets = new StringMap();
		onAssetsLoaded = new Dispatcher();
	}
	
	public function preloadAssets() : Void {
		_loaderIterator = _assets.iterator();
		loadNextAsset();
	}
	
	public function registerAsset(asset : Asset) : Void {
		_assets.set(asset.name, asset);
	}
	
	public function getAsset(name : String) : Asset {
		return _assets.get(name);
	}

	private function loadNextAsset() : Void {
		if (_loaderIterator.hasNext()) {
			var asset = _loaderIterator.next();
			asset.onLoaded.add( onAssetLoaded );
			asset.load();
		} else {
			_loaderIterator = null;
			onAssetsLoaded.dispatch();
		}
	}
	
	private function onAssetLoaded(e) : Void {
		loadNextAsset();
	}
}