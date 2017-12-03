package com.huey.tests;
import com.huey.macros.MacroTools;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

@:macro class TestBuilder {
	public static function buildTestSuite() : Array<Field> {
		var cl = Context.getLocalClass().get();
		var fields : Array<Field> = Context.getBuildFields();
		var pos = Context.currentPos();
		
		var testMethods : List<String> = new List();
		var asyncTestMethods : List<String> = new List();
		
		var newExprs : Array<Expr>;

		function wrapAsync(expr) {
			switch(expr) {
				/*case ECall(e, args):
					switch(Context.typeof(e)) {
						case TFun(_, _):
							return
								ECall(
									{pos: pos, expr: EField(
										{pos: pos, expr: EConst(CIdent("async")) },
										"wrapAsync")
									},
								[ e ]);
								
						default:
					}*/
					
				case EFunction(name, _):
					if (name == null)
						return
							ECall(
								{pos: pos, expr: EField(
									{pos: pos, expr: EConst(CIdent("async")) },
									"wrapAsync")
								},
							[{expr: expr, pos: pos}]);
				default:
			}
			
			return null;
		}
	
		for (field in fields) {
			switch(field.kind) {
				case FFun(f):
					if (field.name == "new") {
						switch(f.expr.expr) {
							case EBlock(e):	newExprs = e;
							default:		Context.error("Expected EBlock for constructor", pos);
						}
					} else {
						for (meta in field.meta) {
							if (meta.name == "test") testMethods.add(field.name);
							else if (meta.name == "asyncTest") {
								f.args.push( { name: "async", opt: false, type: null, value: null } );
								asyncTestMethods.add(field.name);
								MacroTools.mapExpr(f.expr, wrapAsync);
							}
						}
					}
				default:
			}
		}
		
		if (newExprs == null) {
			newExprs = [ Context.parse("super()", pos) ];
			
			fields.push( {
				pos:	pos,
				name:	"new",
				meta:	[],
				access:	[APublic],
				doc:	null,
				kind:	FFun( { ret: null, params: [], args: [], expr: { expr: EBlock(newExprs), pos: pos } } )
			} );
		}

		for(method in testMethods)
			newExprs.push( Context.parse(Std.format('_tests.add(new com.huey.tests.TestCase("$method", $method))'), pos) );
		for(method in asyncTestMethods)
			newExprs.push( Context.parse(Std.format('_tests.add(new com.huey.tests.AsyncTestCase("$method", $method))'), pos) );
		
		/*for (meta in cl.meta) {
			if (meta.name == "childSuites") {
				for (child in meta.params) {
					
				}
				break;
			}
		}*/
		
		return fields;
	}
}