package com.newgrounds.swivel.swf;
import com.huey.events.Dispatcher;
import com.newgrounds.swivel.audio.AudioTracker;
import flash.net.LocalConnection;
import flash.net.SharedObject;
import haxe.Int32;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

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