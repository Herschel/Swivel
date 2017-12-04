package com.huey.macros;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class MacroTools
{
	public static function extractString(expr : Expr) : String {
		switch(expr.expr) {
			case EConst(c):
				switch(c) {
					case CString(s):	return s;
					default:
				}
			default:
		}
		return null;
	}

	inline public static function extractIdentifier(expr : Expr) : String {
		switch(expr.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(s):		return s;
					default:
				}
			default:
		}
		
		throw "Expression is not an identifier.";
		return null;
	}
	
	inline public static function getVar(fields : Array<Field>, name : String) {
		for (field in fields) {
			if (field.name == name) {
				switch(field.kind) {
					case FVar(_, _):	return field.kind;
					default:
				}
			}
		}
		
		return null;
	}
	
	inline public static function hasVar(fields : Array<Field>, name : String) : Bool {
		for (field in fields) {
			if (field.name == name) {
				switch(field.kind) {
					case FVar(_, _):	return true;
					default:
				}
			}
		}
		
		return false;
	}
	
	inline public static function getMeta(field : Field, name : String) : Array<Expr> {
		var ret = null;
		for (m in field.meta) {
			if (m.name == name) ret = m.params;
		}
		
		return ret;
	}
	
	inline public static function hasMeta(field : Field, name : String) : Bool {
		return getMeta(field, name) != null;
	}

	public static function cocnatExpr(e1 : Expr, e2 : Expr) : Expr {
		return {expr: EBlock([e1, e2]), pos: e1.pos};
	}
	
	public static function mapExpr(expr : Expr, f : ExprDef->ExprDef) : Void {
		if (expr == null) return;
		var replaceExpr : ExprDef = f(expr.expr);

		if(replaceExpr == null) {
			switch(expr.expr) {
				case EArray(e1, e2):
					mapExpr(e1, f);
					mapExpr(e2, f);
				
				case EArrayDecl(values):
					for (e in values) mapExpr(e, f);
				
				case EBinop(op, e1, e2):
					mapExpr(e1, f);
					mapExpr(e2, f);
				
				case EBlock(es):
					for (e in es) mapExpr(e, f);

				case EBreak:
					
				case ECall(e, params):
					mapExpr(e, f);
					for (e in params) mapExpr(e, f);
				
				case ECast(e, t):
					mapExpr(e, f);
					
				case ECheckType(e, t):
					mapExpr(e, f);
					
				case EConst(c):
				
				case EContinue:
				
				case EDisplay(e, isCall):
					mapExpr(e, f);
					
				case EDisplayNew(t):
				
				case EField(e, field):
					mapExpr(e, f);
				
				case EFor(it, e):
					mapExpr(it, f);
					mapExpr(e, f);
				
				case EFunction(name, func):
					mapExpr(func.expr, f);
				
				case EIf(econd, eif, eelse):
					mapExpr(econd, f);
					mapExpr(eif, f);
					mapExpr(eelse, f);
				
				case EIn(e1, e2):
					mapExpr(e1, f);
					mapExpr(e2, f);
				
				case ENew(t, params):
					for (e in params) mapExpr(e, f);
					
				case EObjectDecl(fields):
					for (field in fields) mapExpr(field.expr, f);
				
				case EParenthesis(e):
					mapExpr(e, f);
					
				case EReturn(e):
					if (e != null) mapExpr(e, f);
					
				case ESwitch(e, cases, edef):
					mapExpr(e, f);
					for (c in cases) mapExpr(c.expr, f);
					if (edef != null) mapExpr(edef, f);
					
				case ETernary(econd, eif, eelse):
					mapExpr(econd, f);
					mapExpr(eif, f);
					mapExpr(eelse, f);
				
				case EThrow(e):
					mapExpr(e, f);
					
				case ETry(e, catches):
					mapExpr(e, f);
					for (c in catches)
						mapExpr(c.expr, f);
					
				case EUnop(op, postFix, e):
					mapExpr(e, f);
					
				case EUntyped(e):
					mapExpr(e, f);
					
				case EVars(vars):
					for (v in vars)
						if (v.expr != null) mapExpr(v.expr, f);

				case EWhile(econd, e, normalWhile):
					mapExpr(econd, f);
					mapExpr(e, f);
					
				default:
			}
		} else { expr.expr = replaceExpr; }
	}
	
	public static function concatExpr(e1 : Expr, e2 : Expr) : Expr {
		var out = switch(e1.expr) {
			case EBlock(es):	es;
			default:			[e1];
		}
		
		out.concat( switch(e2.expr) {
			case EBlock(es):	es;
			default:			[e2];
		} );
		
		// TODO: smarter position?
		return {expr: EBlock(out), pos: e1.pos};
	}
	
}