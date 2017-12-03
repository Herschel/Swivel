package  {
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	
	public class __Swivel {
		private static var __swivelSharedObj : SharedObject;
		private static var _swivelCon : Object;
		private static var _frame : int = 0;
		private static var _root : MovieClip;
		private static var _s : __SwivelSound;
		private static var _mask : Shape;
		private static var _startFrame : int;
		
		public static function __swivel(...args) : void {
			//args.unshift("__swivel");
			//__swivelCon.send.apply(__swivelCon, args);
			//trace("swivel: " + args);
			_swivelCon.receiveMessage(args);
		}
		
		public static function get frame() : uint {
			return _frame - 1;
		}
				
		public static function setMask(clip : DisplayObject, margin : Number) : void {
			if(margin < 10) margin = 10;

			var m : Shape = new Shape();
			m.graphics.beginFill(0);
			m.graphics.drawRect(-margin, -margin, stage.stageWidth+margin*2, stage.stageHeight+margin*2);
			m.graphics.endFill();
			// TODO: Dangerous... does this allow GC safely?
			stage.addChild(m);
			m.visible = false;
			clip.mask = m;
		}
		
		public static function get stage() : Stage {
			try {
				var ow : Array = getDefinitionByName("flash.desktop.NativeApplication").nativeApplication.openedWindows;
				return ow[ow.length-1].stage;
			} catch(error:*) { }
			return null; 
		}
		
		public static function registerDocument(root : MovieClip, startFrame : int) : void {
			_startFrame = startFrame;
			
			_root = root;			
			_root.addEventListener(Event.ENTER_FRAME, __onEnterFrame, false, 999, true)
			_root.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 999, true);
			
			__onEnterFrame(null);
			_swivelCon = stage.loaderInfo.applicationDomain.getDefinition("com.newgrounds.swivel.swf.AS3SwivelConnection");
		}
		
		private static function addedToStage(e:Event) : void {
			_root.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			if(_startFrame > 1) _root.gotoAndPlay(_startFrame);
		}
		
		private static function __onEnterFrame(e:Event) : void {
			if(!__swivelSharedObj) {
				__swivelSharedObj = SharedObject.getLocal("__swivel");
				__swivelSharedObj.clear();
			}
			var rootFrame : uint = _root.currentFrame;
			for(var i:int=0; _root.scenes[i].name != _root.currentScene.name && i<_root.scenes.length; i++) {
				rootFrame += _root.scenes[i].numFrames;
			}
			__swivelSharedObj.data.frame = rootFrame;
			__swivelSharedObj.flush();
			_frame++;
		}
		

	}
	
}
