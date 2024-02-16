package scriptStuff;

import animateatlas.AtlasFrameMaker;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.macros.FlxMacroUtil;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import gameplayStuff.BGSprite;
import gameplayStuff.BackgroundDancer;
import gameplayStuff.BackgroundGirls;
import gameplayStuff.Character;
import gameplayStuff.Conductor;
import gameplayStuff.Note;
import gameplayStuff.Song;
import gameplayStuff.Stage;
import gameplayStuff.StaticArrow;
import gameplayStuff.TankmenBG;
import haxe.Constraints.Function;
import haxe.Exception;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.app.Application;
import openfl.Assets as OpenFlAssets;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import shaders.Shaders.ColorSwap;
import shaders.Shaders.VCRDistortionEffect;
import states.GameOverSubstate;
import states.MusicBeatState;
import states.playState.PlayState;
import tea.SScript;
import utils.Paths;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class ScriptException extends Exception
{
	public function new(message:String, ?previous:Exception, ?native:Any):Void
	{
		super(message, previous, native);
		Debug.displayAlert('Error with hscript file!', message);
	}
}

class HScriptHandler extends SScript
{
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
		set('FlxColor', CustomFlxColor);

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
		set('WiggleEffect', shaders.WiggleEffect);
		set('AtlasFrameMaker', AtlasFrameMaker);
		set('Achievements', Achievements);
		set('VCRDistortionEffect', shaders.VCRDistortionEffect);
		set('ColorSwap', shaders.ColorSwap);
		set('StaticArrow', StaticArrow);
		set('AssetsUtil', AssetsUtil);
		set('PolymodHscriptState', states.HscriptableState.PolymodHscriptState);

		set('getRGBColor', getRGBColor);
		set('openPolymodState', openPolymodState);
	}

	function openPolymodState(scriptFileName:String)
	{
		try
		{
			var state = states.HscriptableState.PolymodHscriptState.init(scriptFileName);
			MusicBeatState.switchState(state);
		}
		catch (e)
		{
			Debug.logTrace(e.details());
		}
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

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}