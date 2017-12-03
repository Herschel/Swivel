package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getQualifiedClassName;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import flash.media.SoundLoaderContext;
	import flash.media.ID3Info;
	
	public class __SwivelSound extends EventDispatcher {
		private static var _numInstances : uint = 1;
		
		public function get bytesLoaded() : uint	{ return 1; }
		public function get bytesTotal() : uint		{ return 1; }
		public function get id3() : ID3Info			{ return null; }
		public function get isBuffering() : Boolean	{ return false; }
		public function get isURLInaccessible() : Boolean { return false; }
		public function get length() : Number 		{ return 1; }
		public function get url() : String			{ return null; }
		
		public function __SwivelSound() {
			super();
			_instanceNum = _numInstances++;
			_name = getQualifiedClassName(this);
		}
		
		public function close():void {}
		public function extract(target : ByteArray, length : Number, startPosition : Number = -1) : void {}
		public function load(stream : URLRequest, context : SoundLoaderContext = null) : void {}
		public function loadCompressedDataFromByteArray(bytes : ByteArray, bytesLength : uint) : void {}
		public function loadPCMFromByteArray(bytes : ByteArray, samples : uint, format : String = "float", stereo : Boolean = true, sampleRate : Number = 44100.0) : void {}
		
		public function play(startTime : Number = 0, loops : int = 0, soundTransform : SoundTransform = null) : __SwivelSoundChannel {
			__Swivel.__swivel("asStart", __Swivel.frame, _instanceNum, _name, startTime, loops)
			return new __SwivelSoundChannel(_instanceNum);
		}		
		
		private var _instanceNum : uint;
		private var _name : String;
	}
	
}
