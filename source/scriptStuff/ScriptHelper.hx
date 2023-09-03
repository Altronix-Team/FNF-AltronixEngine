package scriptStuff;

import sys.thread.Thread;
import gameplayStuff.Section.SwagSection;

@:allow(states.PlayState)
class ScriptHelper
{
	public static var hscriptFiles:Array<HScriptModchart> = [];

	public static function clearAllScripts()
	{
		Thread.create(function() {
			for (script in hscriptFiles){
				hscriptFiles.remove(script);
				script.destroy();
			}
		});
	}

	public static function setOnHscript(name:String, value:Dynamic)
	{
		Thread.create(function() {
			for (script in hscriptFiles)
			{
				script.scriptHandler.set(name, value);
			}
		});
	}

	public static function callOnHscript(functionToCall:String, ?params:Array<Any>)
	{
		Thread.create(function() {
			for (script in hscriptFiles)
			{
				var scriptHelper = script.scriptHandler;
				if (scriptHelper.exists(functionToCall))
				{
					scriptHelper.call(functionToCall, params);
				}
			}
		});
	}

	public static function isFunctionExists(funcName:String):Bool
	{
		var retVal = false;
		for (script in hscriptFiles)
		{
			var scriptHelper = script.scriptHandler;
			if (scriptHelper.exists(funcName))
				retVal = true;
		}
		return retVal;
	}

	public static function stepHit(step:Int)
	{
		callOnHscript('onStepHit', []);
	}

	public static function beatHit(beat:Int)
	{
		callOnHscript('onBeatHit', []);
	}

	public static function sectionHit(section:SwagSection)
	{
		callOnHscript('onSectionHit', []);
	}
}
