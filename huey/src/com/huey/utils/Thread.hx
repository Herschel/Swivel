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

import flash.events.Event;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;

#if flash9
class Thread {
	public var state(default, null) : ThreadState;

	private var _worker : Worker;

	// MIKE: swf width and height for flash only
	public static function spawn(entryPoint : String) : Thread {
		var thread = new Thread(WorkerDomain.current.createWorker(flash.Lib.current.loaderInfo.bytes, true));
		thread.setProperty("entryPoint", entryPoint);
		return thread;
	}

	public static var current(get, null) : Thread;
	private static function get_current() : Thread {
		if(current == null) {
			current = new Thread(Worker.current);
		}
		return current;
	}

	private function new(worker : flash.system.Worker) {
		_worker = worker;
		workerStateHandler(null);
		_worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
	}

	public function start() : Void {
		_worker.start();
	}

	public function getProperty(key : String) : Dynamic {
		return _worker.getSharedProperty(key);
	}

	public function setProperty(key : String, value : Dynamic) : Void {
		_worker.setSharedProperty(key, value);
	}

	private function workerStateHandler(e : Event) : Void {
		state = switch(_worker.state) {
			case NEW:			stopped;
			case RUNNING:		running;
			case TERMINATED:	terminated;
		}
	}
}

#else

#error Threads not implemented on this platform

#end

enum ThreadState {
	stopped;
	running;
	terminated;
}