package utils;

import sys.thread.Thread;

class ThreadUtil
{
	public static function runTaskAsync(task:Void->Void, ?callback:Dynamic->Void)
	{
		#if FEATURE_MULTITHREADING
		try
		{
			Main.threadPool.queue(task);

			if (callback != null)
				Main.threadPool.onComplete.add(callback, true);
		}
		catch (e)
		{
			Debug.logError('Failed to run task async!');
			task();
		}
		#else
		task();
		#end
	}

	public static function runReservedTask(threadName:String, task:Void->Void)
	{
		#if FEATURE_MULTITHREADING
		for (thread in Main.reservedGameThreads)
		{
			if (thread.isReserved && thread.threadName == threadName)
			{
				return thread.doTask(task);
			}
		}
		#else
		task();
		#end
	}
}

class ReservedThreadObject
{
	public var thread:Thread;
	public var isReserved:Bool = false;

	public var threadName:Null<String> = null;

	public function new(?isReserved:Bool = false, ?threadName:Null<String> = null)
	{
		thread = Thread.createWithEventLoop(function()
		{
			Thread.current().events.promise();
		});

		this.isReserved = isReserved;
		this.threadName = threadName;
	}

	public function doTask(func:Void->Void)
	{
		return thread.events.run(func);
	}
}
