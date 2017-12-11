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

package com.newgrounds.swivel.swf;
import com.huey.events.Dispatcher;
import com.newgrounds.swivel.audio.AudioTracker;
import flash.net.LocalConnection;
import flash.net.SharedObject;
import haxe.Int32;

interface ISwivelConnection {
	public var client(get, set) : Dynamic;
	public function tick() : Void;
	public function close() : Void;
 }

class SwivelConnection implements ISwivelConnection
{
	public static inline var CONNECTION_NAME : String = "__swivel";
	
	private var _inConnection : LocalConnection;
	
	public var client(get, set) : Dynamic;
	private function get_client() : Dynamic				{ return _inConnection.client; }
	private function set_client(v : Dynamic) : Dynamic	{ return _inConnection.client = v; }

	public function new() {
		_inConnection = new LocalConnection();
		// TODO: output better error msg here
		_inConnection.addEventListener(flash.events.AsyncErrorEvent.ASYNC_ERROR,
			function(e) {}
		);
		_inConnection.connect(CONNECTION_NAME);
	}
	
	public function tick() : Void {
		
	}
	
	public function close() : Void {
		try { _inConnection.close(); }
		catch(_ : Dynamic) { }
	}
}