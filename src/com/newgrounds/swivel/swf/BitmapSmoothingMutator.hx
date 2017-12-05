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