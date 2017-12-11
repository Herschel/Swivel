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

package com.huey.macros;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

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