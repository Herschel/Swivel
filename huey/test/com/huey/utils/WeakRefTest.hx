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

package com.huey.utils;
import com.huey.tests.TestSuite;
import com.huey.utils.WeakRef;

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