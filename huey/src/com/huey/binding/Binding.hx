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

package com.huey.binding;
import com.huey.events.Dispatcher;
import com.huey.macros.ClassBuilder;
import com.huey.macros.FieldInfo;
import com.huey.macros.MacroTools;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
using Lambda;

typedef BindingInstance = Void -> Void;

typedef BindingsList = List<BindingInstance>;

// RUN-TIME BINDING MANAGEMENT
@:autoBuild(com.huey.binding.Binding.bindable())
class Bindable
{
	private var __bindings : StringMap<BindingsList>;
	private var __distpatching : Bool;
	
	public function new() {
		__bindings = new StringMap();
		__distpatching = false;
	}
	
		
	public function addBinding(field : String, binding : BindingInstance) : Void {
		var bindingsList = __bindings.get(field);
		if (bindingsList == null) {
			bindingsList = new List<BindingInstance>();
			__bindings.set(field, bindingsList);
		}
		bindingsList.add(binding);
	}
	
	public function removeBinding(field : String, binding : BindingInstance) : Void {
		var bindingsList = __bindings.get(field);
		if (bindingsList != null)
			bindingsList.remove(binding);
	}

	public function removeBindings(field : String) : Void {
		__bindings.set(field, null);
	}
		
	private function dispatchBinding(field : String) : Void {
		if (__distpatching) return;
		
		__distpatching = true;
		
		var bindingsList : List<BindingInstance> = __bindings.get(field);
		//var isFieldBindable : Bool = Std.is(value, Bindable);
		if(bindingsList != null) {
			for (binding in bindingsList)
			{
				try { binding(); } catch(e:Dynamic) { }
			}
		}
		
		__distpatching = false;
	}
}

/**
 * Binding provides utilities for data binding.
 * @author Newgrounds.com, Inc.
 */
class Binding {
	#if macro
	
	private static var _cl : ClassBuilder;
	
	macro public static function bindable() : Array<Field> {
		_cl = ClassBuilder.createFromContext();

		for(field in _cl.getFieldsWithMeta("bindable"))
			makeFieldBindable(field);

		return _cl.fields();
	}
		
	/** Adds binding dispatches to fields, so that the field can be bound to. */
	private static function makeFieldBindable(field : FieldInfo) : Void {
		var pos = Context.currentPos();
		
		// add event dispatcher
		var setterField : FieldInfo;
		var fieldNameString = {expr:EConst(CString(field.name)), pos: Context.currentPos()};
		var fieldNameIdent = {expr:EConst(CIdent(field.name)), pos: Context.currentPos()};

		switch(field.kind) {
			case FVar(t, e):
				setterField = new FieldInfo("set_" + field.name);
				setterField.access = [APrivate];
				setterField.kind = FFun({
					ret:	t,
					params:	[],
					expr:	macro { $fieldNameIdent = v; dispatchBinding($fieldNameString); return v; },
					args:	[{name: "v", value: null, type: t, opt: false}]
				});
				_cl.addField(setterField);
				field.kind = FProp("default", setterField.name, t, e);

			case FProp(get, set, t, e):
				if(set == "default") {
					setterField = new FieldInfo("set_" + field.name);
					setterField.access = [APrivate];
					setterField.kind = FFun({
						ret:	t,
						params:	[],
						expr:	macro { $fieldNameIdent = v; dispatchBinding($fieldNameString); return v; },
						args:	[{name: "v", value: null, type: t, opt: false}]
					});
					_cl.addField(setterField);
					field.kind = FProp(get, setterField.name, t, e);
				} else {
					function injectNotify(e : ExprDef) : ExprDef {
						var retExpr : Expr;
						return switch(e) {
							case EReturn(e):
								(macro {
									var ret = $e;
									dispatchBinding($fieldNameString);
									return ret;
								}).expr;
							default:	return null;
						}
					}

					var setter = _cl.getField('set_${field.name}'); // MIKNEW
					switch(setter.kind) {
						case FFun(f):
							com.huey.macros.MacroTools.mapExpr(f.expr, injectNotify);
						default: Context.error("Unexpected error", pos);
					}
				}

			default:
				Context.error('${field.kind} can not be bindable', pos);
		}
	}
	
