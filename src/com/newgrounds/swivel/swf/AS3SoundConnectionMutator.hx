/**
 * ...
 * @author Newgrounds.com, Inc.
 * Tracks sound events over LocalConnection
 */

package com.newgrounds.swivel.swf;
import com.newgrounds.swivel.audio.AudioTracker;
import com.newgrounds.swivel.audio.SoundClip;
import com.newgrounds.swivel.swf.SwivelSwf.ABCStuff;
import format.abc.Context;
import format.abc.Data;
import format.abc.OpReader;
import format.as1.Data;
import format.swf.Data;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

using com.newgrounds.swivel.swf.AbcUtils;

typedef ClipFrameSounds = IntHash< Array<SoundLogEntry> >;

class AS3SoundConnectionMutator extends SoundConnectionMutator {
	public function new(connectionName : String, audioTracker : AudioTracker) {
		super(connectionName, audioTracker);
		_clipsWithSound = new IntHash();
	}
	
	override public function mutate(swf : SwivelSwf) : Void {
		for(i in 0...swf.tags.length) {
			var tag = swf.tags[i];
			switch(tag) {
				case TActionScript3(data, c):
					var abc = new format.abc.Reader(new BytesInput(data)).read();
					
					var altered = false;
					for(j in 0...abc.names.length) {
						var clName = abc.getNamePath(Idx(j+1));
						if(clName == "flash.media.Sound") {
							abc.names[j] = NName( abc.string("__SwivelSound"), abc.namespace(NPublic(abc.string(""))) );
							altered = true;
						} else if(clName == "flash.media.SoundChannel") {
							abc.names[j] = NName( abc.string("Object"), abc.namespace(NPublic(abc.string(""))) );
							altered = true;
						}
					}
					
					if(altered) {
						var o = new BytesOutput();
						new format.abc.Writer(o).write(abc);
						swf.tags[i] = TActionScript3(o.getBytes(), c);
					}

				default:
			}
		}
		
		super.mutate(swf);
	}
	
	private var _clipsWithSound : IntHash<ClipFrameSounds>;
	
	override private function handleStartSound(clipId : Int, frame : Int, soundId : Int, infos : SoundInfo) : SWFTag {
		var sounds = getClip(clipId, frame);
		sounds.push({
			frame: frame,
			soundId: event(soundId),
			type: event(infos),
		});
		return null;
	}
	
	override private function handleStreamFrame(clipId : Int, clipFrame : Int, streamId : Int, streamFrame : Int) : SWFTag {
		var sounds = getClip(clipId, clipFrame);
		sounds.push({
			frame: clipFrame,
			soundId: SoundClipId.stream(streamId),
			type: SoundLogType.stream({startFrame: streamFrame, endFrame: streamFrame}),
		});
		return null;
	}
	
	private function getClip(id : Int, frame : Int) : Array<SoundLogEntry> {
		var sounds = _clipsWithSound.get(id);
		if(sounds == null) {
			sounds = new IntHash();
			_clipsWithSound.set(id, sounds);
		}
		
		var frameSounds = sounds.get(frame);
		if(frameSounds == null) {
			frameSounds = new Array();
			sounds.set(frame, frameSounds);
		}
		return frameSounds;
	}
	
	inline private function name(ctx : Context, name : String) {
		return ctx.name( NName(ctx.string(name), ctx.nsPublic) );
	}
	
	private var _currentSounds : ClipFrameSounds;
	
	override private function finalize(swf : SwivelSwf) {
		for(clipId in _clipsWithSound.keys()) {
			_currentSounds = _clipsWithSound.get(clipId);
			swf.hoistClip(clipId, injectSoundMethods);
		}
	}
	
