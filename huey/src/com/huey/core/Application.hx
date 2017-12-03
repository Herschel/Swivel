package com.huey.core;
import com.huey.assets.*;
import com.huey.ui.*;
import com.huey.utils.Assert;
import com.huey.binding.Binding;
import com.huey.utils.Thread;
/**
 * ...
 * @author Newgrounds.com, Inc.
 */

@:autoBuild(com.huey.core.ApplicationMacros.buildApplication())
class Application extends Binding.Bindable
{
	private var _thread : Thread;

	public var ui(default, null) : StateContainer;
	
	public var assetManager(default, null) : AssetManager;
	
	private var _appXml : haxe.xml.Fast;

	private function new() {
		super();
			
		flash.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(flash.events.UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
		#if !debug
		haxe.Log.trace = function(_, ?_){}
		#end
		
		assetManager = AssetManager.instance;

		ui = new StateContainer();
		
		#if flash9
		// TODO
		untyped { flash.Lib.current.addChild(ui._implComponent); }
		#end

		// XML resource name gets set by macro
		// TODO: pass thru constructor?
		var applicationData = haxe.Resource.getString("applicationData");
		if(applicationData != null) {
			_appXml = new haxe.xml.Fast( Xml.parse(applicationData).firstElement() );
		}

		registerAssets();
		
		assetManager.onAssetsLoaded.add(assetsLoadedHandler);
		assetManager.preloadAssets();
	}
	
	private function registerAssets() : Void {
		
	}

	private function assetsLoadedHandler(e) : Void {
		for(uiData in _appXml.node.ui.elements) {
			var component = readComponent(uiData);
			if (component != null) ui.add( component );
			else {
				if (uiData.name == "state") {
					var stateComps = readUIList(uiData);
					for(comp in stateComps)
						ui.addToState(comp, uiData.att.name);
				}
			}
		}

		#if air
		var win = flash.desktop.NativeApplication.nativeApplication.openedWindows[0];
		if(win != null) {
			win.x = (win.stage.fullScreenWidth - win.width) / 2;
			win.y = (win.stage.fullScreenHeight - win.height) / 2;
			
			win.addEventListener(flash.events.Event.CLOSE, function(_) exit());
		}
		#end
		
		init();
	}
	
	private function readUIList(data : haxe.xml.Fast) : Array<Component> {
		var comps : Array<Component> = [];
		for(uiData in data.elements) {
			var component = readComponent(uiData);
			if(component != null) comps.push( component );
		}
		return comps;
	}
	
	private function readStateContainer(data : haxe.xml.Fast) : Component {
		var container = new StateContainer();
		
		for(uiData in data.elements) {
			var component = readComponent(uiData);
			if (component != null) container.add( component );
			else {
				if (uiData.name == "state") {
					var stateComps = readUIList(uiData);
					for(comp in stateComps)
						container.addToState(comp, uiData.att.name);
				}
			}
		}
		
		return container;
	}
	
	private function readComponent(uiData : haxe.xml.Fast) : Component {
		if(uiData == null) return null;
		var comp : Component;
		
		switch(uiData.name) {
			case "radioGroup":
				var radioGroup = new RadioGroup();
				Reflect.setProperty(this, uiData.att.name, radioGroup);
				return null;
				
			case "container":
				comp = readStateContainer(uiData);
				
			case "image":
				var source = if(uiData.has.source) assetManager.getAsset(uiData.att.source) else null;
				var image = new Image(source);
				comp = image;
				
			case "scaledImage":
				var source = if(uiData.has.source) assetManager.getAsset(uiData.att.source) else null;
				var image = new ScaledImage(source);
				comp = image;

			case "label":
				var label = new Label();
				if(uiData.has.text) label.text = StringTools.replace(uiData.att.text, "\\n", "\n");
				if(uiData.has.wordWrap) label.wordWrap = uiData.att.wordWrap != "false";
				label.font = uiData.att.font;
				if(uiData.has.size) label.size  = Std.parseFloat(uiData.att.size);
				if(uiData.has.editable) label.editable = uiData.att.editable != "false";
				label.bold = uiData.has.bold && uiData.att.bold == "true";
				label.color = Std.parseInt(uiData.att.color);
				if(uiData.has.width) label.autoSize = false;
				if(uiData.has.letterSpacing) label.letterSpacing = Std.parseFloat(uiData.att.letterSpacing);
				if(uiData.has.align) label.align = switch(uiData.att.align) {
					case "left":	left;
					case "right":	right;
					case "center":	center;
					case "justify":	justify;
					default:		left;
				}
				comp = label;


			case "button":
				var button = new Button();
				button.upState = if(uiData.hasNode.upState) readComponent(uiData.node.upState.elements.next()) else null;
				button.downState = if(uiData.hasNode.downState) readComponent(uiData.node.downState.elements.next()) else null;
				button.overState = if(uiData.hasNode.overState) readComponent(uiData.node.overState.elements.next()) else null;
				if(uiData.has.onClick) button.onClick.add(Reflect.field(this, uiData.att.onClick));
				if(uiData.has.onMouseDown) button.onMouseDown.add(Reflect.field(this, uiData.att.onMouseDown));
				comp = button;
				
			case "checkBox":
				var checkBox = new CheckBox();
				checkBox.upState = if(uiData.hasNode.upState) readComponent(uiData.node.upState.elements.next()) else null;
				checkBox.downState = if(uiData.hasNode.downState) readComponent(uiData.node.downState.elements.next()) else null;
				checkBox.overState = if (uiData.hasNode.overState) readComponent(uiData.node.overState.elements.next()) else null;
				checkBox.selectedUpState = if(uiData.hasNode.selectedUpState) readComponent(uiData.node.selectedUpState.elements.next()) else null;
				checkBox.selectedDownState = if(uiData.hasNode.selectedDownState) readComponent(uiData.node.selectedDownState.elements.next()) else null;
				checkBox.selectedOverState = if(uiData.hasNode.selectedOverState) readComponent(uiData.node.selectedOverState.elements.next()) else null;
				if(uiData.has.onClick) checkBox.onClick.add(Reflect.field(this, uiData.att.onClick));
				if(uiData.has.onMouseDown) checkBox.onMouseDown.add(Reflect.field(this, uiData.att.onMouseDown));
				if(uiData.has.selected) checkBox.selected = uiData.att.selected != "false";
				comp = checkBox;

			case "radioButton":
				var radioButton = new RadioButton();
				radioButton.upState = if(uiData.hasNode.upState) readComponent(uiData.node.upState.elements.next()) else null;
				radioButton.downState = if(uiData.hasNode.downState) readComponent(uiData.node.downState.elements.next()) else null;
				radioButton.overState = if (uiData.hasNode.overState) readComponent(uiData.node.overState.elements.next()) else null;
				radioButton.selectedUpState = if(uiData.hasNode.selectedUpState) readComponent(uiData.node.selectedUpState.elements.next()) else null;
				radioButton.selectedDownState = if(uiData.hasNode.selectedDownState) readComponent(uiData.node.selectedDownState.elements.next()) else null;
				radioButton.selectedOverState = if(uiData.hasNode.selectedOverState) readComponent(uiData.node.selectedOverState.elements.next()) else null;
				if(uiData.has.onClick) radioButton.onClick.add(Reflect.field(this, uiData.att.onClick));
				if(uiData.has.onMouseDown) radioButton.onMouseDown.add(Reflect.field(this, uiData.att.onMouseDown));
				if(uiData.has.selected) radioButton.selected = uiData.att.selected != "false";
				if(uiData.has.group) {
					radioButton.group = Reflect.getProperty(this, uiData.att.group);
					radioButton.group.items.push(radioButton);
					if(radioButton.selected) radioButton.group.selectedItem = radioButton;
				}
				comp = radioButton;

			case "listBox":
				var listBox = new ListBox();
				comp = listBox;
				
			case "selectBox":
				var selectBox = new SelectBox();
				comp = selectBox;

			case "textBox":
				var textBox = new TextBox();
				var comps = readUIList(uiData);
				for (comp in comps) textBox.add(comp);
				if (uiData.has.textX) textBox.textX = Std.parseFloat(uiData.att.textX);
				if (uiData.has.textY) textBox.textY = Std.parseFloat(uiData.att.textY);
				textBox.font = uiData.att.font;
				textBox.size = Std.parseFloat(uiData.att.size);
				textBox.color = Std.parseInt(uiData.att.color);
				comp = textBox;

			case "slider":
				var slider = new Slider();
				var comps = readUIList(uiData);
				for (comp in comps) slider.add(comp);
				if (uiData.hasNode.nub) {
					slider.nub = readComponent(uiData.node.nub.elements.next());
					slider.add( slider.nub );
				}
				if (uiData.has.labelX) slider.label.x = Std.parseFloat(uiData.att.labelX);
				if (uiData.has.labelY) slider.label.y = Std.parseFloat(uiData.att.labelY);
				if (uiData.has.bold) slider.bold = uiData.att.bold != "false";
				if (uiData.has.step) slider.step = Std.parseFloat(uiData.att.step);
				if (uiData.has.minimum) slider.minimum = Std.parseFloat(uiData.att.minimum);
				if (uiData.has.maximum) slider.maximum = Std.parseFloat(uiData.att.maximum);
				if (uiData.has.labelFunc) slider.labelFunc = Reflect.getProperty(this, uiData.att.labelFunc);
				if(uiData.has.value) slider.value = Std.parseFloat(uiData.att.value);
				if(uiData.has.font) slider.font = uiData.att.font;
				if(uiData.has.size) slider.size = Std.parseFloat(uiData.att.size);
				if(uiData.has.color) slider.color = Std.parseInt(uiData.att.color);
				comp = slider;
				
				case "progressBar":
				var slider = new ProgressBar();
				var comps = readUIList(uiData);
				for (comp in comps) slider.add(comp);
				if (uiData.hasNode.nub) {
					slider.nub = readComponent(uiData.node.nub.elements.next());
					slider.add( slider.nub );
				}
				if (uiData.has.labelX) slider.label.x = Std.parseFloat(uiData.att.labelX);
				if (uiData.has.labelY) slider.label.y = Std.parseFloat(uiData.att.labelY);
				if (uiData.has.bold) slider.bold = uiData.att.bold != "false";
				if (uiData.has.step) slider.step = Std.parseFloat(uiData.att.step);
				if (uiData.has.minimum) slider.minimum = Std.parseFloat(uiData.att.minimum);
				if (uiData.has.maximum) slider.maximum = Std.parseFloat(uiData.att.maximum);
				if (uiData.has.labelFunc) slider.labelFunc = Reflect.getProperty(this, uiData.att.labelFunc);
				if(uiData.has.value) slider.value = Std.parseFloat(uiData.att.value);
				if(uiData.has.font) slider.font = uiData.att.font;
				if(uiData.has.size) slider.size = Std.parseFloat(uiData.att.size);
				if(uiData.has.color) slider.color = Std.parseInt(uiData.att.color);
				comp = slider;
			
			case "numericStepper":
				var numericStepper = new NumericStepper();
				var comps = readUIList(uiData);
				for (comp in comps) {
					numericStepper.add(comp);
					if(Std.is(comp,TextBox)) numericStepper._textBox = cast(comp);
				}
				if(uiData.hasNode.incButton) numericStepper.incButton = cast(readComponent(uiData.node.incButton.elements.next()));
				if(uiData.hasNode.decButton) numericStepper.decButton = cast(readComponent(uiData.node.decButton.elements.next()));
				if(uiData.has.minimum) numericStepper.minimum = Std.parseFloat(uiData.att.minimum);
				if(uiData.has.maximum) numericStepper.maximum = Std.parseFloat(uiData.att.maximum);
				if(uiData.has.value) numericStepper.value = Std.parseFloat(uiData.att.value);
				if(uiData.has.step) numericStepper.step = Std.parseFloat(uiData.att.step);
				comp = numericStepper;
				
			case "rectangle":
				var rectangle = new Rectangle(Std.parseInt(uiData.att.color), Std.parseFloat(uiData.att.width), Std.parseFloat(uiData.att.height));
				comp = rectangle;
				
			default:
				return null;
		}
				
		comp.x = if(uiData.has.x) Std.parseFloat(uiData.att.x) else 0;
		comp.y = if (uiData.has.y) Std.parseFloat(uiData.att.y) else 0;
		if(uiData.has.alpha) comp.alpha = Std.parseFloat(uiData.att.alpha);
		if(uiData.has.depth) comp.depth = Std.parseFloat(uiData.att.depth);
		if(uiData.name != "rectangle") {
			if(uiData.has.width) comp.width = Std.parseFloat(uiData.att.width);
			if(uiData.has.height) comp.height = Std.parseFloat(uiData.att.height);
		}
		if (uiData.has.enabled) comp.enabled = uiData.att.enabled != "false";
		if(uiData.has.visible) comp.visible = uiData.att.visible != "false";
		if(uiData.hasNode.hitArea) {
			var hitArea = uiData.node.hitArea;
			if(hitArea.hasNode.rectangle) {
				comp.hitArea = Rectangle(
					Std.parseFloat(hitArea.node.rectangle.att.x),
					Std.parseFloat(hitArea.node.rectangle.att.y),
					Std.parseFloat(hitArea.node.rectangle.att.width),
					Std.parseFloat(hitArea.node.rectangle.att.height)
				);
			}
		}
		if (uiData.has.name) Reflect.setProperty(this, uiData.att.name, comp);
		
		return comp;
	}
	
	private function init() : Void {
		
	}

	public function exit() : Void {
		#if air
		flash.desktop.NativeApplication.nativeApplication.exit();
		#end
	}

	public function minimize() : Void {
		#if air
		flash.desktop.NativeApplication.nativeApplication.activeWindow.minimize();
		#end
	}
	
	public function orderToFront() {
		#if air
		var win = flash.desktop.NativeApplication.nativeApplication.openedWindows[0];
		if(win != null) win.orderToFront();
		#end
	}
	
	private function uncaughtErrorHandler(_) {
		
	}
}