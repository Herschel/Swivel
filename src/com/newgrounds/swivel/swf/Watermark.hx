package com.newgrounds.swivel.swf;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

typedef Watermark = {
	var image : flash.display.BitmapData;
	var align : WatermarkAlign;
	var alpha : Float;
	var scale : Float;
}

enum WatermarkAlign {
	topLeft;
	topCenter;
	topRight;
	middleLeft;
	center;
	middleRight;
	bottomLeft;
	bottomCenter;
	bottomRight;
}