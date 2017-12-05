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
import format.swf.Reader;
import format.swf.Writer;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using com.newgrounds.swivel.swf.AbcUtils;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

typedef ABCStuff = {abc : ABCData, cl : ClassDef, tagIndex : Int, extra : AS3Context};

class SwivelSwf {
	public static function getAvm1Bytes( actions : AS1 ) : Bytes {
		var o = new BytesOutput();
		var writer = new format.as1.Writer(o);
		writer.write(actions);
		return o.getBytes();
	}

	public var version(get_version, set_version) : Int;
	inline private function get_version()					{ return _header.version; }
	inline private function set_version(v)					{ return _header.version = v; }
	
	public var avmVersion(default, set_avmVersion) : AVM;
	private function set_avmVersion(v) {
		if(version < 8 || _fileAttributesIndex < 0) {
			return avmVersion = v;
		}
		
		if(version < 9 && Type.enumEq(v, AVM2)) throw("AVM2 requires SWF version 9 or higher");
		
		// MIKNEW
		_headerTags[_fileAttributesIndex] = switch(_headerTags[_fileAttributesIndex]) {
			case TSandBox(useDirectBlit, useGpu, hasMeta, useAs3, useNetwork):
				TSandBox(useDirectBlit, useGpu, hasMeta, v == AVM2, useNetwork);
			default: throw("Unexpected tag");
		}
		
		return avmVersion = v;
	}
	
	public var abcData(default, null) : ABCData;

	public var compression(get, set) : SWFCompression;
	inline private function get_compression()				{ return _header.compression; }
	inline private function set_compression(v)				{ return _header.compression = v; }
	
	public var width(get, set) : Int;
	inline private function get_width()						{ return _header.width; }
	inline private function set_width(v)	 				{ return _header.width = v; }
	
	public var height(get, set) : Int;
	inline private function get_height()					{ return _header.height; }
	inline private function set_height(v)					{ return _header.height = v; }
	
	public var frameRate(get, set) : Float;
	inline private function get_frameRate()					{ return _header.fps / 256.0; }
	inline private function set_frameRate(v : Float)				{ _header.fps = Std.int(v * 256.0); return v;  }
	
	@:isVar public var backgroundColor(get, set) : Int;
	inline private function get_backgroundColor()			{ return backgroundColor; }
	inline private function set_backgroundColor(v)			{ return backgroundColor = v; }
	
	@bindable public var numFrames(default, set) : Int;
	inline private function set_numFrames(v)				{ return numFrames = _header.nframes = v; }
	
	private var _header : SWFHeader;
	private var _data: Bytes;
	private var _headerTags : Array<SWFTag>;
	public var tags : Array<SWFTag>;
	private var _parsed : Bool = false;

	private var _startIndex : Int;	// index after SetBackground tag
	private var _fileAttributesIndex :  Int = -1;

	public function new(data : Bytes) {
		var partialSwf = new SwivelSwfReader( new BytesInput(data) ).readPartial();
		_header = partialSwf.header;
		numFrames = _header.nframes;
		_headerTags = partialSwf.tags;
		tags = [];
		_data = partialSwf.data;

		avmVersion = AVM1;
		var i = 0;
		for (t in _headerTags) {
			switch(t) {
				case TSandBox(_, _, _, useAs3, _): // MIKENEW
					_fileAttributesIndex = i;
					avmVersion = if(useAs3) AVM2 else AVM1;

				case TBackgroundColor(color):
					backgroundColor = color;
					
				default:
			}
			i++;
		}
		_startIndex = 0;
	}
	
	public function parseSwf() {
		var reader = new SwivelSwfReader( new BytesInput(_data) );
		untyped reader.version = _header.version;
		var newTags = reader.readTagList();
		_startIndex = _headerTags.length;
		tags = _headerTags.concat(newTags);
		_parsed = true;
	}
	
	private var _clipNum : Int = 0;
	
	public function hoistClip(clipId : Int, f : ABCStuff -> Void) {
		var clipIndex = 0;
		var i = 0;
		for(tag in tags) {
			switch(tag) {
				case TSymbolClass(links):
					for(link in links) {
						if(link.cid == clipId) {
							var clipStuff = getAbcWithClass(link.className);
							var clipAbc = clipStuff.abc;
							f(clipStuff);

							var o = new BytesOutput();
							new format.abc.Writer(o).write(clipAbc);
							tags[clipStuff.tagIndex] = TActionScript3(o.getBytes(), clipStuff.extra);
							return;
						}
					}
					
				case TClip(id,_,_):
					if(clipId == id)
						clipIndex = i+1;
					
				default:
			}
			
			i++;
		}
		
		var ctx = new format.abc.Context();
		var className = '__SwivelClip$_clipNum';
		var cl = ctx.beginClass(className);
		cl.isSealed = false;
		cl.superclass = ctx.type("flash.display.MovieClip");
		_clipNum++;
		ctx.endClass();
		ctx.finalize();
		
		var abc = ctx.getData();
		f({abc:ctx.getData(), cl:abc.classes[0], tagIndex:0, extra:null});
		
		var o = new BytesOutput();
		new format.abc.Writer(o).write(abc);
		var tag = TActionScript3(o.getBytes(), null);
		
		// insert new AS3 tag in proper location
		//prepend(tag);
		if(clipId == 0) {
			clipIndex = _startIndex;
			_startIndex+=2;
		} else if(clipIndex == 0) return;
		
		//tags.insert(clipIndex, TSymbolClass([ {cid: clipId, className: className} ]));
		tags.insert(clipIndex, tag);
		tags.insert(clipIndex+1, TSymbolClass([ {cid: clipId, className: className} ]));
	}
	