	private static function isBindable(obj : Expr) : Bool {
		switch(Context.typeof(obj)) {
			case TInst(t, params):
				var cl = t.get();
				while (cl.superClass != null) {
					cl = cl.superClass.t.get();
					if (cl.name == "Bindable") return true;
				}
				return false;
			default:	return false;
		}
	}
	
	private static function isBindableArray(obj : Expr) : Bool {
		switch(Context.typeof(obj)) {
			case TInst(t, params):
				var cl = t.get();
				return cl.name == "BindableArray";
			default:		return false;
		}
		
	}
	#end
		
	/** COMPILE-TIME BINDING GENERATION */
	#if !macro macro #end
	public static function bind<T>(dst : ExprOf<T>, src : ExprOf<T>) : ExprOf<Void> {
		// determine binding dependencies
		var dependencies = [];
		var localVars = [];
		function traverseExpr(e : ExprDef) : ExprDef {
			switch(e) {
				case EConst(c):
					switch(c) {
						case CIdent(s):
							if(Lambda.indexOf(localVars, s) == -1)
								if (isBindable( { expr: EConst(CIdent("this")), pos: Context.currentPos() } )) {
									dependencies.push( { obj: null, field: s } );
								}

						default:
					}
					
				case EField(obj, field):
					if (isBindable( obj )) {
						dependencies.push( { obj: obj, field: field } );
					}
					var expr = { expr:e, pos: Context.currentPos() };
					if (isBindableArray(expr))
						dependencies.push( { obj: expr, field: "_array" } );
				
				case EVars(vars):
					for(v in vars)
						localVars.push(v.name);
					
				default:
			}
			
			return null;
		}
		
		MacroTools.mapExpr(src, traverseExpr);
		/*
		// var oldObj = $obj;
		// function handler() {
		//		// for each dependent
		//		if($obj != oldObj) {
		//			oldObj.removeBinding($field, handler);
		//			$obj.addBinding($field, handler);
		//			oldObj = $obj;
		//		}
		//		$dst = $src;
		//	}
		*/

		var i : Int = 0;
		var vars = [];
		var ifExprs : Array<Expr> = [];
		var initExprs : Array<Expr> = [];
		for(dep in dependencies) {
			var obj;
			var isThis;
			if (dep.obj != null) {
				obj = dep.obj;
				isThis = false;
			} else {
				obj = { expr: EConst(CIdent("this")), pos: Context.currentPos() };
				isThis = true;
			}
			var field = { expr: EConst(CString(dep.field)), pos: Context.currentPos() };
			var oldObj = { expr: EConst(CIdent("old" + i)), pos: Context.currentPos() };
			var initBinding = macro if($obj != null) $obj.addBinding($field, handler);
			if(!isThis) {
				vars.push( {name: "old" + i, type: null, expr: obj} );
				ifExprs.push(
					macro if($oldObj != $obj) {
						if($oldObj != null) $oldObj.removeBinding($field, handler);
						$initBinding;
						$oldObj = $obj;
					}
				);
			}
			initExprs.push( macro $initBinding );
			i++;
		}

		var varsExpr = {expr: EVars(vars), pos: Context.currentPos()};
		var ifExpr = {expr: EBlock(ifExprs), pos: Context.currentPos()};
		var initExpr = {expr: EBlock(initExprs), pos: Context.currentPos()};
		var bindingExpr = macro { try { $dst = $src; } catch (e:Dynamic) { } };

		return macro {
			$varsExpr;
			function handler() {
				$ifExpr;
				$bindingExpr;
			}
			$initExpr;
			handler();
		};
	}

	macro public static function bindTwoWay<T>(dst : ExprOf<T>, src : ExprOf<T>) : ExprOf<Void> {
		return { expr: EBlock([Binding.bind(dst, src), Binding.bind(src, dst)]), pos: Context.currentPos() };
	}

}