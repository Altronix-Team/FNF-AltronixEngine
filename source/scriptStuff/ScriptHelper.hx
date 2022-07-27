package scriptStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import Paths;
import gameplayStuff.Conductor;
import openfl.Assets as OpenFlAssets;

class ScriptException extends Exception {}

class ScriptHelper
{
    public var expose:StringMap<Dynamic>;
	
	var parser:Parser;
    var interp:Interp;

    var ast:Expr;
    
    public function new()
    {        
        parser = new Parser();
        interp = new Interp();

        parser.allowTypes = true;

		expose = new StringMap<Dynamic>();

		expose.set("Sys", Sys);
		expose.set("Std", Std);
		expose.set("Math", Math);
		expose.set("StringTools", StringTools);
		expose.set("FlxMath", FlxMath);
		expose.set("Conductor", Conductor);
		expose.set('Debug', Debug);
		expose.set('Paths', Paths);
		expose.set('PlayState', states.PlayState);
		
		expose.set("loadModule", loadModule);
		expose.set("createSprite", createSprite);
		expose.set("getGraphic", getGraphic);
		expose.set("playSound", playSound);
		expose.set("lazyPlaySound", lazyPlaySound);
		expose.set("createTimer", createTimer);

		expose.set("getSparrowAtlas", Paths.getSparrowAtlas);
    }

    public function get(field:String):Dynamic
        return interp.variables.get(field);

    public function set(field:String, value:Dynamic)
        interp.variables.set(field, value);

    public function exists(field:String):Bool
        return interp.variables.exists(field);

    public function loadScript(path:String, execute:Bool = true)
    {
        if (path != "")
        {
			if (OpenFlAssets.exists(path))
            {
                try
                {
					ast = parser.parseString(OpenFlAssets.getText(path), path);
					
					for (v in expose.keys())
						interp.variables.set(v, expose.get(v));
					
                    if (execute)
                        interp.execute(ast);
                }
                catch (e:Error)
                {
                    throw new ScriptException("Script parse error:\n" + e);
                }
            }
			else if (OpenFlAssets.exists(OpenFlAssets.getPath(path)))
			{
				try
				{
					ast = parser.parseString(OpenFlAssets.getText(OpenFlAssets.getPath(path)), path);

					for (v in expose.keys())
						interp.variables.set(v, expose.get(v));

					if (execute)
						interp.execute(ast);
				}
				catch (e:Error)
				{
					throw new ScriptException("Script parse error:\n" + e);
				}
			}
            else
            {
				throw new ScriptException("Cannot locate script file in " + path);
            }
        }
        else
        {
			throw new ScriptException("Path is empty!");
        }
    }

	function loadModule(path:String):Dynamic
	{
		if (path != "")
		{
			if (OpenFlAssets.exists(path))
			{
				try
				{
					var moduleInterp = new Interp();
					var moduleAst = parser.parseString(OpenFlAssets.getText(path), path);

					for (v in expose.keys())
						moduleInterp.variables.set(v, expose.get(v));

					moduleInterp.execute(moduleAst);

					var module:Dynamic = {};

					for (v in moduleInterp.variables.keys())
					{
						switch (v)
						{
							case "null", "true", "false", "trace": {/* Does nothing */}
							default:
								Reflect.setField(module, v, moduleInterp.variables.get(v));
						}
					}

					return module;
				}
				catch (e:Error)
				{
					throw new ScriptException("Module parse error:\n" + e);
				}
			}
			else if (OpenFlAssets.exists(OpenFlAssets.getPath(path)))
			{
				try
				{
					var moduleInterp = new Interp();
					var moduleAst = parser.parseString(OpenFlAssets.getText(OpenFlAssets.getPath(path)), path);

					for (v in expose.keys())
						moduleInterp.variables.set(v, expose.get(v));

					moduleInterp.execute(moduleAst);

					var module:Dynamic = {};

					for (v in moduleInterp.variables.keys())
					{
						switch (v)
						{
							case "null", "true", "false", "trace":
								{/* Does nothing */}
							default:
								Reflect.setField(module, v, moduleInterp.variables.get(v));
						}
					}

					return module;
				}
				catch (e:Error)
				{
					throw new ScriptException("Module parse error:\n" + e);
				}
			}
			else
			{
				throw new ScriptException("Cannot locate module file in " + path);
			}
		}
		else
		{
			throw new ScriptException("Path is empty!");
		}
	}

	function createSprite(x:Float, y:Float):FlxSprite
	{
		var sprite = new FlxSprite(x, y);
		return sprite;
	}

	function getGraphic(path:String):FlxGraphic
	{
		return Paths.loadImage(path);
	}

	function playSound(path:String, group:String = ""):FlxSound
	{
		return FlxG.sound.play(Paths.getAsset(path, SOUND, group));
	}

	function lazyPlaySound(path:String, group:String = "")
	{
		FlxG.sound.play(Paths.getAsset(path, SOUND, group));
	}

	function createTimer():FlxTimer
	{
		return new FlxTimer();
	}
}