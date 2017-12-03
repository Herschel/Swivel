package com.huey.macros;
import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class FieldInfo
{
	public static function fromField(field : Field) : FieldInfo {
		var f : FieldInfo = new FieldInfo(field.name);
		f.pos = field.pos;
		f.meta = field.meta;
		f.kind = field.kind;
		f.access = field.access;
		return f;
	}
	
	public var name : String;
	public var pos : Position;
	public var meta(default, null) : Metadata;
	public var kind : FieldType;
	public var access : Array<Access>;
	
	public function new(name : String) : Void {
		this.name = name;
		meta = [];
		access = [APublic];
		#if macro
			pos = Context.currentPos();
		#end
	}
	
	public function toField() : Field {
		return {
			name:	name,
			pos:	pos,
			meta:	meta,
			kind:	kind,
			access:	access
		};
	}
	
	public function getMeta(name : String) {
		for (m in meta)
			if (m.name == name) return m;
		
		return null;
	}
	
	public function addMeta(name : String, ?params : Array<Expr>) : Void {
		
	}
	
	
}