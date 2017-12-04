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