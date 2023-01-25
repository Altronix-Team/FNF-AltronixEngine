package scriptStuff;

@:allow(states.PlayState)
class ScriptHelper
{
	public static var hscriptFiles:Array<Dynamic> = [];

	public static function clearAllScripts()
	{
		hscriptFiles = [];
		luaArray = [];
		Debug.logInfo('Cleared all scripts');
	}

	public static function setOnScripts(name:String, value:Dynamic)
	{
		setOnHscript(name, value);
	}

	public static function callOnScripts(functionToCall:String, args:Array<Dynamic>):Dynamic {
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

	public static function stepHit()
	{
		callOnScripts('onStepHit', []);
	}

	public static function beatHit()
	{
		callOnScripts('onBeatHit', []);
	}

	public static function sectionHit()
	{
		callOnScripts('onSectionHit', []);
	}
}
