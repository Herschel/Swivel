package com.newgrounds.swivel.swf;

/**
 * FilterMutator scales all filters to match the video size
 * @author Newgrounds.com, Inc.
 */

import format.swf.Data;
import haxe.ds.IntMap;
using com.newgrounds.swivel.swf.AbcUtils;

class ScaleFilterMutator implements ISWFMutator
{
	public function new(scale : Float) {
		this.scale = scale;
	}

	public var scale : Float;
	private var _filteredClips : IntMap<Float>;
	private var _maskClips : IntMap<Bool>;
	private var _isAS3 : Bool;
	
	public function mutate(swf : SwivelSwf) {
		_isAS3 = switch(swf.avmVersion) {
			case AVM1:	false;
			case AVM2:
				_filteredClips = new IntMap();
				_maskClips = new IntMap();
				true;
		}
		
		swf.mapClips( tweakFilters );

		if(_isAS3) {
			for (id in _filteredClips.keys()) {
				if (_maskClips.get(id)) continue;
				swf.hoistClip(id, function(abcStuff) {
					var abc = abcStuff.abc;
					var cl = abcStuff.cl;
					var ctor = abc.getFunction(cl.constructor);
					if(ctor.maxStack < 4) ctor.maxStack = 4;
					if(ctor.maxScope < 4) ctor.maxScope = 4;
				
					ctor.prependOps([
						OGetLex( abc.publicName("__Swivel") ),
						OThis,
						OFloat( abc.float( _filteredClips.get(id) ) ),
						OCallPropVoid( abc.publicName("setMask"), 2 )
					]);
				} );
			}
		}
	}
	
	private function tweakFilters(id : Int, tags : Array<SWFTag>) : Array<SWFTag> {
		var curClips = new IntMap<Int>();
		
		for(i in 0...tags.length) {
			var tag = tags[i];
			switch(tag) {
				case TPlaceObject2(po):
					if (po.cid != null) curClips.set(po.depth, po.cid);
					if (po.clipDepth != null) _maskClips.set(po.cid, true);
					
				case TPlaceObject3(po):
					if (po.cid != null) curClips.set(po.depth, po.cid);
					if (po.clipDepth != null) _maskClips.set(po.cid, true);
					
					if (po.filters != null || po.bitmapCache != null) {
						var margin = 0.0;
						
						if(po.filters != null) {
							for (filter in po.filters) {
								switch (filter) {
									case FBlur(data):
										data.blurX = Std.int(data.blurX * scale);
										data.blurY = Std.int(data.blurY * scale);
										//data.passes = 3;
										margin = Math.max(margin, data.blurX/0x00010000+1);
										margin = Math.max(margin, data.blurY/0x00010000+1);
										
									case FGradientGlow(data), FGradientBevel(data):
										data.data.blurX = Std.int(data.data.blurX * scale);
										data.data.blurY = Std.int(data.data.blurY * scale);
										data.data.distance = Std.int(data.data.distance * scale);
										//data.data.flags.passes = 3;
										var dist = Math.abs(data.data.distance/0x00010000) + 1;
										margin = Math.max(margin, data.data.blurX + dist);
										margin = Math.max(margin, data.data.blurY + dist);
										
									case FDropShadow(data), FGlow(data), FBevel(data):
										data.blurX = Std.int(data.blurX * scale);
										data.blurY = Std.int(data.blurY * scale);
										data.distance = Std.int(data.distance * scale);
										//data.strength = Std.int(data.strength * scale);
										//data.flags.passes = 3;
										var dist = Math.abs(data.distance/0x00010000) + 1;
										margin = Math.max(margin, data.blurX/0x00010000 + dist);
										margin = Math.max(margin, data.blurY/0x00010000 + dist);
										
									default:
								}
							}
						}
						
						if(_isAS3) {
							_filteredClips.set(curClips.get(po.depth), margin);
						} else {
							if(po.events == null) po.events = new Array();
							po.events.push( {
								eventsFlags: 1,
								data: com.newgrounds.swivel.swf.SwivelSwf.getAvm1Bytes([
									APush( [PFloat(margin), PString("this")] ),
									AEval,
									APush( [PInt(2), PString("__createMask")] ),
									ACall,
									APop,
								]),
							} );
						}
					}
					
				default:
			}
		}
		
		return tags;
	}
}