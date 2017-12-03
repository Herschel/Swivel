package com.newgrounds.swivel.swf;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

import format.swf.Data;

class BitmapSmoothingMutator implements ISWFMutator
{

	public function new()
	{
		
	}
	
	public function mutate(swf : SwivelSwf) {
		swf.mapTags( forceBitmapSmoothing );
	}
	
	private function setSmoothInStyles( fillStyles : Array<FillStyle> ) {
		for(i in 0...fillStyles.length) {
			switch(fillStyles[i]) {
				case FSBitmap(id, matrix, smooth, repeat):
					if(smooth == false)
						fillStyles[i] = FSBitmap(id, matrix, true, repeat);

				default:
			}
		}
	}

	private function forceBitmapSmoothing( tag : SWFTag ) : SWFTag {
		switch(tag) {
			case TShape(shape):
				setSmoothInStyles( shape.styles.fillStyles );
				
				for(sr in shape.shapeRecords) {
					switch(sr) {
						case SRStyleChange(s):
							if(s.newStyles != null) setSmoothInStyles( s.newStyles.fillStyles );

						default:
					}
				}
				
			default:
		}

		return tag;
	}
	
}