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
import com.newgrounds.swivel.swf.SwivelConnection.ISwivelConnection;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AS3SwivelConnection implements ISwivelConnection
{
	private static var _instance : AS3SwivelConnection;
	
	private var _client : Dynamic;
	public var client(get,set) : Dynamic;
	private function get_client() : Dynamic				{ return _client; }
	private function set_client(v : Dynamic ) : Dynamic	{ return _client = v; }
	
	public function new() {
		_instance = this;
	}
	
	public static function receiveMessage(args : Array<Dynamic>) {
		try {
			if(_instance != null && _instance.client != null) {
				var methodName = args.shift();
				var method : Dynamic = Reflect.getProperty(_instance.client, methodName);
				if(args.length == 0) method();
				else if(args.length == 1) method(args[0]);
				else if(args.length == 2) method(args[0],args[1]);
				else if(args.length == 3) method(args[0],args[1],args[2]);
				else if(args.length == 4) method(args[0],args[1],args[2],args[3]);
				else if(args.length == 5) method(args[0],args[1],args[2],args[3],args[4]);
				else if(args.length == 6) method(args[0],args[1],args[2],args[3],args[4],args[5]);
				else if(args.length == 7) method(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
				
				//Reflect.callMethod(_instance.client, args.shift(), args);
			}
		} catch(e:Dynamic) {  }
	}
	
	public function tick() {
		
	}
	
	public function close() {
		client = null;
	}
}