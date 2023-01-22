package utils;

#if FEATURE_MULTITHREADING
import sys.thread.Thread;

class ThreadUtil 
{
    private static var threadCount = 0;
    public static function runTaskAsync(task:Void->Void)
    {
        var thread = Main.gameThreads[threadCount++ % Main.gameThreads.length];
        if (thread.isReserved) runTaskAsync(task);
    }

    public static function runReservedTask(threadName:String, task:Void->Void)
    {
        for (thread in Main.gameThreads)
        {
            if (thread.isReserved && thread.threadName == threadName)
            {
                return thread.doTask(task);
            }
        }
    }
}
#end

class ThreadObject
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

    public function doTask(func:Void->Void) {
        return thread.events.run(func);
    }
}