package scriptStuff;

import gameplayStuff.Section.SwagSection;

@:allow(states.PlayState)
class ScriptHelper
{
	public static var hscriptFiles:Array<Dynamic> = [];

	public static function clearAllScripts()
	{
		hscriptFiles = [];
		Debug.logInfo('Cleared all scripts');
	}

	public static function setOnScripts(name:String, value:Dynamic)
	{
		setOnHscript(name, value);
	}

	public static function callOnScripts(functionToCall:String, args:Array<Dynamic>):Dynamic
	{
		return callOnHscript(functionToCall, args);
	}

	public static function setOnHscript(name:String, value:Dynamic)
	{
		for (script in hscriptFiles)
		{
			script.scriptHandler.set(name, value);
		}
	}

	public static function callOnHscript(functionToCall:String, ?params:Array<Any>):Dynamic
	{
		var retVal = false;
		for (script in hscriptFiles)
		{
			var scriptHelper = script.scriptHandler;
			if (scriptHelper.exists(functionToCall))
			{
				if (scriptHelper.call(functionToCall, params) != null)
					retVal = true;
			}
		}
		return retVal;
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
		callOnScripts('onStepHit', []);
	}

	public static function beatHit(beat:Int)
	{
		callOnScripts('onBeatHit', []);
	}

	public static function sectionHit(section:SwagSection)
	{
		callOnScripts('onSectionHit', []);
	}
}
