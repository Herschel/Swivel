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