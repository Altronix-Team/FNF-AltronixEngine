package scriptStuff;

#if FEATURE_MODCORE
import scriptStuff.scriptBodies.ScriptBody;
#end
import gameplayStuff.Section.SwagSection;
@:allow(states.PlayState)
class ScriptHelper
{
	public static var hscriptFiles:Array<Dynamic> = []; //Old Hscript format

	#if FEATURE_MODCORE
	public static var allHscriptFiles:Array<IScript> = []; //Handle basic stuff, such as beat, step and section hit and update
	#end

	public static function clearAllScripts()
	{
		#if FEATURE_MODCORE
		for (script in allHscriptFiles)
		{
			if (!script.isGlobal)
			{
				allHscriptFiles.remove(script);
				script.destroy();
			}	
		}
		#end
		hscriptFiles = [];
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

	public static function stepHit(step:Int)
	{
		callOnScripts('onStepHit', []);

		#if FEATURE_MODCORE
		for (script in allHscriptFiles)
		{
			script.stepHit(step);
		}
		#end
	}

	public static function beatHit(beat:Int)
	{
		callOnScripts('onBeatHit', []);
		#if FEATURE_MODCORE
		for (script in allHscriptFiles)
		{
			script.beatHit(beat);
		}
		#end
	}

	public static function sectionHit(section:SwagSection)
	{
		callOnScripts('onSectionHit', []);
		#if FEATURE_MODCORE
		for (script in allHscriptFiles)
		{
			script.sectionHit(section);
		}
		#end
	}

	public static function update(elapsed:Float)
	{
		#if FEATURE_MODCORE
		for (script in allHscriptFiles)
		{
			script.update(elapsed);
		}
		#end
	}
}
