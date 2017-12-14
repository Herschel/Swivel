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
import haxe.macro.Expr;
import haxe.macro.Context;

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