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
import format.abc.Context;
import format.abc.Data;
import format.swf.Data;
import format.as1.Data;
import haxe.Int32;

using com.newgrounds.swivel.swf.AbcUtils;

class SwivelMutator implements ISWFMutator
{
	
	public function new(?startFrame : Int = 0) {
		_startFrame = startFrame;
		
	}
	
	public function mutate(swf : SwivelSwf) : Void {
		swf.compression = SCUncompressed;

		// Set our SWF version is at least version 6 so that our various AS will work
		// (maybe this could break some things, since AS2 is case-sensitive, but AS1 isn't?)
		if (swf.version < 6) swf.version = 6;

		if(Type.enumEq(swf.avmVersion, AVM1)) {
			swf.prepend(SwfUtils.getAs2Tag("AS2Basics", {width: swf.width, height: swf.height, frameRate: swf.frameRate}));
			
			var clip = SwfUtils.getClip("AS2Basics", "__FrameCounter");

			var clipDepth = 9999;
			switch(clip) {
				case TClip(_, frames, tags): clip = TClip(clipDepth, frames, tags);
				default: throw("Bad clip");
			}
			

			swf.prepend(clip);
			
			var po = new PlaceObject();
			po.cid = clipDepth;
			swf.prepend( TPlaceObject2(po) );
			var i=0;
			//swf.prepend(TDoActions( SwivelSwf.getAvm1Bytes([AGotoFrame(_startFrame), APlay])));
			var f = 0;
			while(i < swf.tags.length) {
				switch(swf.tags[i]) {
					case TUnknown(id, _):
						// get rid of debug tags... causing super weird problems in AS2 movies
						if(id == 63 || id == 64) {
							swf.tags.splice(i,1);
							i--;
						}
					case TShowFrame:
						if(_startFrame == 0) break;
						
						if(f==0) {
							swf.tags.insert(i, TDoActions( SwivelSwf.getAvm1Bytes([AGotoFrame(_startFrame), APlay])) );
							i++;
						} else if(f==_startFrame) {
							swf.tags.insert(i, TDoActions( SwivelSwf.getAvm1Bytes([APlay])) );
							break;
						}
						f++;
					default:
				}
				i++;
			}
		} else {
			for(i in 0...swf.tags.length) {
				var tag = swf.tags[i];
				switch(tag) {
					case TActionScript3(data, c):
						var abc = new format.abc.Reader(new haxe.io.BytesInput(data)).read();
						
						var altered = false;
						for(j in 0...abc.strings.length) {
							var str = abc.strings[j];
							if(str == "exactFit" || str == "noBorder" || str == "showAll") {
								abc.strings[j] = "noScale";
								altered = true;
							} else if(str == "EXACT_FIT" || str == "NO_BORDER" || str == "SHOW_ALL") {
								abc.strings[j] = "NO_SCALE";
								altered = true;
							}
						}
						
						if(altered) {
							var o = new haxe.io.BytesOutput();
							new format.abc.Writer(o).write(abc);
							swf.tags[i] = TActionScript3(o.getBytes(), c);
						}

					default:
				}
			}
		
			swf.prepend( SwfUtils.getAs3Tag("AS3Core", 0).tag );
			swf.hoistClip(0, function(abcStuff) {
				var abc = abcStuff.abc;
				var cl = abcStuff.cl;
				var ctor = abc.getFunction(cl.constructor);
				if(ctor.maxStack < 4) ctor.maxStack = 4;
				if(ctor.maxScope < 4) ctor.maxScope = 4;

				
				/*if(_startFrame != 0) {
					ctor.appendOps([
						OThis,
						OInt(_startFrame),
						OCallPropVoid( abc.publicName("gotoAndPlay"), 1),
						ORetVoid,
					]);
				}*/
				
				ctor.prependOps([
					OGetLex( abc.publicName("__Swivel") ),
					OThis,
					OInt( _startFrame+1 ),
					OCallPropVoid( abc.publicName("registerDocument"), 2)
				]);

				abc.quickMethod(cl, abc.publicName("stage"), [
					OGetLex( abc.publicName("__Swivel") ),
					OGetProp( abc.publicName("stage") ),
					ORet,
				], KGetter, null, abc.type("flash.display.Stage"), true);
			});
			
			return;
		}
	}

	private var _startFrame : Int;
}