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
import format.abc.Data;
import format.as1.Data;
import format.swf.Data;
import haxe.ds.IntMap;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.Resource;
import haxe.macro.Expr;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class SwfUtils
{
	macro public static function getAs2Tag(resourceName, ?params) {
		var name = switch(resourceName.expr) {
			case EConst(c):
				switch(c) {
					case CString(s): s;
					default: null;
				}
			default: null;
		}
		haxe.macro.Context.addResource(name, sys.io.File.getBytes('assets/inject_swfs/$name.swf'));
		return macro com.newgrounds.swivel.swf.SwfUtils._getAs2Tag($resourceName, $params);
	}
	
	macro public static function getAs3Tag(resourceName, ?i) {
		var name = switch(resourceName.expr) {
			case EConst(c):
				switch(c) {
					case CString(s): s;
					default: null;
				}
			default: null;
		}
		haxe.macro.Context.addResource(name, sys.io.File.getBytes('assets/inject_swfs/$name.swf'));
		return macro com.newgrounds.swivel.swf.SwfUtils._getAs3Tag($resourceName, $i);
	}
	
	macro public static function getClip(resourceName, clipName) {
		var name = switch(resourceName.expr) {
			case EConst(c):
				switch(c) {
					case CString(s): s;
					default: null;
				}
			default: null;
		}
		haxe.macro.Context.addResource(name, sys.io.File.getBytes('assets/inject_swfs/$name.swf'));
		return macro com.newgrounds.swivel.swf.SwfUtils._getClip($resourceName, $clipName);
	}
	
	#if !macro
	private static function getSwf(resourceName : String) : SWF {
		var bytes = Resource.getBytes(resourceName);
		if(bytes == null) throw("Could not find resource " + resourceName);
		var i = new BytesInput(bytes);
		var swf = new format.swf.Reader(i).read();
		return swf;
	}
	
	public static function _getAs2Tag(resourceName, ?params : Null<Dynamic>) : SWFTag {
		var swf = getSwf(resourceName);
		for(tag in swf.tags) {
			switch(tag) {
				case TDoActions(data):
					if(params != null) {
						var i = new BytesInput(data);
						var as1 = new format.as1.Reader(i).read();

						for(key in Reflect.fields(params)) {
							as1 = [
								APush( [PString("_global")] ),
								AEval,
								APush( [PString("$"+key), PFloat( Reflect.field(params, key) )] ),
								AObjSet,
							].concat(as1);
						}
					
						var o = new BytesOutput();
						new format.as1.Writer(o).write(as1);
						return TDoActions(o.getBytes());
					} else return tag;
					
				default:
			}
		}
		
		throw("AS2 Data not found in " + resourceName);
	}
	
	public static function _getClip(resourceName : String, clipName : String) : SWFTag {
		var swf = getSwf(resourceName);
		var clips = new IntMap<SWFTag>();
		
		for(tag in swf.tags) {
			switch(tag) {
				case TClip(id, frames, tags):
					clips.set(id, tag);
					
				case TExport(links):
					for(link in links)
						if(link.name == clipName)
							return clips.get(link.cid);
							
				default:
			}
		}
		
		return null;
	}
	
	public static function _getAs3Tag(resourceName : String, ?i : Int = 0)  {
		var swf = getSwf(resourceName);
		for(tag in swf.tags) {
			switch(tag) {
				case TActionScript3(data, _):
					if(i > 0) {
						i--;
						continue;
					}
					
					var reader = new format.abc.Reader(new BytesInput(data));
					
					return {tag: tag, abc: reader.read()};
				default:
			}
		}
		
		throw("AS3 Data not found in " + resourceName);
		return null;
	}
	#end
	/*public function mutateAs3(tag : SWFTag, f : ABCData -> Void) : SWFTag {
		switch(tag) {
			case TActionScript3(data):
				var abc = new format.abc.Reader( new BytesInput(data) ).read();
				f(abc);
				var o = new BytesOutput();
				new format.abc.Writer(o).write(abc);
				return TActionScript3(o.getBytes());
			
		default:
			throw("Not an AS3 tag");
		}
	}*/
}