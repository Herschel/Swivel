package com.huey.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using com.huey.macros.MacroTools;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class Macros
{
	@:macro public static function build() : Array<Field> {
		var cl : ClassBuilder = ClassBuilder.createFromContext();

		for (field in cl.getFieldsWithMeta("forward")) {
			var meta = field.getMeta("forward");
			
			if (meta.params.length < 1)
				Context.error("@forward requires a parameter.", meta.pos);
			
			var fieldExpr : Expr = meta.params[0];
			
			switch(fieldExpr.expr) {
				case EConst(c):
					switch(c) {
						case CIdent(i):
							fieldExpr.expr = EField({expr: fieldExpr.expr, pos: fieldExpr.pos}, field.name);
						default:
					}
					
				default:
			}
			
			var type;
			switch(field.kind) {
				case FVar(t, _):	type = t;
				default:			Context.error("@forward destination field must be a variable, not be a property or function.", fieldExpr.pos);
			}
			
			// transform into property
			var getterName = "get_" + field.name;
			var setterName = if (meta.params.length < 2) "set_" + field.name else null;
			field.kind = FProp("get", if( setterName != null ) setterName else "null", type);
			
			meta.params = [];
			
			var getter = new FieldInfo(getterName);
			getter.pos = meta.pos;
			getter.access = [APrivate, AInline];
			getter.kind = FFun( {
				params:		[],
				args:		[],
				ret:		null,
				expr:		macro return $fieldExpr
			} );
			cl.addField(getter);
			
			if(setterName != null) {
				var setter = new FieldInfo(setterName);
				setter.pos = meta.pos;
				setter.access = [APrivate, AInline];
				setter.kind = FFun( {
					params:		[],
					args:		[ { name: "v", opt: false, type: null, value: null } ],
					ret:		null,
					expr:		macro return $fieldExpr = v
				} );
				cl.addField(setter);
			}
		}
		
		return cl.fields();
	}

}