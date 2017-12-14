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
import format.swf.Constants;
import format.swf.Data;
import format.swf.Reader;
import haxe.io.BytesInput;

class SwivelSwfReader extends format.swf.Reader {

	public function new(i : BytesInput) {
		bits = new format.tools.BitsInput(i);
		super(i);
	}
		
	public function readPartial() {
		var header = readHeader();
		var tags = new Array();
		while(true) {
			var tag = readTag();
			tags.push(tag);
			switch(tag) {
			case TSandBox(_):
			case TBackgroundColor(_): break;
			default:
			}
		}

		return {header: header, tags: tags, data: i.readAll() };
	}

	// TODO: repeated from SWFReader, to not throw on some incorrect-ish SWF files
	// Is there a way we can avoid repeating this?
	/* MIKE TODO 2017: Reintegrate the below, or just change it directly in our format fork.
	override public function readHeader() : SWFHeader {
		var tag = i.readString(3);
		var compression;
		if( tag == "ZWS" )
			compression = SCLZMA;
		else if( tag == "CWS" )
			compression = SCDeflate;
		else if( tag == "FWS" )
			compression = SCUncompressed;
		else
			throw error();
		version = i.readByte();
		var size = readInt();
		
		switch( compression ) {
		case SCLZMA:
			throw "LZMA is unsupported";
		
		case SCDeflate:
			var bytes = format.tools.Inflate.run(i.readAll());
			if( bytes.length + 8 != size ) trace("Compressed data length is incorrect");
			i = new haxe.io.BytesInput(bytes);
			
		case SCUncompressed:
		}
		
		bits = new format.tools.BitsInput(i);
		var r = readRect();
		if( r.left != 0 || r.top != 0 )
			throw error();
		var fps = readFixed8();
		var nframes = i.readUInt16();
		return {
			version : version,
			compression : compression,
			width : Std.int(r.right/20),
			height : Std.int(r.bottom/20),
			fps : fps,
			nframes : nframes,
		};
	}
	
	override private function readTagData(id,len) : SWFTag {
		var startPos = untyped i.b.position;

		var tag = super.readTagData(id, len);

		// Assert here
		var endPos = untyped i.b.position;
		if(len != endPos - startPos) {
			#if debug
			trace("Bad tag!");
			#end
			untyped i.b.position = startPos + len;
		}
		
		return tag;
	}
	*/
}