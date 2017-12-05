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

package com.huey.utils;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import haxe.ds.StringMap;
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
	
	private static var loggers : StringMap<Logger> = new StringMap();
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