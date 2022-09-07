package scriptStuff;

import flixel.addons.display.FlxRuntimeShader;
import states.MusicBeatState;
import flixel.FlxObject;
import flixel.text.FlxText;
import gameplayStuff.Character;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import states.GameOverSubstate;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.ds.StringMap;
import Paths;
import gameplayStuff.Conductor;
import openfl.Assets as OpenFlAssets;

//Base hscript 
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

//Hscript classes
/*import hscript.ParserEx;
import hscript.InterpEx;*/

class ScriptException extends Exception 
{
	public function new(message:String, ?previous:Exception, ?native:Any):Void
	{
		super(message, previous, native);
		Debug.displayAlert('Error with hscript file!', message);
	}
}

class ScriptHelper
{
    public var expose:StringMap<Dynamic>;
	
	var parser:Parser;
	var interp:CustomInterp;

	/*var parserEx:ParserEx;
	var interpEx:InterpEx;*/

    var ast:Expr;
    
    public function new()
    {        
        parser = new Parser();
		interp = new CustomInterp();

        parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

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
		expose.set('GameOverSubstate', GameOverSubstate);
		expose.set('FlxG', FlxG);
		expose.set('FlxSprite', FlxSprite);
		expose.set('FlxCamera', FlxCamera);
		expose.set('FlxTween', FlxTween);
		expose.set('FlxEase', FlxEase);
		expose.set('FlxText', FlxText);
		expose.set('FlxObject', FlxObject);
		expose.set('Character', Character);
		expose.set('Alphabet', Alphabet);
		expose.set('MusicBeatState', MusicBeatState);
		expose.set('WindowUtil', WindowUtil);
		expose.set('WindowShakeEvent', WindowUtil.WindowShakeEvent);

		expose.set('newType', newType);
		expose.set("loadModule", loadModule);		
		expose.set("getGraphic", getGraphic);
		expose.set("playSound", playSound);
		expose.set("lazyPlaySound", lazyPlaySound);
		expose.set("createTimer", createTimer);
		expose.set('setProperty', setProperty);
		expose.set('getProperty', getProperty);
		expose.set('getInstance', getInstance);
		expose.set('set', set);
		expose.set('get', get);
		expose.set('exists', exists);
		expose.set('getEngineFont', getEngineFont);
		//expose.set("instancePluginClass", instanceExClass);
		
		expose.set("getSparrowAtlas", Paths.getSparrowAtlas);

		expose.set('setNoteTypeTexture', setNoteTypeTexture);
		expose.set('setNoteTypeIgnore', setNoteTypeIgnore);

		//Depraceted
		expose.set("createSprite", createSprite);
		expose.set("createText", createText);
		expose.set('createRuntimeShader', createRuntimeShader);
    }

    public function get(field:String):Dynamic
        return interp.variables.get(field);

    public function set(field:String, value:Dynamic)
        interp.variables.set(field, value);

    public function exists(field:String):Bool
        return interp.variables.exists(field);

	/** Creates new class.
	 * - Works like: new FlxText(x, y, width, text, size, embedded);
	 * @param newClass The name of new class: (FlxText)
	 * @param args Array with arguments to new function: ([x, y, width, text, size, embedded])
	 **/
	public function newType(newClass:String, args:Array<Dynamic>):Dynamic
		return interp.newType(newClass, args);

    public function loadScript(path:String, execute:Bool = true)
    {
        if (path != "")
        {
			if (OpenFlAssets.exists(path))
            {
				Debug.logTrace('Found hscript');
				Debug.logTrace('At path: ' + path);
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
				Debug.logTrace('Found hscript');
				Debug.logTrace('At path: ' + OpenFlAssets.getPath(path));
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

	/*function instanceExClass(classname:String, args:Array<Dynamic> = null)
	{
		return interpEx.createScriptClassInstance(classname, args);
	}*/

	function createRuntimeShader(fragmentSource:String = null, vertexSource:String = null, glslVersion:Int = 120):FlxRuntimeShader
	{
		Debug.logWarn('Deprecated! Use newType("FlxRuntimeShader", [fragmentSource, vertexSource, glslVersion]) instead');
		var shader = new FlxRuntimeShader(fragmentSource, vertexSource, glslVersion);
		return shader;
	}

	function createText(x:Float = 0, y:Float = 0, width:Float = 0, text:String = '', size:Int = 8, embedded:Bool = true):FlxText
	{
		Debug.logWarn('Deprecated! Use newType("FlxText", [x, y, width, text, size, embedded]) instead');
		var text = new FlxText(x, y, width, text, size, embedded);
		return text;
	}

	function getEngineFont():String
	{
		if (!FlxG.save.data.language)
		{
			return Paths.font("vcr.ttf");
		}
		else
		{
			return Paths.font("UbuntuBold.ttf");
		}
	}

	function createSprite(x:Float, y:Float):FlxSprite
	{
		Debug.logWarn('Deprecated! Use newType("FlxSprite", [x, y]) instead');
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

	function setNoteTypeTexture(type:String, texture:String)
	{
		states.PlayState.instance.setNoteTypeTexture(type, texture);
	}

	function setNoteTypeIgnore(type:String, ignore:Bool)
	{
		states.PlayState.instance.setNoteTypeIgnore(type, ignore);
	}

	function getProperty(instance:Null<Dynamic> = null, variable:String):Any { //Copy from lua
		if (instance == null)
			return Reflect.getProperty(getInstance(), variable);
		else
			return Reflect.getProperty(instance, variable);
	}

	function setProperty(instance:Null<Dynamic> = null, variable:String, value:Dynamic) { // Copy from lua
		if (instance == null)
			Reflect.setProperty(getInstance(), variable, value);
		else
			Reflect.setProperty(instance, variable, value);
	}

	function getInstance() { //Copy from lua
		return states.PlayState.instance.isDead ? states.GameOverSubstate.instance : states.PlayState.instance;
	}
}

class CustomInterp extends Interp
{
	public function new()
		super();

	public function newType(newClass:String, args:Array<Dynamic>):Dynamic
		return cnew(newClass, args);
}