	function injectSoundMethods(abcStuff : ABCStuff) {
		var abc = abcStuff.abc;
		var cl = abcStuff.cl;
				
		var addFrameScriptName = abc.publicName( "addFrameScript" );
		var publicNs = abc.namespace( NPublic(abc.string("")) );
		var voidName = abc.publicName("void");
		var swivelClName = abc.publicName("__Swivel");
		var startSoundStr = abc.string("startSound");
		var frameName = abc.publicName("frame");
		var streamSoundStr = abc.string("streamSound");
		var swivelName = abc.publicName("__swivel");
		//var traceName = abc.publicName("trace");
		
		var oldFrameScripts = new IntHash<Function>();
		for(f in cl.fields) {
			var name = abc.getName(f.name);
			switch(name) {
				case NName(n,_):
					var name = abc.getString(n);
					if(name.substr(0,5) == "frame") {
						var oldMethod = switch(f.kind) {
						case FMethod(t,_,_,_): abc.getFunction(t);
							default: throw("Unexpected frame method");
						};
				
						var frameNum = Std.parseInt(name.substr(5));
						if(frameNum != null) oldFrameScripts.set( frameNum-1, oldMethod );
					}
				default:
			}
		}
			
		var ctorOps = [
			OThis,
			OScope,
		];
		
		var j = 0;
		for(frame in _currentSounds.keys()) {
			var methodName = abc.pushName( NName(abc.pushString('__snd$j'), publicNs) );
			var oldMethod = oldFrameScripts.get(frame);
			
			if(oldMethod == null) {
				ctorOps = ctorOps.concat([
					OFindPropStrict(addFrameScriptName),
					abc.opInt(frame),
					OThis,
					OGetProp(methodName),
					OCallPropVoid(addFrameScriptName, 2),
				]);
			} else {
				if(oldMethod.maxStack < 2) oldMethod.maxStack = 2;
				oldMethod.prependOps([
					OThis,
					OScope,
					OFindPropStrict(methodName),
					OCallPropVoid(methodName, 0),
					OPopScope,
				]);
			}
			
			var methodOps = [
				OThis,
				OScope,
			];
			
			for(e in _currentSounds.get(frame)) {
				var soundId : Int = switch(e.soundId) {
					case event(i):	i;
					case stream(i):	i;
					default:		throw("Bad sound id"); -1;
				}
				
				
				switch(e.type) {
					case event(info):
						methodOps = methodOps.concat([
							OGetLex( swivelClName ),
							OString( startSoundStr ),
							OGetLex( swivelClName ),
							OGetProp( frameName ), // movie frame
							OInt(soundId), // sound id
							OInt(Type.enumIndex(info.sync)), // sync
							if(info.inPoint != null) abc.opInt(Int32.toNativeInt(info.inPoint)) else ONull, // inPoint
							if(info.outPoint != null) abc.opInt(Int32.toNativeInt(info.outPoint)) else ONull, // outPoint
							OInt(info.loops), // loops
						]);
						
						if(info.envelope != null) {
							for(p in info.envelope) {
								methodOps = methodOps.concat([
									abc.opInt(Int32.toNativeInt(p.position)),
									abc.opInt(p.leftLevel),
									abc.opInt(p.rightLevel),
								]);
							}
							methodOps.push(OArray(info.envelope.length * 3));
						} else methodOps.push( ONull );
						methodOps.push( OCallPropVoid(swivelName, 8) );
						
					case stream(frames):
						methodOps = methodOps.concat([
							OGetLex( swivelClName ),
							OString( streamSoundStr ),
							OGetLex( swivelClName ),
							OGetProp( frameName ), // movie frame
							OInt(soundId), // stream id
							abc.opInt(frames.startFrame), // stream frame
							OCallPropVoid(swivelName, 4),
						]);
						
					default:
						throw("Bad sound type in AS3SoundConnectionMutator");
				}
			}

			methodOps.push(OPopScope);
			methodOps.push(ORetVoid);
			
			abc.quickMethod(cl, methodName, methodOps, KNormal, null, voidName);
			j++;
		}
		
		ctorOps.push(OPopScope);
		
		var ctor = abc.getFunction(cl.constructor);
		if(ctor.maxStack < 4) ctor.maxStack = 4;
		if(ctor.maxScope < 4) ctor.maxScope = 4;
		ctor.prependOps(ctorOps);
	}
}
