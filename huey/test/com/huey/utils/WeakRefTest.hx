package com.huey.utils;
import com.huey.tests.TestSuite;
import com.huey.utils.WeakRef;

/**
 * ...
 * @author Newgrounds.com, Inc.
 */

class WeakRefTest extends TestSuite
{
	@test public function testWeakRef() {
		var ref = new WeakRef<Dynamic>( {foo: 1, bar: 2} );
		assertEqual(1, ref.get().foo);
	}
	
	#if flash9
	@asyncTest public function testWeakRefGC() {
		var ref = new WeakRef<Dynamic>( {foo: 1, bar: 2} );
		flash.system.System.gc();

		haxe.Timer.delay(
			function() {
				assertNull(ref.get(), "Weak reference was not garbage collected.");
				pass();
			},
			100
		);
	}
	#end
}