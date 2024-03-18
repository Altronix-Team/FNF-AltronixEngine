package altronixengine.core;

import haxe.CallStack;
import altronixengine.utils.Debug.DebugLogWriter;
import lime.app.Application;
import sys.io.Process;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

class CrashHandler {
    public function new() {
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#end
    }

    static final ERROR_REPORT_URL = "https://github.com/AltronMaxX/FNF-AltronixEngine";

    var funnyTitle:Array<String> = [
        'Fatal Error!',
        'Monika deleted everything!',
        'Catastrophic Error',
        'Well-well-well, what have we got here?',
        'Game over',
        'Kade Engine moment',
        'Tester couldn`t find it'
    ];

	private function onUncaughtError(error:UncaughtErrorEvent)
	{
        onError(error.error);
	}

	private function onError(message:String):Void
	{
        FlxG.resetGame();
		#if FEATURE_FILESYSTEM
		var errorMsg:String = prepareErrorMsg();

		errorMsg += '==========STACK TRACE==========\n';
		errorMsg += message + '\n';

		var errorCallStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (line in errorCallStack)
		{
			switch (line)
			{
				case CFunction:
					errorMsg += '  function:\n';
				case Module(m):
					errorMsg += '  module:${m}\n';
				case FilePos(s, file, line, column):
					errorMsg += '  (${file}#${line},${column})\n';
				case Method(className, method):
					errorMsg += '  method:(${className}/${method}\n';
				case LocalFunction(v):
					errorMsg += '  localFunction:${v}\n';
				default:
					errorMsg += line;
			}
		}
		errorMsg += '\n';

		var logFolderPath = CoolUtil.createDirectoryIfNotExists('crashes');

		var path:String = '${logFolderPath}/Altronix Engine - ${DebugLogWriter.getDateString()}.txt';

		sys.io.File.saveContent(path, errorMsg + "\n");

		errorMsg += 'An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n'
			+ ERROR_REPORT_URL
			+ '\n';

		Application.current.window.alert('An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n'
			+ ERROR_REPORT_URL,
			funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);

		try
		{
			new Process(path);
		}
		#else
		Application.current.window.alert('An error has occurred and the game is forced to close.\nWe cannot write a log file though. Tell the developers:\n'
			+ ERROR_REPORT_URL,
			funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);
		#end
	}

    private function prepareErrorMsg(){
        var errorMsg:String = '';

		errorMsg += '==========FATAL ERROR==========\n';
		errorMsg += 'An uncaught error was thrown, and the game had to close.\n';
		errorMsg += 'Please use the link below, create a new issue, and upload this file to report the error.\n';
		errorMsg += '\n';
		errorMsg += ERROR_REPORT_URL;
		errorMsg += '\n';

		errorMsg += '==========SYSTEM INFO==========\n';
		errorMsg += 'Altronix Engine version: ${EngineConstants.engineVer}\n';
		errorMsg += '\tHaxeFlixel version: ${Std.string(FlxG.VERSION)}\n';
		errorMsg += '\tFriday Night Funkin\' version: ${altronixengine.states.MainMenuState.gameVer}\n';
		errorMsg += 'System telemetry:\n';

        return errorMsg;
    }
}