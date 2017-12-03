package com.newgrounds.swivel.swf;
import format.swf.Data;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class SilenceSoundMutator implements ISWFMutator
{

	public function new() {
	}
	
	public function mutate(swf : SwivelSwf) : Void {
		swf.mapTags(removeSounds);
	}
	
	private function removeSounds(tag : SWFTag) : SWFTag {
		switch(tag) {
			case TStartSound(_,_), TSoundStream(_), TSoundStreamData(_):
				return null;
			default:
				return tag;
		}
	}
	
}