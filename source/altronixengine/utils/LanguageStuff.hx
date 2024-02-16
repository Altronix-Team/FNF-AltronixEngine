package altronixengine.utils;

import flixel.addons.ui.FlxUIState;
import openfl.utils.AssetType;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import firetongue.Replace;
import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;

class LanguageStuff
{
	public static var tongue(default, null):CustomFireTongue = new CustomFireTongue(OPENFL);
	public static var locales:Array<String>;
	public static var fontName:String;
	public static var locale:String = "en-US";

	public static function initLanguages()
	{
		if (Main.save.data.localeStr != null)
			locale = Main.save.data.localeStr;

		tongue.initialize({
			locale: locale,
			finishedCallback: onFinish,
			directory: 'locales/',
			checkMissing: true
		});

		locale = tongue.locale;

		locales = tongue.locales;

		fontName = getData("$FONT_NAME");

		FlxUIState.static_tongue = tongue;
	}

	static function onFinish():Void
	{
		var text:String = '';
		var contextArray:Array<String> = ["data", "optionsDesc", "options"];
		if (tongue.missingFiles != null)
		{
			for (context in contextArray)
			{
				var str:String = tongue.get("$MISSING_FILES", context);
				str = Replace.flags(str, ["<X>"], [Std.string(tongue.missingFiles.length)]);
				text += str + "\n";
				for (file in tongue.missingFiles)
				{
					text += "    " + file + "\n";
				}

				Debug.logError(text);
			}
		}

		if (tongue.missingFlags != null)
		{
			var missingFlags = tongue.missingFlags;

			for (context in contextArray)
			{
				var miss_str:String = tongue.get("$MISSING_FLAGS", context);

				var count:Int = 0;
				var flag_str:String = "";

				for (key in missingFlags.keys())
				{
					var list:Array<String> = missingFlags.get(key);
					count += list.length;
					for (flag in list)
					{
						flag_str += "    Context(" + key + "): " + flag + "\n";
					}
				}

				miss_str = Replace.flags(miss_str, ["<X>"], [Std.string(count)]);
				text += miss_str + "\n";
				text += flag_str + "\n";
			}

			Debug.logError(text);
		}

		if (tongue.missingFlags == null && tongue.missingFiles == null)
		{
			Debug.logInfo('Successfully loaded language stuff');
		}
	}

	public static function getImagePath(key:String):String
	{
		if (Assets.exists('locales/$locale/images/$key.png', IMAGE))
		{
			return 'locales/$locale/images/$key.png';
		}
		return null;
	}

	public static function getFilePath(key:String, type:AssetType = TEXT):String
	{
		if (Assets.exists('locales/$locale/$key', type))
		{
			return 'locales/$locale/$key';
		}
		return null;
	}

	public static function getSparrowAtlas(key:String)
	{
		if (Assets.exists('locales/$locale/images/$key.png', IMAGE) && Assets.exists('locales/$locale/images/$key.xml', TEXT))
		{
			return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(Assets.getBitmapData('locales/$locale/images/$key.png')),
				'locales/$locale/images/$key.xml');
		}
		return null;
	}

	public static function getPackerAtlas(key:String)
	{
		if (Assets.exists('locales/$locale/images/$key.png', IMAGE) && Assets.exists('locales/$locale/images/$key.txt', TEXT))
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(FlxGraphic.fromBitmapData(Assets.getBitmapData('locales/$locale/images/$key.png')),
				'locales/$locale/images/$key.txt');
		}
		return null;
	}

	public static function getData(key:String):String
	{
		var context = "data";
		return tongue.get(key, context);
	}

	public static function getPlayState(key:String):String
	{
		var context = "playState";
		return tongue.get(key, context);
	}

	public static function getOption(key:String):String
	{
		var context = "option";
		return tongue.get(key, context);
	}

	public static function getOptionDesc(key:String):String
	{
		var context = "optionsDesc";
		return tongue.get(key, context);
	}

	public static function getString(key:String, context:String):String
	{
		return tongue.get(key, context);
	}

	public static function getUiLanguageName(targetlocale:String = '', curlocale:String = ''):String
	{
		//return tongue.getIndexString(LanguageBilingual, targetlocale);
		return tongue.locale;
	}

	public static function replaceFlagsAndReturn(key:String, context:String, flags:Array<String>, values:Array<Dynamic>):String
	{
		var stringArray:Array<String> = [];
		for (i in values)
		{
			stringArray.push(i.toString());
		}
		return Replace.flags(getString(key, context), flags, stringArray);
	}

	public static function loadLanguage(lang:String)
	{
		tongue.initialize({
			locale: lang,
			finishedCallback: onFinish,
			directory: 'locales/',
			checkMissing: true
		});

		fontName = getData("$FONT_NAME");
	}
}

/**
 * Required for IFireTongue implementation
 */
class CustomFireTongue extends FireTongue implements IFireTongue
{
	public function new(?framework:Framework, ?checkFile:String->Bool, ?getText:String->String, ?getDirectoryContents:String->Array<String>,
			?forceCase:Case = Case.Upper)
	{
		super(framework, checkFile, getText, getDirectoryContents, forceCase);
	}
}
