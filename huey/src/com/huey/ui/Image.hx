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