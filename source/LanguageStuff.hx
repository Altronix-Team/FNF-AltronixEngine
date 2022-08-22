package;

import firetongue.FireTongue;
import firetongue.Replace;

class LanguageStuff{

	public static var tongue:FireTongue;
	public static var locales:Array<String>;
    public static var fontName:String;

    public static function initLanguages(){
		tongue = new FireTongue(OPENFL);

		var locale = "en-US";
		if (FlxG.save.data.localeStr != null)
			locale = FlxG.save.data.localeStr;

		tongue.initialize({
			locale: locale,
			finishedCallback: onFinish,
			directory: 'locales/',
			checkMissing: true
		});

		locales = tongue.locales;

		fontName = getData("$FONT_NAME");
    }

    static function onFinish():Void {
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
            Debug.logTrace('Successfully loaded language stuff');
			Debug.logTrace(getData("$ENGINE_START"));
        }
    }

	public static function getData(key:String):String{
		var context = "data";
		return tongue.get(key, context);
	}

	public static function getPlayState(key:String):String{
		var context = "playState";
		return tongue.get(key, context);
	}

	public static function getOption(key:String):String{
		var context = "option";
		return tongue.get(key, context);
	}

	public static function getOptionDesc(key:String):String{
		var context = "optionsDesc";
		return tongue.get(key, context);
	}

	public static function getString(key:String, context:String):String{
		return tongue.get(key, context);
	}

	@:deprecated('Not wotking, crash the game')
	public static function getUiLanguageName(targetlocale:String = '', curlocale:String = ''):String{
		return tongue.getIndexString("$UI_LANGUAGE", targetlocale, curlocale);
	}

	public static function replaceFlagsAndReturn(key:String, context:String, flags:Array<String>, values:Array<Dynamic>):String {
		var stringArray:Array<String> = [];
		for (i in values)
		{
			stringArray.push(Std.string(i));
		}
		return Replace.flags(getString(key, context), flags, stringArray);
    }

	public static function loadLanguage(lang:String){
		tongue.initialize({
			locale: lang,
			finishedCallback: onFinish,
			directory: 'locales/',
			checkMissing: true
		});

		fontName = getData("$FONT_NAME");
    }
}