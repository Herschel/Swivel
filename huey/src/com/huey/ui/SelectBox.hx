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
import com.huey.assets.AssetManager;
import com.huey.events.Dispatcher;
import com.huey.events.Dispatcher;
import com.huey.ui.Image;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class SelectBox extends Container {
	@forward(_listBox) public var items : Array<Dynamic>;
	@forward(_listBox) public var selectedItem : Dynamic;
	@forward(_listBox) public var selectedIndex : Dynamic;
	
	public var onChange(default, null) : Dispatcher<UIEvent>;
	
	public function new() {
		super();
		
		var assetManager = AssetManager.instance;
		_listBoxBg = new Image(assetManager.getAsset("listBoxBigBG"));
		_listBoxBg.visible = false;
		_listBoxBg.y = 22;
		add(_listBoxBg);
		
		_listBox = new ListBox();
		_listBox.visible = false;
		_listBox.y = 22;
		_listBox.onChange.add(listBoxChangeHandler);
		add(_listBox);
		
		_textBoxBg = new Image(assetManager.getAsset("textFieldBig"));
		add(_textBoxBg);
		_textBox = new Label();
		_textBox.width = 312;
		_textBox.x = 8;
		_textBox.y = 1;
		_textBox.font = "AdvoCut_10pt_st";
		_textBox.size = 10;
		_textBox.bold = true;
		_textBox.color = 0x425137;
		add(_textBox);
		
		_showButton = new Button();
		_showButton.upState = new Image(assetManager.getAsset("btnDecUp"));
		_showButton.overState = new Image(assetManager.getAsset("btnDecOver"));
		_showButton.downState = new Image(assetManager.getAsset("btnDecDown"));
		_showButton.x = 309;
		_showButton.hitArea = Rectangle(-309, 0, 329, 25);
		_textBoxBg.onClick.add(showButtonClickHandler);
		_showButton.onClick.add(showButtonClickHandler);
		add(_showButton);
		
		onChange = new Dispatcher();
		_listBox.onChange.add(function(_) onChange.dispatch({source: this}));
	}
	
	private var _textBoxBg : Image;
	private var _textBox : Label;
	private var _listBoxBg : Image;
	private var _listBox : ListBox;
	private var _showButton : Button;

	private function showButtonClickHandler(_) {
		_listBox.visible = !_listBox.visible;
		_listBoxBg.visible = _listBox.visible;
		if(_listBox.visible) {
			flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK, stageClickHandler, false, 0, false);
		} else {
			flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, stageClickHandler);
		}
	}
	
	private function listBoxChangeHandler(_) {
		_listBox.visible = _listBoxBg.visible = false;
		_textBox.text = Std.string(_listBox.selectedItem.label);
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, stageClickHandler);
	}
	
	private function stageClickHandler(_) {
		var c = flash.Lib.current.stage.focus;
		while(c != null) {
			if(c == _implComponent) return;
			c = c.parent;
		}
		
		_listBox.visible = _listBoxBg.visible = false;
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, stageClickHandler);
	}
}