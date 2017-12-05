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

package com.newgrounds.swivel.swf;
import format.abc.Context;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */
/*
class SwivelAbcContext extends Context {
	public static function fromData(d : ABCData) {
		var context = new SwivelAbcContext();
		context.bytepos = new NullOutput();
		contextopw = new OpWriter(bytepos);
		hstrings = new Hash();
		data = new ABCData();
		data.ints = new Array();
		data.uints = new Array();
		data.floats = new Array();
		data.strings = new Array();
		data.namespaces = new Array();
		data.nssets = new Array();
		data.metadatas = new Array();
		data.methodTypes = new Array();
		data.names = new Array();
		data.classes = new Array();
		data.functions = new Array();
		emptyString = string("");
		nsPublic = namespace(NPublic(emptyString));
		arrayProp = name(NMultiLate(nsset([nsPublic])));
		beginFunction([],null);
		ops([OThis,OScope]);
		init = curFunction;
		init.f.maxStack = 2;
		init.f.maxScope = 2;
		classes = new Array();
		data.inits = [{ method : init.f.type, fields : classes }];
	}
	
	public var replaceMode : ReplaceMode;
	
	public function new() {
		replaceMode = overwrite;
		super();
	}
	
	public function beginStatics() {
		if (curClass.statics != null) replaceFunction( data.get(data.functions, cast(curClass.statics))  );
		else {
			beginFunction([], null);
			curClass.statics = curFunction.f.type;
		}
		return curFunction.f;
	}
	
	override public function beginClass( path : String ) {
		endClass();
		var tpath = this.type(path);
		
		for (cl in data.classes) {
			if (Type.enumEq(tpath, cl.name)) {
				curClass = cl;
				break;
			}
		}
		
		if (curClass != null) {
			fieldSlot = curClass.fields.length + curClass.staticFields.length + 1;
		} else {
			beginFunction([],null);
			var st = curFunction.f.type;
			op(ORetVoid);
			endFunction();
			beginFunction([],null);
			var cst = curFunction.f.type;
			curFunction.f.maxStack = 1;
			op(OThis);
			op(OConstructSuper(0));
			op(ORetVoid);
			endFunction();
			fieldSlot = 1;
			curClass = {
				name : tpath,
				superclass : this.type("Object"),
				interfaces : [],
				isSealed : false,
				isInterface : false,
				isFinal : false,
				namespace : null,
				constructor : cst,
				statics : st,
				fields : [],
				staticFields : [],
			};
			data.classes.push(curClass);
			classes.push({
				name: tpath,
				slot: 0,
				kind: FClass(Idx(data.classes.length - 1)),
				metadatas: null,
			});
		}
		
		curFunction = null;
		return curClass;
	}
	
	override public function endClass() {
		if( curClass == null )
			return;
		endFunction();
		curFunction = null;
		curClass = null;
	}
	
	public override function finalize() {
		endClass();

		replaceMode = overwrite;
		
		if (init == null) beginFunction([], null);
		else replaceFunction( init.f );
		
		init = curFunction;
		init.f.maxStack = 2;
		init.f.maxScope = 2;
		
		ops([OThis, OScope]);
		
		for (cl in data.classes) {
			ops([
				OGetGlobalScope,
				OGetLex( curClass.superclass ),
				OScope,
				OGetLex( curClass.superclass ),
				OClassDef( Idx(data.classes.length - 1) ),
				OPopScope,
				OInitProp( curClass.name ),
			]);
		}
		
		op(ORetVoid);
		
		endFunction();
		curClass = null;
	}
	
	override public function beginConstructor(args) {
		if (curClass.constructor != null)
			replaceFunction( data.get(data.functions, cast(curClass.constructor)) );
		else {
			beginFunction(args, null);
			curClass.constructor = curFunction.f.type;
		}
		return curFunction.f;
	}
	
	override public function beginMethod( mname : String, targs, tret, ?isStatic, ?isOverride, ?isFinal ) {
		var fl = if ( isStatic ) curClass.staticFields else curClass.fields;
		for (field in fl) {
			switch( data.get(data.names, field.name) ) {
				case NName(n, _):
					if (data.get(data.strings, n) == mname) {
						switch(field.kind) {
							case FMethod(type,_,_,_):
								replaceFunction( data.get(data.functions, cast(type)) );
								return curFunction.f;
							default: throw("Unexpected field!");
						}
					}
					
				default:
					throw("Unexpected field name!");
			}
		}
		
		var m = beginFunction(targs,tret);
		fl.push({
			name : property(mname),
			slot : 0,
			kind : FMethod(curFunction.f.type,KNormal,isFinal,isOverride),
			metadatas : null,
		});
		return curFunction.f;
	}

	function replaceFunction(f) {
		endFunction();
		curFunction = { f : f, ops : [] };
		registers = new Array();
		for( x in 0...f.nRegs )
			registers.push(true);
		return f;
	}
	
	override function endFunction() {
		if( curFunction == null )
			return;
		var old = opw.o;
		var bytes = new haxe.io.BytesOutput();
		opw.o = bytes;
		for( op in curFunction.ops )
			opw.write(op);
		switch(replaceMode) {
			case overwrite:
				curFunction.f.code = bytes.getBytes();
				
			case prepend:
				if (curFunction.f.code != null) bytes.write(curFunction.f.code);
				curFunction.f.code = bytes.getBytes();
				
			case append:
				var newBytes = new haxe.io.BytesOutput();
				
				if (curFunction.f.code != null) newBytes.write(curFunction.f.code);
				newBytes.write(bytes.getBytes());
				curFunction.f.code = newBytes.getBytes();
		}
		opw.o = old;
		curFunction = null;
	}
}

enum ReplaceMode {
	overwrite;
	prepend;
	append;
}*/