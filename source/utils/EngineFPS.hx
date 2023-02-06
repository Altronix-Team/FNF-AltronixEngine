package utils;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.app.Application as LimeApplication;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPSText extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	private var memoryMegas:Float = 0;
	private var memoryTotal:Float = 0;

	public var bitmap:Bitmap;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	#if !GITHUB_RELEASE
	public static var showDebugInfo:Bool = false;
	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;
	public static var curDecimalBeat:Float = 0;
	#end

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/core/fonts/vcr.ttf").fontName, 14, color);
		text = "FPS: ";
		width += 200;
		height += 30;

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end

		bitmap = ImageOutline.renderImage(this, 1, 0x000000, 1, true);
		(cast(Lib.current.getChildAt(0), Main)).addChild(bitmap);
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	public static var currentColor = 0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if (Main.save.data.fpsRain)
		{
			if (currentColor >= array.length)
				currentColor = 0;
			currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / (Main.save.data.fpsCap / 3)));
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames++;
			if (skippedFrames > (Main.save.data.fpsCap / 3))
				skippedFrames = 0;
		}

		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));

		if (memoryMegas > memoryTotal)
			memoryTotal = memoryMegas;

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = ('' + (Main.save.data.fps ? "FPS: " + currentFPS : '')
				#if openfl
				+ (Main.memoryCount ? '\nMemory: ' + memoryMegas + " MB / " + memoryTotal + " MB" : '')
				#end
				+ (Main.watermarks ? "\nAE " + "v" + EngineConstants.engineVer : ''));

			#if !GITHUB_RELEASE
			if (showDebugInfo)
			{
				text += '\nObjects: ${FlxG.state.members.length}\n';
				text += 'Cameras: ${FlxG.cameras.list.length}\n';
				text += 'CurStep: ${curStep}\n';
				text += 'CurBeat: ${curBeat}\n';
				text += 'CurDecimalBeat: ${curDecimalBeat}\n';
			}
			#end

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();

			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
		}

		// visible = true;

		/*Main.instance.removeChild(bitmap);

			bitmap = ImageOutline.renderImage(this, 2, 0x000000, 1);

			Main.instance.addChild(bitmap); */

		// visible = false;

		cacheCount = currentCount;
	}

	public function clearMaxFPS()
	{
		memoryTotal = 0;
	}
}

class EngineFPS extends Sprite
{
	public static var bgSprite:Sprite = null;

	public static var fpsText:FPSText = null;

	#if !GITHUB_RELEASE
	public static var showDebugInfo(default, set):Bool = false;
	#end

	public function new()
	{
		super();

		bgSprite = new Sprite();
		bgSprite.graphics.beginFill(0xFF000000);
		bgSprite.graphics.drawRect(0, 0, 1, 1);
		bgSprite.graphics.endFill();
		bgSprite.alpha = 0.4;
		addChild(bgSprite);

		fpsText = new FPSText(10, 3, 0xFFFFFF);
		addChild(fpsText);

		bgSprite.scaleX = fpsText.width;
		bgSprite.scaleY = fpsText.height - 70;
	}

	public static function set_showDebugInfo(value:Bool)
	{
		FPSText.showDebugInfo = value;
		showDebugInfo = value;
		bgSprite.scaleY += value ? 70 : -70;
		return value;
	}

	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		bgSprite.x = -x;
		

		super.__enterFrame(deltaTime.toInt());
	}
}
