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

package com.huey.ui;
import com.huey.assets.Asset;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Image extends Component {
	public function new(source : Asset) {
		_implImage = if(source != null) source.data else null;
		super(new flash.display.Bitmap(_implImage, flash.display.PixelSnapping.AUTO, true));
	}
	
	private var _implImage : flash.display.BitmapData;
}