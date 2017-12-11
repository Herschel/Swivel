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
import com.huey.events.Dispatcher;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

class Asset
{
	public var name(default, null) : String;
	public var source(default, null) : AssetSource;
	
	public var data(default, null) : Dynamic;
	
	public var onLoaded(default, null) : Dispatcher<Dynamic>;
	
	private var _loader : Loader;
	
	public function new(name : String, source : AssetSource) {
		this.name = name;
		this.source = source;
		
		onLoaded = new Dispatcher();
	}
	
	public function load() : Void {
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		switch(source) {
			case Internal(id):
				_loader.loadBytes(haxe.Resource.getBytes(id).getData());
				
			case External(url):
				_loader.load(new URLRequest(url));
		}
	}
	
	private function onLoadComplete(event : Event): Void {
		data = cast(_loader.content, Bitmap).bitmapData;
		_loader = null;
		
		onLoaded.dispatch();
	}
	
	private function ioErrorHandler(_) {
		
	}
	
}