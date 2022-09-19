package scriptStuff;

import scriptStuff.FunkinLua;
@:allow(states.PlayState)
class ScriptHelper
{
	public static var hscriptFiles:Array<HScriptModchart> = [];
	public static var luaArray:Array<FunkinLua> = [];

	public static function clearAllScripts()
	{
		hscriptFiles = [];
		luaArray = [];
	}

	public static function setOnScripts(name:String, value:Dynamic)
	{
		setOnHscript(name, value);
		setOnLuas(name, value);
	}

	public static function callOnScripts(functionToCall:String, args:Array<Dynamic>):Dynamic {
		callOnHscript(functionToCall, args);
		return callOnLuas(functionToCall, args);
	}

	public static function setOnHscript(name:String, value:Dynamic)
	{
		for (script in hscriptFiles)
		{
			script.set(name, value);
		}
	}

	public static function callOnHscript(functionToCall:String, ?params:Array<Any>)
	{
		for (script in hscriptFiles)
		{
			var scriptHelper = script.scriptHelper;
			scriptHelper.call(functionToCall, params);
		}
	}

	private static var preventLuaRemove:Bool = false;

	public static function removeLua(lua:FunkinLua)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	public static var closeLuas:Array<FunkinLua> = [];

	public static function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = false, ?exclusions:Array<String>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		if (exclusions == null)
			exclusions = [];
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			if (exclusions.contains(luaArray[i].scriptName))
			{
				continue;
			}
			var ret:Dynamic = luaArray[i].call(event, args);
			if (ret == FunkinLua.Function_StopLua)
			{
				if (ignoreStops)
					ret = FunkinLua.Function_Continue;
				else
					break;
			}

			if (ret != FunkinLua.Function_Continue)
			{
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length)
		{
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public static function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}
}