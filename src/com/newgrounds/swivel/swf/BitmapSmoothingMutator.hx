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
			case TShape(id, SHDShape1(_, data)) |
				TShape(id, SHDShape2(_, data)) |
				TShape(id, SHDShape3(_, data)):
				setSmoothInStyles( data.fillStyles );
				
				for(sr in data.shapeRecords) {
					switch(sr) {
						case SHRChange((change)):
							if((change).newStyles != null) setSmoothInStyles( change.newStyles.fillStyles );

						default:
					}
				}
				
			case TShape(id, SHDShape4(data)):
				setSmoothInStyles( data.shapes.fillStyles );
				
				for(sr in data.shapes.shapeRecords) {
					switch(sr) {
						case SHRChange(change):
							if(change.newStyles != null) setSmoothInStyles( change.newStyles.fillStyles );

						default:
					}
				}
				
			default:
		}

		return tag;
	}
	
}