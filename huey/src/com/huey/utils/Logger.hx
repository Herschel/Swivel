package com.huey.utils;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import haxe.macro.Expr;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Logger {
	inline public static function log(name : String, msg : String) {
		Logger.getInstance(name).logMessage(msg);
	}
	
	inline public static function getLog(name : String) : String {
		return Logger.getInstance(name).get();
	}
	
	private static var loggers : Hash<Logger> = new Hash();
	inline public static function getInstance(name : String) {
		var logger = loggers.get(name);
		if(logger == null) {
			logger = new Logger(name, File.applicationStorageDirectory.resolvePath('$name.txt').nativePath);
			loggers.set(name, logger);
		}
		return logger;
	}
	
	private var name : String;
	private var logFile : File;
	private var outputStream : FileStream;
	
	private function new(name : String, outputFile : String) {
		this.name = name;
		logFile = new File(outputFile);
		
		try {
			if(logFile.exists) logFile.deleteFile();
			outputStream = new FileStream();
			outputStream.open(logFile, FileMode.UPDATE);
		} catch(_ : Dynamic) {
			outputStream = null;
		}
	}
	
	public function logMessage(msg : String) {
		#if debug
			trace('$msg');
		#end
		if(outputStream != null) {
			try outputStream.writeUTFBytes(msg) catch(_ : Dynamic) {}
		}
	}
	
	public function get() : String {
		//var inputStream = new FileStream();
		try {
			//inputStream.open(logFile, FileMode.READ);
			outputStream.position = 0;
			var data = outputStream.readUTFBytes(outputStream.bytesAvailable);
			//inputStream.close();
			return data;
		} catch(_ : Dynamic) return "";
	}
	
}