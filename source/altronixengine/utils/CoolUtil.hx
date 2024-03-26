package altronixengine.utils;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIBar.FlxBarStyle;
import Type;
import flixel.math.FlxMath;
import openfl.utils.Assets as OpenFlAssets;

@:cppFileCode('#include <windows.h>\n#include <iostream>')
class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Hard P"];

	public static final defaultDifficulties:Array<String> = ['Easy', "Normal", "Hard", "Hard P"];

	public static var difficultyPrefixes:Array<String> = ['-easy', '', '-hard', '-hardplus'];

	public static final defaultDifficultyPrefixes:Array<String> = ['-easy', '', '-hard', '-hardplus'];

	public static var songDiffs:Map<String, Array<String>> = [];

	public static var songDiffsPrefix:Map<String, Array<String>> = [];

	public static var daPixelZoom:Float = 6;

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function clearDifficultyArray(difficulty:Int)
	{
		difficultyArray = defaultDifficulties;
	}

	public static function flxColorFromRGBArray(value:Array<Int>):FlxColor
	{
		if (value.length < 3)
			return FlxColor.WHITE;

		return FlxColor.fromRGB(value[0], value[1], value[2]);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		if (OpenFlAssets.exists(path))
			daList = OpenFlAssets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function camLerpShit(lerp:Float):Float
	{
		return lerp * (FlxG.elapsed / (1 / 60));
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0;
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}

	/**
	 * @param duration The duration in seconds
	 * @return The duration in the format "MM:SS"
	 */
	public static function durationToString(duration:Float):String
	{
		var seconds = FlxMath.roundDecimal(duration, 0) % 60;
		var secondsStr = Strings.lpad('$seconds', 2, '0');
		var minutes = FlxMath.roundDecimal(duration - seconds, 0) / 60;
		var minutesStr = FlxMath.roundDecimal(minutes, 0);
		return '$minutesStr:$secondsStr';
	}

	public static function getTypeName(input:Dynamic):String
	{
		return switch (Type.typeof(input))
		{
			case TEnum(e):
				Type.getEnumName(e);
			case TClass(c):
				Type.getClassName(c);
			case TInt:
				"int";
			case TFloat:
				"float";
			case TBool:
				"bool";
			case TObject:
				"object";
			case TFunction:
				"function";
			case TNull:
				"null";
			case TUnknown:
				"unknown";
			default:
				"";
		}
	}

	/**
	 * Utility to parse an ARGB value from the current hex value
	 * Hex string is cached on the class so that it does not need to be recalculated for every pixel.
	 */
	public static function parseARGB(alpha:Int, hexStr:String):UInt
	{
		return Std.parseInt("0x" + Strings.toHex(alpha) + hexStr);
	}

	/**
	 * Convert a hexadecimal number to a hexadecimal string.
	 */
	public static function toHexString(hex:UInt):String
	{
		var r:Int = (hex >> 16);
		var g:Int = (hex >> 8 ^ r << 8);
		var b:Int = (hex ^ (r << 16 | g << 8));

		var red:String = Strings.toHex(r);
		var green:String = Strings.toHex(g);
		var blue:String = Strings.toHex(b);

		red = (red.length < 2) ? "0" + red : red;
		green = (green.length < 2) ? "0" + green : green;
		blue = (blue.length < 2) ? "0" + blue : blue;
		return (red + green + blue).toUpperCase();
	}

	public static function createDirectoryIfNotExists(localFolder:String):String
	{
		#if FEATURE_FILESYSTEM
		var fullPath = '${Sys.getCwd()}/$localFolder';
		if (!sys.FileSystem.exists(fullPath))
			sys.FileSystem.createDirectory(fullPath);
		return fullPath;
		#else
		return localFolder;
		#end
	}

	// Function to easy work with FlxUIBar
	public static function createFlxUIBarstyle(filledColors:Array<FlxColor>, emptyColors:Array<FlxColor>, chunkSize:Null<Int>, gradRotation:Null<Int>,
			filledColor:Null<FlxColor>, emptyColor:Null<FlxColor>, borderColor:Null<FlxColor>, filledImgSrc:String, emptyImgSrc:String):FlxBarStyle
	{
		var retVal:FlxBarStyle = {
			filledColors: filledColors,
			emptyColors: emptyColors,

			chunkSize: chunkSize,
			gradRotation: gradRotation,
			filledColor: filledColor,
			emptyColor: emptyColor,
			borderColor: borderColor,
			filledImgSrc: filledImgSrc,
			emptyImgSrc: emptyImgSrc
		};
		return retVal;
	}

	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.sound(sound, library));
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.music(sound, library));
	}

	public static function fromArray(group:FlxTypedGroup<Dynamic>, array:Array<Dynamic>)
	{
		for (obj in array)
		{
			try
			{
				group.add(obj);
			}
			catch (e)
			{
				Debug.logError('Can not push object to group');
				continue;
			}
		}
		return group;
	}

	private static function precacheSoundFile(file:Dynamic):Void
	{
		if (OpenFlAssets.exists(file, SOUND) || OpenFlAssets.exists(file, MUSIC))
			OpenFlAssets.getSound(file, true);
	}

	@:functionCode('
		res = LOWORD(GetKeyboardLayout(0));
	')
	public static function getKeyboardLayout(res:Int = 0)
	{
		return res;
	}
}
