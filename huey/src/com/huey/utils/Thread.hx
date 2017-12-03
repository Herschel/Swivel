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

	public static var current(getCurrentThread, null) : Thread;
	private static function getCurrentThread() : Thread {
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