	/*public function hoistClip2(clipId : Int, f : ABCStuff -> Void) {
		var newClassName = '__SwivelClip$_clipNum';
		_clipNum++;
		
		var ctx = new format.abc.Context();
		var cl = ctx.beginClass(className);
		cl.isSealed = false;
		cl.superclass = ctx.type("flash.display.MovieClip");
		ctx.endClass();
		ctx.finalize();
		var abc = ctx.getData();
		
		f({abc:ctx.getData(), cl:abc.classes[0], tagIndex:0, extra:null});

		var clipIndex = 0;
		var i = 0;
		for(tag in tags) {
			switch(tag) {
				case TSymbolClass(links):
					for(link in links) {
						if(link.cid == clipId) {
							var clipStuff = getAbcWithClass(link.className);
							var clipAbc = clipStuff.abc;
							cl.superclass = ctx.type(clipStuff.cl.name);
							clipStuff.cl.name = clipAbc.publicName(newClassName);
							
							f(clipStuff);

							var o = new BytesOutput();
							new format.abc.Writer(o).write(clipAbc);
							tags[clipStuff.tagIndex] = TActionScript3(o.getBytes(), clipStuff.extra);
							return;
						}
					}
					
				case TClip(id,_,_):
					if(clipId == id)
						clipIndex = i+1;
					
				default:
			}
			
			i++;
		}
		
		var o = new BytesOutput();
		new format.abc.Writer(o).write(abc);
		var tag = TActionScript3(o.getBytes(), null);
		
		// insert new AS3 tag in proper location
		//prepend(tag);
		if(clipId == 0) {
			clipIndex = _startIndex;
			_startIndex+=2;
		} else if(clipIndex == 0) return;
		
		//tags.insert(clipIndex, TSymbolClass([ {cid: clipId, className: className} ]));
		tags.insert(clipIndex, tag);
		tags.insert(clipIndex+1, TSymbolClass([ {cid: clipId, className: className} ]));
	}*/
	
	private function getAbcWithClass(className : String) : ABCStuff {
		var i = 0;
		for(tag in tags) {
			switch(tag) {
				case TActionScript3(data, extra):
					var abc = new format.abc.Reader(new BytesInput(data)).read();
					for(cl in abc.classes) {
						if(abc.getNamePath(cl.name) == className) {
							return {abc: abc, cl: cl, tagIndex: i, extra: extra};
						}
					}
			
				default:
			}
			i++;
		}
		return null;
	}
	
	public function prepend(tag : SWFTag) : Void {
		tags.insert(_startIndex++, tag);
	}
	
	public function mapTags(f : SWFTag -> SWFTag) : Void {
		tags = _mapTags(f, tags);
	}
	
	private function _mapTags(f : SWFTag -> SWFTag, tags : Array<SWFTag>) : Array<SWFTag> {
		var newTags = new Array();
		for (tag in tags) {
			switch(tag) {
				case TClip(id, frames, tags):
					var t = f(tag);
					if (t != null) {
						if (Type.enumEq(t, tag)) newTags.push( TClip(id, frames, _mapTags(f, tags)) );
						else newTags.push(t);
					}
					
				default:
					var t = f(tag);
					if (t != null) newTags.push(t);
			}
		}
		
		return newTags;
	}
	
	public function mapClips(f : Int -> Array<SWFTag> -> Array<SWFTag>) : Void {
		f(0, tags);
		
		for (tag in tags) {
			switch(tag) {
				case TClip(id, _, tags):
					f(id, tags);
					
				default:
			}
		}
	}
	
	public function getBytes() : Bytes {
		var o = new haxe.io.BytesOutput();
		var writer = new Writer( o );
		if(_parsed) writer.write( {header: _header, tags: tags} );
		else {
			writer.writeHeader(_header);
			for(t in _headerTags)
				writer.writeTag(t);
			for(t in tags)
				writer.writeTag(t);
			untyped writer.o.write(_data);
			writer.writeEnd();
		}
		return o.getBytes();
	}
	
	public function disposeTags() {
		_parsed = false;
		tags = [];
		_startIndex = 0;
	}
	
	public function clone() : SwivelSwf {
		var swf = Type.createEmptyInstance(SwivelSwf);
		swf.tags = [];
		swf._headerTags = _headerTags.copy();
		swf._header = {
			version:	_header.version,
			compression:	_header.compression,
			width:		_header.width,
			height:		_header.height,
			fps:		_header.fps,
			nframes:	_header.nframes,
		}
		swf.backgroundColor = backgroundColor;
		swf._data = _data;
		swf._parsed = false;
		swf._startIndex = _startIndex;
		swf._fileAttributesIndex = _fileAttributesIndex;
		
		return swf;
	}
}

enum AVM
{
	AVM1;
	AVM2;
}