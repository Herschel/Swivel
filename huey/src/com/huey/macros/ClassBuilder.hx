package com.huey.macros;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class ClassBuilder
{
	public static function createFromContext() : ClassBuilder {
		var builder : ClassBuilder = new ClassBuilder();
		#if macro
			var clazz = Context.getLocalClass().get();
			builder.name = clazz.name;
			builder.fullClassPath = clazz.module;
			builder.meta = clazz.meta.get();
			for (field in Context.getBuildFields())
				builder._fields.set(field.name, FieldInfo.fromField(field));
		#end
		
		return builder;
	}
	
	public var _fields : StringMap<FieldInfo>;
	public var name(default, null) : String;
	public var fullClassPath(default, null) : String;
	public var meta : Metadata;
 
	public function new() {
		// TODO: name etc.
		_fields = new StringMap();
		meta = [];
	}
	
	inline public function getField(name : String) : Null<FieldInfo> {
		return _fields.get(name);
	}
	
	public function addField(field : FieldInfo) : Void {
		_fields.set(field.name, field);
	}
	
	public function getFieldsWithMeta(metadata : String) : Array<FieldInfo> {
		var results : Array<FieldInfo> = [];
		
		for (f in _fields) {
			var meta = f.getMeta(metadata);
			if (meta != null) results.push(f);
		}
		
		return results;
	}

	public function getMeta(metadata : String) {
		for(m in meta)
			if(m.name == metadata) return m;

		return null;
	}
	
	public function fields() : Array<Field> {
		var fields : Array<Field> = [];
		for (f in _fields) fields.push(f.toField());
		return fields;
	}
}