/*
 * WindowUtil.hx
 * Contains static utility functions used for doing funny weird stuff.
 * This includes the command to open an external URL, as well as purposefully crash the game,
 * or manipulate the window.
 */

package altronixengine.utils;

import openfl.desktop.ClipboardFormats;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxAxes;
import lime.app.Application as LimeApplication;
import lime.math.Rectangle;
import lime.system.System as LimeSystem;
import openfl.desktop.Clipboard;

class WindowUtil
{
	/**
	 * Set the title of the current window.
	 * Has a allergic reaction when exposed to Unicode.
	 * @param value 
	 */
	public static function setWindowTitle(value:String):Void
	{
		LimeApplication.current.window.title = value;
	}

	public static function getWindowTitle():String
	{
		return LimeApplication.current.window.title;
	}

	/**
	 * Sets whether the window should encompass the full screen.
	 * Works on desktop and HTML5.
	 * @param value Whe
	 */
	public static function setFullscreen(value:Bool):Void
	{
		LimeApplication.current.window.fullscreen = value;
	}

	/**
	 * Gets the window is the full screen.
	 * Works on desktop and HTML5.l
	 */
	public static function getFullscreen():Bool
	{
		return LimeApplication.current.window.fullscreen;
	}

	/**
	 * Sets whether the window should encompass the full screen.
	 * Works on desktop and HTML5.
	 */
	public static function toggleFullscreen():Void
	{
		setFullscreen(!LimeApplication.current.window.fullscreen);
	}

	/**
	 * Enables or disabled Borderless Windowed mode.
	 */
	public static function setBorderlessWindowed(value:Bool)
	{
		if (value)
		{
			// Disable fullscreen mode, disable window borders, and make the window span the display.
			setFullscreen(false);
			LimeApplication.current.window.borderless = true;
			var screenSize:Rectangle = LimeSystem.getDisplay(0).bounds;
			repositionWindow(Std.int(screenSize.left), Std.int(screenSize.top));
			resizeWindow(Std.int(screenSize.width), Std.int(screenSize.height));
		}
		else
		{
			LimeApplication.current.window.borderless = false;
			resizeWindow();
			// Center the window.
		}
	}

	/**
	 * Put the game into windowed mode.
	 * Disable fullscreen mode and borderless windowed mode.
	 */
	public static function forceWindowedMode()
	{
		setFullscreen(false);
		setBorderlessWindowed(false);
	}

	/**
	 * Modifies the size of the current window.
	 * @param width The desired width. Defaults to 1280.
	 * @param height The desired height. Defaults to 720.
	 */
	public static function resizeWindow(width:Int = 1280, height:Int = 720)
	{
		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(width, height);
	}

	/**
	 * Returns the size of the current window.
	 * @param param Width or Height
	 * @return Window width or height
	 */
	public static function getWindowSize(param:String):Int
	{
		if (param == 'Width' || param == 'width')
			return LimeApplication.current.window.width;
		else
			return LimeApplication.current.window.height;
	}

	/**
	 * Returns the position of the current window.
	 * @param param X or Y
	 * @return Position of current window
	 */
	public static function getWindowPosition(param:String):Int
	{
		if (param == 'x' || param == 'X')
			return LimeApplication.current.window.x;
		else
			return LimeApplication.current.window.y;
	}

	/**
	 * Modifies the position of the current window.
	 * @param x The desired X position.
	 * @param y The desired Y position.
	 */
	public static function repositionWindow(x:Int, y:Int)
	{
		LimeApplication.current.window.x = x;
		LimeApplication.current.window.y = y;
	}

	public static function setClipboard(value:String):Void
	{
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, value);
	}

	public static function getClipboard():String
	{
		return Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT);
	}

	/**
	 * Pause execution for the given duration.
	 * WARNING: This is a blocking call. The application will freeze if this is called from the main thread.
	 * @param milliseconds Time to pause in milliseconds.
	 */
	public static function sleep(milliseconds:Int):Void
	{
		#if sys
		Sys.sleep(milliseconds / 1000);
		#end
	}

	/**
	 * Crashes the game, like Bob does at the end of ONSLAUGHT.
	 * Only works on SYS platforms like Windows/Mac/Linux/Android/iOS
	 * 
	 * @param nice If false, the game will crash with a non-zero exit code, if you care about that.
	 */
	public static function crashTheGame(?nice:Bool = true)
	{
		#if sys
		Sys.exit(nice ? 0 : 1);
		#end
	}

	/**
	 * Opens the given URL in the user's browser.
	 * @param targetURL The URL to open.
	 */
	public static function openURL(targetURL:String)
	{
		// Different behavior for certain platforms.
		#if linux
		Sys.command('/usr/bin/xdg-open', [targetURL, "&"]);
		#else
		FlxG.openURL(targetURL);
		#end
	}
}

/**
 * Steps to shake the window:
 * - When you want to start shaking, initialize a WindowShakeEvent object.
 * - Then, add a call to `windowShakeEvent.update()` in your state's update loop.
 * The window will shake for the specified duration with the specified intensity.
 * - To shake the window again with different settings, create a new event.
 * - To shake the window again with the same duration and intensity, simply call `windowShakeEvent.reset()`.
 */
class WindowShakeEvent
{
	public final intensity:Float;
	public final duration:Float;
	public final axes:FlxAxes;

	var timeRemaining:Float = 0;
	var basePosition:FlxPoint;
	var offset:FlxPoint;

	/*
	 * @param intensity The distance to shake the window, in pixels.
	 * @param duration The time to shake the window, in seconds.
	 * @param axes The directions to shake the window in. Defaults to XY (both).
	 */
	public function new(intensity:Float, duration:Float, axes:FlxAxes = FlxAxes.XY)
	{
		this.intensity = intensity;
		this.duration = duration;
		this.axes = axes;

		reset();
	}

	/**
	 * Restart the timer and enable shaking again.
	 */
	public function reset()
	{
		this.timeRemaining = this.duration;
	}

	/**
	 * Reset the window position back to normal.
	 */
	function cleanup()
	{
		this.basePosition = new FlxPoint(LimeApplication.current.window.x, LimeApplication.current.window.y);
		this.offset = FlxPoint.get();
	}

	public function update(elapsed:Float)
	{
		if (timeRemaining <= 0)
			return;

		// Keep track of elapsed time.
		timeRemaining -= elapsed;

		if (timeRemaining > 0)
		{
			// Choose a new random position.
			switch (this.axes)
			{
				case XY:
					offset.x = FlxG.random.float(-intensity, intensity);
					offset.y = FlxG.random.float(-intensity, intensity);
				case X:
					offset.x = FlxG.random.float(-intensity, intensity);
				case Y:
					offset.y = FlxG.random.float(-intensity, intensity);
				default:
					// Do nothing
			}
		}
		else
		{
			cleanup();
		}

		// Apply the new window position.
		var newPos = FlxPoint.get().addPoint(basePosition).addPoint(offset);
		WindowUtil.repositionWindow(Std.int(newPos.x), Std.int(newPos.y));
	}
}
