package com.newgrounds.swivel.swf;

import format.abc.Data;
import format.abc.OpWriter;
import format.abc.Reader;
import format.abc.Writer;
import format.swf.Data;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class AbcUtils {
	private static function lookup<T>( arr : Array<T>, n : T ) : Index<T> {
		for( i in 0...arr.length )
			if( arr[i] == n )
				return Idx(i + 1);
		arr.push(n);
		return Idx(arr.length);
	}
	
	private static function elookup<T>( arr : Array<T>, n : T ) : Index<T> {
		for( i in 0...arr.length )
			if( Type.enumEq(arr[i],n) )
				return Idx(i + 1);
		arr.push(n);
		return Idx(arr.length);
	}

	inline public static function opInt(abc : ABCData, v) : OpCode {
		return
			if(v < 32768) OInt(v);
			else OIntRef( int(abc, v) );
	}
	
	public static function int(abc : ABCData, v)								return lookup(abc.ints, v);
	public static function uint(abc : ABCData, v)								return lookup(abc.uints, v);
	public static function float(abc : ABCData, v : Float)						return lookup(abc.floats, v);
	public static function string(abc : ABCData, v : String)					return lookup(abc.strings, v);
	public static function pushString(abc : ABCData, v : String) : Index<String> {
		abc.strings.push(v);
		return Idx(abc.strings.length);
	}
	public static function name(abc : ABCData, v : Name)						return elookup(abc.names, v);
	inline public static function pushName(abc : ABCData, v : Name) : IName {
		abc.names.push(v);
		return Idx(abc.names.length);
	}
	public static function publicName(abc : ABCData, v : String)				return elookup(abc.names, NName( string(abc, v), namespace(abc, NPublic(string(abc, ""))) ) );
	public static function namespace(abc : ABCData, v : Namespace)				return elookup(abc.namespaces, v);
	public static function namespaceSet(abc : ABCData, v : NamespaceSet)		return elookup(abc.nssets, v);
	public static function methodType(abc : ABCData, v : MethodType)			{ abc.methodTypes.push(v); return Idx(abc.methodTypes.length - 1); }
	public static function type(abc : ABCData, path) : Null<Index<Name>> {
		if( path == "*" )
			return null;
		var path = path.split(".");
		var cname = path.pop();
		var pid = string(abc,path.join("."));
		var nameid = string(abc,cname);
		var pid = namespace(abc,NPublic(pid));
		var tid = name(abc,NName(nameid,pid));
		return tid;
	}
	
	public static function replaceName(abc : ABCData, i : IName, name : Name) {
		var _i = switch(i) {
			case Idx(i): i-1;
		};
		
		abc.names[_i] = name;
	}
	
	public static function getInt(abc : ABCData, i)								return abc.get(abc.ints, i);
	public static function getUInt(abc : ABCData, i)							return abc.get(abc.uints, i);
	public static function getFloat(abc : ABCData, i : Index<Float>)			return abc.get(abc.floats, i);
	public static function getString(abc : ABCData, i : Index<String>)			return abc.get(abc.strings, i);
	public static function getClass(abc : ABCData, i : Index<ClassDef>)			return abc.get(abc.classes, i);
	public static function getName(abc : ABCData, i : IName)					return abc.get(abc.names, i);
	public static function getNamespace(abc : ABCData, i : Index<Namespace>)	return abc.get(abc.namespaces, i);
	public static function getNamespaceSet(abc : ABCData, i : Index<NamespaceSet>) return abc.get(abc.nssets, i);
	public static function getMethodType(abc : ABCData, i : Index<MethodType>)	{
		return switch( i ) { case Idx(n): abc.methodTypes[n]; };
	}
	public static function getFunction(abc : ABCData, i : Index<MethodType>) {
		for (f in abc.functions)
			if (Type.enumEq(f.type, i)) return f;
		return null;
	}
	
	public static function getNamespaceStr(abc : ABCData, i : Index<Namespace>) : String {
		switch(i) { case Idx(n): if(n==0) return null; }
		
		return switch( getNamespace(abc, i) ) {
			case NPublic(ns):			getString(abc, ns);
			case NNamespace(ns):		getString(abc, ns);
			case NPrivate(ns):			getString(abc, ns);
			case NInternal(ns):			getString(abc, ns);
			case NProtected(ns):		getString(abc, ns);
			case NExplicit(ns):			getString(abc, ns);
			case NStaticProtected(ns):	getString(abc, ns);
		}
	}
	
	/*public static function quickClass(name : String) : ABCData {
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
	}*/
	
	public static function dumpFunc(abc : ABCData, f : Function) : String {
		var ops = format.abc.OpReader.decode(new BytesInput(f.code));
		var str = "";
		for(op in ops) {
			str += switch(op) {
				case OGetLex(n):			'OGetLex(${getNamePath(abc,n)})';
				case OFindProp(n):			'OFindProp(${getNamePath(abc,n)})';
				case OFindPropStrict(n):	'OFindPropStrict(${getNamePath(abc,n)})';
				case OGetProp(n):			'OGetProp(${getNamePath(abc,n)})';
				case OInitProp(n):			'OInitProp(${getNamePath(abc,n)})';
				case OString(s):			'OString(${getString(abc,s)})';
				case OCallProperty(n,i):	'OCallProperty(${getNamePath(abc,n)},$i)';
				case OCallPropVoid(n,i):	'OCallPropVoid(${getNamePath(abc,n)},$i)';
				case OConstructProperty(n,i):'OConstructProperty(${getNamePath(abc,n)},$i)';
				case OSetProp(n):			'OSetProp(${getNamePath(abc,n)})';
				//case OClassDef(c):			'OClassDef(${getNamePath(abc,getClass(abc,c).name)})';
				
				default:	Std.string(op);
			}
			str += "\n";
		}
		return str;
	}
	
	public static function dumpAbc(abc : ABCData) {
		var str = "";
		/*var str = "init fields:";
		for(init in abc.inits) {
			for(field in init.fields)
				str += "  " + getNamePath(abc, field.name) + "\n";
		}
		str += "\n";*/
		for(f in abc.functions) {
			str += dumpFunc(abc, f);
			str += "-----------------\n\n";
		}
		/*
		str += "\nclasses:\n";
		for(cl in abc.classes)
			str += "  " + getNamePath(abc, cl.name) + " extends " + getNamePath(abc, cl.superclass) + "\n";
		str += "\n";*/
		
		str += "\nstrings:\n";
		for(i in 0...abc.strings.length)
			if(abc.strings[i].substr(0,5) != "frame") str += "  " + (i+1) + ".\t" + abc.strings[i] + "\n";
			
		/*str += "\nnames:\n";
		for(i in 1...abc.names.length+1)
			str += "  " + i + ".\t" + getNamePath(abc, Idx(i)) + "\n";*/
			
		str += "\n";
		return str;
	}

	/*inline private static function mergeMap<T>(abc : ABCData, arr : Array<Index<T>>, i : Index<T> ) : T {
		switch(i) {
			case Idx(j): return arr[j];
		}
	}
	
	inline private static function nullMergeMap<T>(abc : ABCData, arr : Array<Index<T>>, i : Null<Index<T>> ) : T {
		return if(i != null) mergeMap(abc,arr,i) else null;
	}
	
	public static function merge(dst : ABCData, src : ABCData) {
		var intMap = new Array();
		var uintMap = new Array();
		var floatMap = new Array();
		var namespaceMap = new Array();
		var nssetMap = new Array();
		var nameMap = new Array();
	
		var classMap = new Array();
		
		for(i in 0...src.ints.length) intMap[i] = dst.int(src.ints[i]);
		for(i in 0...src.uints.length) uintMap[i] = dst.uint(src.uints[i]);
		for(i in 0...src.floats.length) floatMap[i] = dst.float(src.uints[i]);
		for(i in 0...src.strings.length) stringMap[i] = dst.string(src.strings[i]);
		
		for(i in 0...src.namespaces.length) {
			namespaceMap[i] = switch(src.namespaces[i]) {
				case NPrivate(ns):			dst.namespace( NPrivate(mergeMap(dst,stringMap,ns)) );
				case NNamespace(ns):		dst.namespace( NNamespace(mergeMap(dst,stringMap,ns)) );
				case NPublic(ns):			dst.namespace( NPublic(mergeMap(dst,stringMap,ns)) );
				case NInternal(ns):			dst.namespace( NInternal(mergeMap(dst,stringMap,ns)) );
				case NProtected(ns):		dst.namespace( NProtected(mergeMap(dst,stringMap,ns)) );
				case NExplicit(ns):			dst.namespace( NExplicit(mergeMap(dst,stringMap,ns)) );
				case NStaticProtected(ns):	dst.namespace( NStaticProtected(mergeMap(dst,stringMap,ns)) );
			}
		}
		
		for(i in 0...src.nssets.length) {
			var nsset = src.nssets[i];
			var newNsset = new Array();
			for(ns in nsset) newNsset.push( mergeMap(dst,namespaceMap,ns) );
			nssetMap[i] = dst.namespaceSet( newNsset );
		}
		
		for(i in 0...src.names.length) {
			nameMap[i] = switch(src.names[i]) {
				case NName(n,ns):			dst.name( NName( mergeMap(dst,stringMap,n), mergeMap(dst,namespaceMap,ns) ) );
				case NMulti(n,nsset):		dst.name( NMulti( mergeMap(dst,stringMap,n), mergeMap(dst,nssetMap,nsset) ) );
				case Runtime(n):			dst.name( NRuntime( mergeMap(dst,stringMap,n) ) );
				case NRuntimeLate:			dst.name( NRuntimeLate );
				case NMultiLate(nsset):		dst.name( NMultiLate( mergeMap(dst,nssetMap,nsset) ) );
				case NAttrib(n):			dst.name( NAttrib(n) );
				case NParams(n, params):
					throw("TODO???");
			}
		}
		
		// TODO: method types???
		
		// TODO this
		for(i in 0...src.metadatas.length) {
			var metadata = src.metadatas[i];
			var newData = {
				n: if(metadata.n != null) mergeMap(dst,stringMap,metadata.n) else null,
				v: mergeMap(dst,stringMap,metadata.v)
			};
			metadataMap[i] = dst.metadata( {name: mergeMap(dst,stringMap,metadata.name), data: newData} );
		}
		
		for(i in 0...src.classes.length) {
			var cl = src.classes[i];
			var newClass = {
				name: mergeMap(dst,stringMap,cl.name),
				superclass: nullMergeMap(dst,stringMap,cl.superclass),
				interfaces: new Array(),
				constructor: mergeMap(dst,methodTypeMap,cl.constructor),
				fields: new Array(),
				namespace: nullMergeMap(dst,namespaceMap,cl.namespace),
				isSealed: cl.isSealed,
				isFinal: cl.isFinal,
				isInterface: cl.isInterface,
				statics: mergeMap(dst,methodTypeMap,cl.statics),
				staticFields: new Array(),
			};
			
			dst.classes.push(cl);
			classMap[i] = dst.classes.length;
		}
		
		for(i in 0...src.inits.length) {
			var init = src.inits[i];
			var newInit = {
				method: mergeMap(dst,methodTypeMap,init.method),
				fields: new Array(),
			};
			dst.inits.push(newInit);
		}
		
		for(i in 0...src.functions.length) {
			var f = src.functions[i];
			var newF = {
				type: mergeMap(dst,methodTypeMap,f.type),
				maxStack: f.maxStack,
				nRegs: f.nRegs,
				initScope: f.initScope,
				maxScope: f.maxScope,
				maxStack: f.maxStack,
				code: null,
				trys: new Array(),
				locals: new Array(),
			}
			
			
			var ops = format.abc.OReader.decode(new BytesInput(f.code));
			for(i in 0...ops.length) {
				ops[i] = switch(ops[i]) {
					case OGetSuper(n):				OGetSuper( mergeMap(dst,nameMap,n) );
					case OSetSuper(n):				OSetSuper( mergeMap(dst,nameMap,n) );
					case ODxNs(s):					ODxNs( mergeMap(dst,stringMap,s) );
					case OString(s):				OString( mergeMap(dst,stringMap,s) );
					case OIntRef(i):				OIntRef( mergeMap(dst,intMap,i) );
					case OUIntRef(i):				OUIntRef( mergeMap(dst,uintMap,i) );
					case OFloat(f):					OFloat( mergeMap(dst,floatMap,f) );
					case ONamespace(ns):			ONamespace( mergeMap(dst,namespaceMap,ns) );
					case OFunction(m):				OFunction( mergeMap(dst,methodTypeMap,m) );
					case OCallStatic(m,i): 			OCallStatic( mergeMap(dst,methodTypeMap,m), i);
					case OCallSuper(n,i):			OCallSuper( mergeMap(dst,nameMap,n), i );
					case OCallProperty(n,i):		OCallProperty( mergeMap(dst,nameMap,n), i );
					case OConstructProperty(n,i):	OConstructProperty( mergeMap(dst,nameMap,n), i );
					case OCallPropLex(n,i):			OCallPropLex( mergeMap(dst,nameMap,n), i );
					case OCallSuperVoid(n,i):		OCallSuperVoid( mergeMap(dst,nameMap,n), i );
					case OCallPropVoid(n,i):		OCallPropVoid( mergeMap(dst,nameMap,n), i );
					// OClassDef
					case OGetDescendants(n):		OGetDescendants( mergeMap(dst,nameMap,n) );
					case OFindPropStrict(n):		OFindPropStrict( mergeMap(dst,nameMap,n) );
					case OFindDefinition(n):		OFindDefinition( mergeMap(dst,nameMap,n) );
					case OGetLex(n):				OGetLex( mergeMap(dst,nameMap,n) );
					case OSetProp(n):				OSetProp( mergeMap(dst,nameMap,n) );
					case OGetProp(n):				OGetProp( mergeMap(dst,nameMap,n) );
					case OInitProp(n):				OInitProp( mergeMap(dst,nameMap,n) );
					case ODeleteProp(n):			ODeleteProp( mergeMap(dst,nameMap,n) );
					case OCast(n):					OCast( mergeMap(dst,nameMap,n) );
					case OAsType(n):				OAsType( mergeMap(dst,nameMap,n) );
					case OIsType(n):				OIsType( mergeMap(dst,nameMap,n) );
					case ODebugReg(s,r,l):			ODebugReg( mergeMap(dst,stringMap,s), r, l );
					case ODebugFile(s):				ODebugFile( mergeMap(dst,stringMap,s) );
					default: ops[i];
				}
			}
			var o = new BytesOutput();
			format.abc.OReader.encode(o, ops);
			newF.code = o.getBytes();
			dst.functions.push(newF);
		}
	}*/
	
	private static var _mergeI : Int = 0;
	public static function mergeClass(dst : ABCData, dstCl : ClassDef, src : ABCData, srcCl : ClassDef) {
		trace(dumpAbc(dst));
		trace( dumpAbc(src) );
		//trace( countSlots(src, srcCl) );
		var slotOffset = countSlots(dst, dstCl);
		//trace( slotOffset );
		
		var srcClassName : String = getNamePath(src, srcCl.name);
		var dstClassName : String = getNamePath(dst, dstCl.name);
		for(i in 0...src.strings.length) {
			if(src.strings[i] == srcClassName) {
				src.strings[i] = dstClassName;
			}
		}
		
		for(field in srcCl.fields) {
			dstCl.fields.push(mergeField(dst,src,field, slotOffset));
		}
		
		var theName = null;
		for(field in srcCl.staticFields) {
			dstCl.staticFields.push(mergeField(dst,src,field, slotOffset));
			var newField = dstCl.staticFields[dstCl.staticFields.length-1];
			theName = newField.name;
		}
				
		var srcCtor = getFunction(src,srcCl.constructor);
		var ctorF = mergeFunction(dst,src,srcCtor);
		
		var consField = {
			name:	publicName(dst, '__cons$_mergeI'),
			slot:	0,
			kind:	FMethod(
				ctorF.type,
				KNormal,
				false,
				false
			),
			metadatas:	null,
		};
		_mergeI++;
		
		dstCl.fields.push(consField);
		
		
		/*var sField = {
			name: publicName(dst, "__a"),
			slot: 1,
			kind: FVar( publicName(dst, "Object") ),
			metadatas: null,
		};
		dstCl.staticFields.push(sField);*/
		
		var dstCtor = getFunction(dst,dstCl.constructor);
		var o = new BytesOutput();
		encodeOps(o, [
			OThis,
			OCallPropVoid(consField.name, 0),
			/*OThis,
			OScope,
			OFindPropStrict(publicName(dst, "trace")),
			OString(string(dst, "InjectCtor")),
			OCallPropVoid(publicName(dst,"trace"),1),
			OPopScope,*/
		]);
		o.write(dstCtor.code);
		dstCtor.code = o.getBytes();
		
		//trace("NEW");
		//trace( dumpAbc(dst) );
	}
	
	private static function countSlots(abc : ABCData, cl : ClassDef) {
		var maxSlot = 0;
		for(field in cl.staticFields) {
			if(field.slot > maxSlot) maxSlot = field.slot;
		}
		
		for(field in cl.fields) {
			if(field.slot > maxSlot) maxSlot = field.slot;
		}
		
		return maxSlot;
	}
	
	private static function mergeField(dst : ABCData, src : ABCData, srcField : Field, ?slotOffset : Int = 0) {
		var newKind = switch(srcField.kind) {
			case FVar(type, value, const):
				FVar(
					if(type != null) mergeName(dst,src,type) else null,
					if(value != null) mergeValue(dst,src,value) else null,
					const
				);
				
			case FMethod(type, kind, isFinal, isOverride):
				var newF = mergeFunction(dst,src,getFunction(src,type));
				FMethod(
					newF.type,
					kind,
					isFinal,
					isOverride
				);
				
			case FClass(_):
				throw("TODO FClass");
			
			case FFunction(_):
				throw("TODO FFunction");
			
		}
		
		var newField = {
			name: mergeName(dst,src,srcField.name),
			slot: if(srcField.slot > 0) srcField.slot + slotOffset else 0,
			kind: newKind,
			metadatas: null,
		};
		
		return newField;
	}
	
	private static function mergeValue(dst : ABCData, src : ABCData, v : Value ) : Value {
		return switch(v) {
			case VNull:			VNull;
			case VBool(b):		VBool(b);
			case VString(s):	VString( mergeString(dst,src,s) );
			case VInt(i):		VInt( mergeInt(dst,src,i) );
			case VUInt(i):		VUInt( mergeUInt(dst,src,i) );
			case VFloat(f):		VFloat( mergeFloat(dst,src,f) );
			case VNamespace(k,ns): VNamespace(k, mergeNamespace(dst,src,ns));
		};
	}
	
	private static function mergeInt(dst : ABCData, src : ABCData, i) {
		if(Type.enumEq(i,Idx(0))) return i;
		return int(dst, getInt(src, i));
	}
	
	private static function mergeUInt(dst : ABCData, src : ABCData, i) {
		if(Type.enumEq(i,Idx(0))) return i;
		return uint(dst, getUInt(src, i));
	}
	
	private static function mergeFloat(dst : ABCData, src : ABCData, i : Index<Float>) : Index<Float> {
		if(Type.enumEq(i,Idx(0))) return i;
		return float(dst, getFloat(src, i));
	}
	
	private static function mergeFunction(dst : ABCData, src : ABCData, srcF : Function) : Function {
		var newLocals = new Array();
		for(field in srcF.locals) {
			newLocals.push( mergeField(dst,src,field) );
		}
		
		var newTrys = new Array();
		for(i in 0...srcF.trys.length) {
			var t = srcF.trys[i];
			newTrys.push({
				start:	t.start,
				end:	t.end,
				handle:	t.handle,
				type:	if(t.type != null) mergeName(dst, src, t.type) else null,
				variable: if(t.variable != null) mergeName(dst, src, t.variable) else null,
			});
		}
		
		var ops = format.abc.OpReader.decode(new BytesInput(srcF.code));
		for(i in 0...ops.length) {
			ops[i] = switch(ops[i]) {
				case OGetSuper(n):				OGetSuper( mergeName(dst,src,n) );
				case OSetSuper(n):				OSetSuper( mergeName(dst,src,n) );
				case ODxNs(s):					ODxNs( mergeString(dst,src,s) );
				case OString(s):				OString( mergeString(dst,src,s) );
				case OIntRef(i):				OIntRef( mergeInt(dst,src,i) );
				case OUIntRef(i):				OUIntRef( mergeUInt(dst,src,i) );
				case OFloat(f):					OFloat( mergeFloat(dst,src,f) );
				case ONamespace(ns):			ONamespace( mergeNamespace(dst,src,ns) );
				case OFunction(m):				OFunction( mergeMethodType(dst,src,m) );
				case OCallStatic(m,i): 			OCallStatic( mergeMethodType(dst,src,m), i);
				case OCallSuper(n,i):			OCallSuper( mergeName(dst,src,n), i );
				case OCallProperty(n,i):		OCallProperty( mergeName(dst,src,n), i );
				case OConstructProperty(n,i):	OConstructProperty( mergeName(dst,src,n), i );
				case OCallPropLex(n,i):			OCallPropLex( mergeName(dst,src,n), i );
				case OCallSuperVoid(n,i):		OCallSuperVoid( mergeName(dst,src,n), i );
				case OCallPropVoid(n,i):		OCallPropVoid( mergeName(dst,src,n), i );
				case OClassDef(c):				throw("TODO OClassDef"); null;
				case OGetDescendants(n):		OGetDescendants( mergeName(dst,src,n) );
				case OFindPropStrict(n):		OFindPropStrict( mergeName(dst,src,n) );
				case OFindProp(n):				OFindProp( mergeName(dst,src,n) );
				case OFindDefinition(n):		OFindDefinition( mergeName(dst,src,n) );
				case OGetLex(n):				OGetLex( mergeName(dst,src,n) );
				case OSetProp(n):				OSetProp( mergeName(dst,src,n) );
				case OGetProp(n):				OGetProp( mergeName(dst,src,n) );
				case OInitProp(n):				OInitProp( mergeName(dst,src,n) );
				case ODeleteProp(n):			ODeleteProp( mergeName(dst,src,n) );
				case OCast(n):					OCast( mergeName(dst,src,n) );
				case OAsType(n):				OAsType( mergeName(dst,src,n) );
				case OIsType(n):				OIsType( mergeName(dst,src,n) );
				case ODebugReg(s,r,l):			ODebugReg( mergeString(dst,src,s), r, l );
				case ODebugFile(s):				ODebugFile( mergeString(dst,src,s) );
				default: ops[i];
			}
		}
		var o = new BytesOutput();
		encodeOps(o, ops);
		
		var newF = {
			type:		mergeMethodType(dst, src, srcF.type),
			maxStack:	srcF.maxStack,
			nRegs:		srcF.nRegs,
			initScope:	srcF.initScope,
			maxScope:	srcF.maxScope,
			code:		o.getBytes(),
			locals:		newLocals,
			trys:		newTrys,
		}
		
		dst.functions.push(newF);
		return newF;
	}
	
	private static function mergeMethodType(dst : ABCData, src : ABCData, i : Index<MethodType>) : Index<MethodType> {
		var m = getMethodType(src,i);
		var newArgs = new Array();
		for(arg in m.args) {
			newArgs.push( if(arg != null) mergeName(dst,src,arg) else null );
		}
		
		var newExtra = null;
		if(m.extra != null) {
			var newDParams = null;
			if(m.extra.defaultParameters != null) {
				newDParams = new Array();
				for(v in m.extra.defaultParameters) {
					newDParams.push( mergeValue(dst,src,v) );
				}
			}
			
			var newParamNames = null;
			if(m.extra.paramNames != null) {
				newParamNames = new Array();
				for(p in m.extra.paramNames) {
					newParamNames.push( if(p != null) mergeString(dst,src,p) else null );
				}
			}
			
			newExtra = {
				native:				m.extra.native,
				variableArgs:		m.extra.variableArgs,
				argumentsDefined:	m.extra.native,
				usesDXNS:			m.extra.usesDXNS,
				newBlocK:			m.extra.newBlock,
				unused:				m.extra.unused,
				debugName:			if(m.extra.debugName != null) mergeString(dst,src,m.extra.debugName) else null,
				defaultParameters:	newDParams,
				paramNames:			newParamNames,
			};
		}
		
		return methodType(dst,{
			args:	newArgs,
			ret:	if(m.ret != null) mergeName(dst,src,m.ret) else null,
			extra:	null,
		});
	}
	
	private static function mergeName(dst : ABCData, src : ABCData, i : IName) : IName {
		if(Type.enumEq(i,Idx(0))) return i;
		return switch(getName(src,i)) {
			case NName(n,ns):			name( dst, NName( mergeString(dst,src,n), mergeNamespace(dst,src,ns) ) );
			case NMulti(n,nsset):		name( dst, NMulti( mergeString(dst,src,n), mergeNamespaceSet(dst,src,nsset) ) );
			case NRuntime(n):			name( dst, NRuntime( mergeString(dst,src,n) ) );
			case NRuntimeLate:			name( dst, NRuntimeLate );
			case NMultiLate(nsset):		name( dst, NMultiLate( mergeNamespaceSet(dst,src,nsset) ) );
			case NAttrib(n):			name( dst, NAttrib(n) ); throw("TODO");
			case NParams(n, params):
				throw("TODO???");
		}
	}
	
	private static function mergeNamespace(dst : ABCData, src : ABCData, i : Index<Namespace>) : Index<Namespace> {
		if(Type.enumEq(i,Idx(0))) return i;
		return switch(getNamespace(src,i)) {
			case NPrivate(ns):			namespace( dst, NPrivate(mergeString(dst,src,ns)) );
			case NNamespace(ns):		namespace( dst, NNamespace(mergeString(dst,src,ns)) );
			case NPublic(ns):			namespace( dst, NPublic(mergeString(dst,src,ns)) );
			case NInternal(ns):			namespace( dst, NInternal(mergeString(dst,src,ns)) );
			case NProtected(ns):		namespace( dst, NProtected(mergeString(dst,src,ns)) );
			case NExplicit(ns):			namespace( dst, NExplicit(mergeString(dst,src,ns)) );
			case NStaticProtected(ns):	namespace( dst, NStaticProtected(mergeString(dst,src,ns)) );
		}
	}
	
	private static function mergeNamespaceSet(dst : ABCData, src : ABCData, i : Index<NamespaceSet>) : Index<NamespaceSet> {
		if(Type.enumEq(i,Idx(0))) return i;
		var nsset = getNamespaceSet(src,i);
		var newNsset = new Array();
		for(ns in nsset) newNsset.push( mergeNamespace(dst,src,ns) );
		return namespaceSet( dst,newNsset );
	}
	
	private static function mergeString(dst : ABCData, src : ABCData, s : Index<String>) : Index<String> {
		if(Type.enumEq(s,Idx(0))) return s;
		return string(dst, getString(src,s));
	}
	
	public static function getNamePath(abc : ABCData, i : IName) : String {
		var multiname = getName(abc, i);
		return switch( multiname ) {
			case NName(n, ns):
				var p = getNamespaceStr(abc, ns);
				return (p != null && p != "" ? p + "." : "") + getString(abc, n);
			
			case NMulti(n, nsset):
				var nses = getNamespaceSet(abc, nsset);
				var str="NMulti: [";
				for(ns in nses) {
					var p = getNamespaceStr(abc, ns);
					str+=p+",";
				}
				str += "]." + getString(abc, n);
				return str;
				
			default:
				//throw("Unexpected name");
				return Std.string(multiname);
		}
	}
	
	public static function publicToInternalNs(abc : ABCData, i : IName) : Index<Namespace> {
		return switch( getName(abc, i) ) {
			case NName(_, ns):
				switch(getNamespace(abc, ns)) {
					case NPublic(ns):	return namespace(abc, NInternal(ns));
					default:			throw("Unexpected namespace");
				}
				
			default:
				throw("Unexpected name");
		}
	}
	
	public static function prependOps(f : Function, ops : Array<OpCode>) {
		var oldLength = f.code.length;
		var o = new haxe.io.BytesOutput();
		encodeOps(o, ops);
		o.write(f.code);
		f.code = o.getBytes();
		var offset = f.code.length - oldLength;
		for(t in f.trys) {
			t.start += offset;
			t.end += offset;
			t.handle += offset;
		}
	}
	
	public static function appendOps(f : Function, ops : Array<OpCode>) {
		var o = new haxe.io.BytesOutput();
		o.writeBytes(f.code, 0, f.code.length-1);
		encodeOps(o, ops);
		f.code = o.getBytes();
	}
	
	public static function encodeOps( o : haxe.io.BytesOutput, ops : Array<OpCode> ) {
		var opWriter = new OpWriter(o);
		for( op in ops ) opWriter.write(op);
	}
	
	public static function getClassPath(abc : ABCData, classPath : String) {
		var pack = classPath.split(".");
		var className = pack.pop();
		for (cl in abc.classes) {
			if (getNamePath(abc, cl.name) == classPath) return cl;
		}
		return null;
	}
	
	public static function quickMethod(abc : ABCData, cl : ClassDef, methodName : IName, ops : Array<OpCode>, ?kind : MethodKind, ?args : Null<Array<IName>>, ?ret : Null<IName>, ?isOverride : Bool = false) : Function {
		var o = new haxe.io.BytesOutput();
		// MIKE NEW:
		var opWriter = new OpWriter(o);
		for(op in ops) opWriter.write(op);
		
		var f = {
			type:		methodType(abc, { args : args == null ? [] : args, ret : ret, extra : null }),
			nRegs:		if(args != null) args.length + 1 else 1,
			initScope:	0,
			maxScope:	255,
			maxStack:	255,
			code:		o.getBytes(),
			trys:		[],
			locals:		[]
		};
		
		abc.functions.push(f);
		
		var field = {
			name: methodName,
			slot: 0,
			kind: FMethod(f.type, if(kind != null) kind else KNormal, false, isOverride),
			metadatas: null,
		};
		
		cl.fields.push(field);
		
		return f;
	}
	
	
}