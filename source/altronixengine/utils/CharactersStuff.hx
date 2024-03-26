package altronixengine.utils;

import flixel.graphics.frames.FlxFramesCollection;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;
import openfl.utils.Assets as OpenFlAssets;
import altronixengine.gameplayStuff.Character;
import altronixengine.data.EngineConstants;

@:access(gameplayStuff.Character)
class CharactersStuff
{
	public static var characterList:Array<String> = [];

	public static var girlfriendList:Array<String> = [];

	static var missingChars:Array<String> = [];

	public static function getCharacterIcon(char:String):String
	{
		var jsonData;
		if (OpenFlAssets.exists(Paths.json('characters/${char}/${char}', "gameplay")))
		{
			jsonData = Paths.loadJSON('characters/${char}/${char}', "gameplay");
		}
		else
		{
			Debug.logError('There is no character with this name!');
			return 'face';
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${char}');
			return 'face';
		}

		if (Reflect.field(jsonData, 'name') != null)
		{
			var data:CharacterData = cast jsonData;
			return data.characterIcon;
		}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null)
		{
			var data:PsychCharacterFile = cast jsonData;
			return data.healthicon;
		}
		else
			return 'face';
	}

	public static function getCharacterColor(char:String):Array<Int>
	{
		var jsonData;
		if (OpenFlAssets.exists(Paths.json('characters/${char}/${char}', "gameplay")))
		{
			jsonData = Paths.loadJSON('characters/${char}/${char}', "gameplay");
		}
		else
		{
			Debug.logError('There is no character with this name!');
			return [0, 0, 0];
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${char}');
			return [0, 0, 0];
		}

		if (Reflect.field(jsonData, 'name') != null)
		{
			var data:CharacterData = cast jsonData;
			return data.barColorJson;
		}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null)
		{
			var data:PsychCharacterFile = cast jsonData;
			return data.healthbar_colors;
		}
		else
			return [0, 0, 0];
	}

	public static function initDefaultCharacters():Bool
	{
		#if CHECK_FOR_DEFAULT_CHARACTERS
		for (char in EngineConstants.defaultCharacters)
		{
			if (OpenFlAssets.exists(Paths.json('characters/${char}/${char}', "gameplay")))
				characterList.push(char);
			else
				missingChars.push(char);
		}

		if (missingChars.length == 0)
			return true;
		else
			return false;
		#else
		return true;
		#end
	}

	public static function initCharacterList()
	{
		characterList = [];

		girlfriendList = [];

		var pathcheck = AssetsUtil.listAssetsInPath('assets/gameplay/characters/', DIRECTORY);

		if (initDefaultCharacters())
		{
			Debug.logInfo('Succesfully loaded all default characters, starting loading mod chars');
			for (charId in pathcheck)
			{
				if (characterList.contains(charId))
					continue;
				else
				{
					if (OpenFlAssets.exists(Paths.json('characters/${charId}/${charId}', "gameplay")))
					{
						characterList.push(charId);

						var charData:CharacterData = Paths.loadJSON('characters/${charId}/${charId}', "gameplay");
						if (charData == null)
						{
							Debug.logError('Character $charId failed to load.');
							characterList.remove(charId);
							continue;
						}
					}
					else
					{
						continue;
					}
				}
			}
		}
		else
		{
			var missChars:String = '';
			if (missingChars.length > 1)
			{
				for (char in missingChars)
				{
					if (missingChars.indexOf(char) != missingChars.length - 1)
						missChars += char + ', ';
					else
						missChars += char;
				}
			}
			else
				missChars = missingChars[0];

			Debug.logWarn('Missing default characters: ' + missChars);

			for (charId in pathcheck)
			{
				if (characterList.contains(charId))
					continue;
				else
				{
					characterList.push(charId);

					var charData:CharacterData = Paths.loadJSON('characters/${charId}/${charId}', "gameplay");
					if (charData == null)
					{
						Debug.logError('Character $charId failed to load.');
						characterList.remove(charId);
						continue;
					}
				}
			}
		}
	}
}
