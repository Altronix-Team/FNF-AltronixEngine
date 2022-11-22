package scriptStuff;

import gameplayStuff.Song;
import Shaders.VCRDistortionEffect;
import animateatlas.AtlasFrameMaker;
import lime.app.Application;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxShader;
import flixel.ui.FlxBar;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.util.FlxAxes;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import flixel.FlxBasic;
import gameplayStuff.Note;
import gameplayStuff.Stage;
import states.PlayState;
import gameplayStuff.BackgroundGirls;
import gameplayStuff.BackgroundDancer;
import haxe.Constraints.Function;
import flixel.math.FlxMath;
import flixel.system.macros.FlxMacroUtil;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameplayStuff.TankmenBG;
#if FEATURE_FILESYSTEM
import sys.io.File;
import sys.FileSystem;
#end

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
import gameplayStuff.BGSprite;

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

#if !USE_SSCRIPT
class HScriptHandler
{
    public var expose:StringMap<Dynamic>;
	
	var parser:Parser;
	public var interp:CustomInterp;

	/*var parserEx:ParserEx;
	var interpEx:InterpEx;*/

    var ast:Expr;

	var color:FlxColor;

	var file:String = '';
    
    public function new()
    {        
        parser = new Parser();
		interp = new CustomInterp();

        parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		expose = new StringMap<Dynamic>();

		expose.set("Sys", Sys);
		expose.set("Reflect", Reflect);
		expose.set("Std", Std);
		expose.set("Math", Math);
		expose.set("StringTools", StringTools);
		expose.set("FlxMath", FlxMath);
		expose.set("Conductor", Conductor);
		expose.set('Debug', Debug);
		expose.set('Paths', Paths);
		expose.set('PlayState', states.PlayState);
		expose.set('GameOverSubstate', GameOverSubstate);
		expose.set("CoolUtil", CoolUtil);
		expose.set('FlxG', FlxG);
		expose.set('FlxRandom', FlxRandom);
		expose.set('FlxSprite', FlxSprite);
		expose.set('FlxTypedGroup', FlxTypedGroup);
		expose.set('WiggleEffect', WiggleEffect);
		expose.set('FlxCamera', FlxCamera);
		expose.set('FlxSound', FlxSound);
		expose.set('FlxTween', FlxTween);
		expose.set('FlxEase', FlxEase);
		expose.set('FlxText', FlxText);
		expose.set('FlxTimer', FlxTimer);
		expose.set('FlxObject', FlxObject);
		expose.set('Character', Character);
		expose.set('Alphabet', Alphabet);
		expose.set('MusicBeatState', MusicBeatState);
		expose.set('WindowUtil', WindowUtil);
		expose.set('WindowShakeEvent', WindowUtil.WindowShakeEvent);

		expose.set('newType', newType);
		expose.set('random', random);
		expose.set('getRGBColor', getRGBColor);
		expose.set("loadModule", loadModule);		
		expose.set("getGraphic", getGraphic);
		expose.set("playSound", playSound);
		expose.set("lazyPlaySound", lazyPlaySound);
		expose.set("createTimer", createTimer);
		expose.set('setProperty', setProperty);
		expose.set('getProperty', getProperty);
		expose.set('getInstance', getInstance);
		expose.set('callMethod', callMethod);
		expose.set('set', set);
		expose.set('get', get);
		expose.set('exists', exists);
		expose.set('call', call);
		expose.set('getEngineFont', getEngineFont);
		expose.set('importClass', importClass);
		//expose.set("instancePluginClass", instanceExClass);
		
		expose.set("getSparrowAtlas", Paths.getSparrowAtlas);
		expose.set("getPackerAtlas", Paths.getPackerAtlas);

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

	public function call(func:String, args:Array<Dynamic>):Dynamic {
		if (func == null)
		{
			Debug.logError('Function name cannot be null for $file!');
			return null;
		}

		var params:Array<Dynamic> = [];

		if (args != null)
		{
			params = args;
		}

		if (!interp.variables.exists(func))
		{
			//Debug.logError('Function $func does not exist in $file.');
			return null;
		}

		try{
			var functionField:Function = get(func);
			return Reflect.callMethod(this, functionField, params);}
		catch (e)
		{
			Debug.logError('Error with calling function $func: ${e.message} \n ${e.stack}');
			return null;
		}
	}

	/** Creates new class and returns it.
	 * - Works like: new FlxText(x, y, width, text, size, embedded);
	 * @param newClass The name of new class: (FlxText)
	 * @param args Array with arguments for the new function: ([x, y, width, text, size, embedded])
	 **/
	public function newType(newClass:String, args:Array<Dynamic>):Dynamic
	{
		if (interp.variables.get(newClass) == null)
			interp.variables.set(newClass, Type.resolveClass(newClass));
		return interp.newType(newClass, args);
	}

    public function loadScript(path:String, execute:Bool = true)
    {
        if (path != "")
        {
			file = path;
			if (OpenFlAssets.exists(path))
            {
				Debug.logTrace('Found hscript');
				Debug.logTrace('At path: ' + path);
                try
                {
					ast = parser.parseString(OpenFlAssets.getText(path), path);
					
					for (v in expose.keys())
						interp.variables.set(v, expose.get(v));
					
                    if (execute){
                        interp.execute(ast);
						return;
					}
                }
                catch (e:Error)
                {
                    throw new ScriptException("Script parse error:\n" + e);
                }
            }
			#if FEATURE_FILESYSTEM
			else if (FileSystem.exists(path))
			{
				Debug.logTrace('Found hscript');
				Debug.logTrace('At path: ' + path);
				try
				{
					ast = parser.parseString(File.getContent(path), path);

					for (v in expose.keys())
						interp.variables.set(v, expose.get(v));

					if (execute){
						interp.execute(ast);
						return;
					}
				}
				catch (e:Error)
				{
					throw new ScriptException("Script parse error:\n" + e);
				}
			}
			#end
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
					var moduleInterp = new CustomInterp();
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
			#if FEATURE_FILESYSTEM
			else if (FileSystem.exists(path))
			{
				try
				{
					var moduleInterp = new CustomInterp();
					var moduleAst = parser.parseString(File.getContent(path), path);

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
			#end
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
		return Paths.font("vcr.ttf");
	}

	function random(type:String, args:Array<Dynamic>):Dynamic
	{
		switch (type)
		{
			case 'bool':
				return FlxG.random.bool(args[0]);
			case 'int':
				return FlxG.random.int(args[0], args[1], args[3]);
			case 'float':
				return FlxG.random.float(args[0], args[1], args[3]);
		}
		return null;
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

	function playSound(path:String, group:String = null):FlxSound
	{
		return FlxG.sound.play(Paths.sound(path, group));
	}

	function lazyPlaySound(path:String, group:String = null)
	{
		FlxG.sound.play(Paths.sound(path, group));
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

	function getRGBColor(r:Int, g:Int, b:Int, ?a:Int):FlxColor
	{
		return FlxColor.fromRGB(r, g, b, a);
	}

	function callMethod(instance:Null<Dynamic> = null, func:Function, args:Array<Dynamic>):Dynamic
	{
		if (instance == null)
			return Reflect.callMethod(getInstance(), func, args);
		else
			return Reflect.callMethod(instance, func, args);
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
	
	function importClass(cl:String) {
		var splitClassName = cl.split(".");
		var realClassName = splitClassName.join(".");

		var cl = Type.resolveClass(realClassName);
		var en = Type.resolveEnum(realClassName);

		if (cl == null && en == null)
		{
			Debug.logWarn("Invalid class" + realClassName);
		}
		else
		{
			if (en != null)
			{
				var enumThingy = {};
				for (c in en.getConstructors())
				{
					Reflect.setField(enumThingy, c, en.createByName(c));
				}
				set(splitClassName[splitClassName.length - 1], enumThingy);
			}
			else
			{
				set(splitClassName[splitClassName.length - 1], cl);
			}
		}

		return null;
	}
}

class CustomInterp extends Interp
{
	public function new()
		super();

	public function newType(newClass:String, args:Array<Dynamic>):Dynamic
		return cnew(newClass, args);

	override private function resetVariables()
	{
		super.resetVariables();

		variables.set("trace", Reflect.makeVarArgs(function(el)
		{
			var inf = posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logTrace(Std.string(v));
		}));
		variables.set("info", Reflect.makeVarArgs(function(el)
		{
			var inf = posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logInfo(Std.string(v));
		}));
		variables.set("warn", Reflect.makeVarArgs(function(el)
		{
			var inf = posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logWarn(Std.string(v));
		}));
		variables.set("error", Reflect.makeVarArgs(function(el)
		{
			var inf = posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logError(Std.string(v));
		}));
	}
}
#else
//Original SScript repository https://github.com/TheWorldMachinima/SScript
//SScript with polymod support https://github.com/AltronMaxX/SScript
//Engine, that gave me main idea of redo engine hscript to SScript and some SScript handler code https://github.com/BeastlyGhost/Forever-Engine-Underscore
class HScriptHandler extends SScript
{
	public function new(file:String, ?preset:Bool = true)
	{
		super(file, preset);
	}

	override public function preset():Void
	{
		super.preset();

		set("trace", Reflect.makeVarArgs(function(el)
		{
			var inf = interp.posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logTrace(Std.string(v));
		}));
		set("info", Reflect.makeVarArgs(function(el)
		{
			var inf = interp.posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logInfo(Std.string(v));
		}));
		set("warn", Reflect.makeVarArgs(function(el)
		{
			var inf = interp.posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logWarn(Std.string(v));
		}));
		set("error", Reflect.makeVarArgs(function(el)
		{
			var inf = interp.posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			Debug.logError(Std.string(v));
		}));

		set('Reflect', Reflect);
		set('FlxG', FlxG);
		set('FlxBasic', FlxBasic);
		set('FlxObject', FlxObject);
		set('FlxCamera', FlxCamera);
		set('FlxSprite', FlxSprite);
		set('FlxText', FlxText);
		set('FlxTextBorderStyle', FlxTextBorderStyle);
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		set('FlxSound', FlxSound);
		set('FlxTimer', FlxTimer);
		set('FlxTween', FlxTween);
		set('FlxEase', FlxEase);
		set('FlxMath', FlxMath);
		set('FlxSound', FlxSound);
		set('FlxGroup', FlxGroup);
		#if (flixel < "5.0.0")
		set('FlxPoint', FlxPoint);
		set('FlxAxes', FlxAxes);
		#end
		set('FlxTypedGroup', FlxTypedGroup);
		set('FlxSpriteGroup', FlxSpriteGroup);
		set('FlxTypedSpriteGroup', FlxTypedSpriteGroup);
		set('FlxStringUtil', FlxStringUtil);
		set('FlxAtlasFrames', FlxAtlasFrames);
		set('FlxSort', FlxSort);
		set('Application', Application);
		set('FlxGraphic', FlxGraphic);
		set('FlxAtlasFrames', FlxAtlasFrames);
		set('File', File);
		set('FlxTrail', FlxTrail);
		set('FlxShader', FlxShader);
		set('FlxBar', FlxBar);
		set('FlxBackdrop', FlxBackdrop);
		set('StageSizeScaleMode', StageSizeScaleMode);
		set('FlxBarFillDirection', FlxBarFillDirection);
		set('GraphicsShader', GraphicsShader);
		set('ShaderFilter', ShaderFilter);
		set('Capabilities', flash.system.Capabilities);

		set('Discord', utils.DiscordClient);

		set('Alphabet', Alphabet);
		set('Song', Song);
		set('Character', Character);
		set('controls', Controls);
		set('CoolUtil', CoolUtil);
		set('Conductor', Conductor);
		set('PlayState', PlayState);
		set('Main', Main);
		set('Note', Note);
		set('Paths', Paths);
		set('Stage', Stage);
		set('WindowUtil', WindowUtil);
		set('WindowShakeEvent', WindowUtil.WindowShakeEvent);
		set('Debug', Debug);
		set('WiggleEffect', WiggleEffect);
		set('AtlasFrameMaker', AtlasFrameMaker);
		set('Achievements', Achievements);
		set('VCRDistortionEffect', VCRDistortionEffect);

		set('getRGBColor', getRGBColor);
	}

	function getRGBColor(r:Int, g:Int, b:Int, ?a:Int):FlxColor
	{
		return FlxColor.fromRGB(r, g, b, a);
	}

	function createTypedGroup():FlxTypedGroup<Dynamic>
	{
		return new FlxTypedGroup<Dynamic>();
	}
}
#end