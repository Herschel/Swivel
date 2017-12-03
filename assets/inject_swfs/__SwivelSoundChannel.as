package  {
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.EventDispatcher;
	
	public class __SwivelSoundChannel extends EventDispatcher {

		public function get leftPeak() : Number	{ return 0; }
		public function get rightPeak() : Number { return 0; }
		public function get position() : Number { return 0; }
		public function get soundTransform() : SoundTransform { return _transform; } // TODO: defensive copy?
		public function set soundTransform(v : SoundTransform) : void {
			_transform = v;
			__Swivel.__swivel("asSetVolume", __Swivel.frame, _instanceNum, _transform.volume);
			if(_transform.rightToLeft > 0 || _transform.leftToRight > 0)
				__Swivel.__swivel("asSetTransform", __Swivel.frame, _instanceNum, _transform.leftToLeft, _transform.rightToLeft, _transform.leftToRight, _transform.rightToRight);
			else
				__Swivel.__swivel("asSetPan", __Swivel.frame, _instanceNum, _transform.pan);
		}
		
		public function __SwivelSoundChannel(instanceNum : uint, soundTransform : SoundTransform = null) {
			super();
			_instanceNum = instanceNum;
			if(soundTransform == null) this.soundTransform = new SoundTransform();
			else this.soundTransform = soundTransform;
		}
		
		public function stop() : void {
			__Swivel.__swivel("asStop",__Swivel.frame, _instanceNum);
		}
		
		private var _instanceNum : uint;
		private var _transform : SoundTransform;
	}
	
}
