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
#if USE_FLIXEL3D
import flx3D.FlxView3D;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

// Base hscript
// Hscript classes

/*import hscript.ParserEx;
	import hscript.InterpEx; */
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
		set('WiggleEffect', shaders.WiggleEffect);
		set('AtlasFrameMaker', AtlasFrameMaker);
		set('Achievements', Achievements);
		set('VCRDistortionEffect', shaders.VCRDistortionEffect);
		set('ColorSwap', shaders.ColorSwap);
		set('StaticArrow', StaticArrow);
		set('AssetsUtil', AssetsUtil);
		set('PolymodHscriptState', states.HscriptableState.PolymodHscriptState);
		#if USE_FLIXEL3D
		set('FlxView3D', FlxView3D);
		#end

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
