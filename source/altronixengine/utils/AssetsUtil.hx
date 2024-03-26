package altronixengine.utils;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.sound.FlxSound;
import flxanimate.frames.FlxAnimateFrames;
import haxe.Json;
import lime.tools.AssetType;
import openfl.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.utils.AssetType;

class AssetsUtil
{
	public var _file:FileReference;

	private static var imageCache:Map<String, FlxGraphic> = [];

	private static var soundCache:Map<String, FlxSound> = [];

	public static function listAssetsInPath(path:String, type:AssetTypes = UNKNOWN):Array<String>
	{
		if (type == DIRECTORY)
			return listFoldersInPath(path);
		var dataAssets = if (type == SOUND || type == MUSIC) OpenFlAssets.list(SOUND)
			.concat(OpenFlAssets.list(MUSIC)) else OpenFlAssets.list(AssetTypes.toOpenFlType(type));

		var queryPath = '${path}';

		var results:Array<String> = [];

		var ends:Array<String> = AssetTypes.returnExts(type);

		for (data in dataAssets)
		{
			for (end in ends)
			{
				if (data.indexOf(queryPath) != -1
					&& data.endsWith('.$end')
					&& (!results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.$end', ''))))
				{
					var suffixPos = data.indexOf(queryPath) + queryPath.length;
					results.push(data.substr(suffixPos).replaceAll('.$end', ''));
				}
			}
		}
		return results;
	}

	public static function loadAsset(key:String, type:AssetTypes = UNKNOWN, ?library:String = "core"):Dynamic
	{
		switch (type)
		{
			case IMAGE:
				if (imageCache.exists(key)){
					var cachedImage = imageCache.get(key);
					return cachedImage ?? loadImage(key, library);
				}
				else{
					var image = loadImage(key, library);
					image.persist = true;
					image.destroyOnNoUse = false;
					imageCache.set(key, image);
					return image;
				}
			case JSON:
				return loadJSON(key, library);
			case TEXT:
				return OpenFlAssets.getText(Paths.getPath(key, TEXT, library));
			case SOUND | MUSIC:
				if (soundCache.exists(key)){
					var cachedSound = soundCache.get(key);
					return cachedSound ?? loadSoundAsset(key, type, library);
				}
				else{
					var sound = loadSoundAsset(key, type, library);
					soundCache.set(key, sound);
					return sound;
				}
			default:
				return null;
		}
	}

	public static function readLibrary(library:String, type:AssetTypes = UNKNOWN, ?subfolders:String = ''):Array<String>
	{
		if (type == UNKNOWN || type == DIRECTORY)
		{
			Debug.logError("Can`t list this type");
			return [];
		}

		var retVal = [];
		var library = OpenFlAssets.getLibrary(library);
		var files = library.list(AssetTypes.toOpenFlType(type).toString());

		for (file in files)
		{
			if (file.contains(subfolders))
			{
				for (ext in AssetTypes.returnExts(type))
				{
					if (file.endsWith(ext))
					{
						var fileName = file.removeBefore(subfolders).removeAll(subfolders).removeAfter(".");
						if (!retVal.contains(fileName))
							retVal.push(fileName);
					}
					else
						continue;
				}
			}
			else
				continue;
		}

		return retVal;
	}

	static public function getSparrowAtlas(key:String, ?library:String = "core")
	{
		if (LanguageStuff.getSparrowAtlas(key) != null)
		{
			return LanguageStuff.getSparrowAtlas(key);
		}
		else
		{
			return FlxAtlasFrames.fromSparrow(loadImage(key, library), Paths.file((key.contains('images/') ? '' : 'images/') + '$key.xml', library));
		}
	}

	static public function getCharacterFrames(charName:String, key:String):FlxFramesCollection
	{
		try
		{
			var filePath = 'characters/$charName/$key';
			if (OpenFlAssets.exists(Paths.txt('characters/$charName/$key', "gameplay")))
				return FlxAtlasFrames.fromSpriteSheetPacker(loadCharacterImage(charName, key), Paths.file('$filePath.txt', "gameplay"));
			else
			{
				if (OpenFlAssets.exists(Paths.xml('characters/$charName/$key', "gameplay")))
				{
					return FlxAtlasFrames.fromSparrow(loadCharacterImage(charName, key), Paths.file('$filePath.xml', "gameplay"));
				}
				else
					return null;
			}
		}
		catch (e)
		{
			Debug.logError('Failed to load character frames ' + e.details());
			return null;
		}
	}

	inline static public function characterImage(charName:String, key:String)
	{
		return Paths.getPath('characters/$charName/$key.png', IMAGE, "gameplay");
	}

	static public function loadCharacterImage(charName:String, key:String):FlxGraphic
	{
		var path = characterImage(charName, key);

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			Debug.logWarn('Could not find image at path $path');
			return null;
		}
	}

	/**
	 * Function which wants to help find you this file all around the engine!
	 * - and mods ;)
	 * @param fileName name of file to find with extension
	 * @return File path
	 */
	static public function findMatchingFiles(fileName:String):String
	{
		var files = OpenFlAssets.list();

		for (file in files)
		{
			if (file.endsWith(fileName))
				return file.replaceAll('assets/', '');
		}
		return null;
	}

	inline static public function getPackerAtlas(key:String, ?library:String = "core")
	{
		if (LanguageStuff.getPackerAtlas(key) != null)
		{
			return LanguageStuff.getPackerAtlas(key);
		}
		else
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), Paths.file((key.contains('images/') ? '' : 'images/') + '$key.txt', library));
		}
	}

	inline static public function doesAssetExists(path:String, type:AssetTypes = UNKNOWN):Bool
	{
		switch (type)
		{
			case SOUND | MUSIC:
				return doesSoundAssetExist(path);
			case TEXT | XML | JSON | HSCRIPT:
				return doesTextAssetExist(path);
			default:
				return OpenFlAssets.exists(path, BINARY);
		}
	}

	public static function returnAssetType(path:String, fileName:String):Array<AssetTypes>
	{
		var checkExts = AssetTypes.returnAllExts();

		for (ext in checkExts)
		{
			if (OpenFlAssets.exists('$path/$fileName.$ext'))
			{
				return AssetTypes.returnTypeByExt(ext);
			}
		}
		return [UNKNOWN];
	}

	public function saveFile(fileContent:Dynamic = '', type:AssetTypes = UNKNOWN, fileName:String = 'file')
	{
		if (type == IMAGE
			|| type == DIRECTORY
			|| type == UNKNOWN
			|| type == FONT
			|| type == SOUND
			|| type == MUSIC
			|| type == VIDEOS)
			return;

		var data:Dynamic = '';
		switch (type)
		{
			case JSON:
				data = Json.stringify(fileContent, null, ' ');
			case XML:
				data = Xml.parse(fileContent);
			default:
				data = fileContent;
		}

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
			_file.addEventListener(openfl.events.Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), fileName + '.${AssetTypes.returnExts(type)}');
		}
	}

	private function onSaveComplete(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private function onSaveCancel(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private function onSaveError(_):Void
	{
		_file.removeEventListener(openfl.events.Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(openfl.events.Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	private static function loadSoundAsset(key:String, type:AssetTypes = SOUND, ?library:String)
	{
		var retSound:FlxSound = null;
		if (type == SOUND)
		{
			retSound = new FlxSound().loadEmbedded(Paths.sound(key, library), true);
			FlxG.sound.list.add(retSound);
		}
		else if (type == MUSIC)
		{
			retSound = new FlxSound().loadEmbedded(Paths.music(key, library), true);
			FlxG.sound.list.add(retSound);
		}
		return retSound;
	}

	inline static private function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND)
			|| OpenFlAssets.exists(path, AssetType.MUSIC)
			|| OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.SOUND)
			|| OpenFlAssets.exists(OpenFlAssets.getPath(path), AssetType.MUSIC);
	}

	inline static private function doesTextAssetExist(path:String)
	{
		if (OpenFlAssets.exists(path, TEXT))
			return OpenFlAssets.exists(path, TEXT);
		else
			return false;
	}

	static private function loadImage(key:String, ?library:String):FlxGraphic
	{
		var retVal:BitmapData;
		var path = Paths.image(key, library);
		if (key.contains("images/"))
		{
			path = path.removeFirst("images/");
		}
		if (OpenFlAssets.exists(path, IMAGE))
		{
			retVal = OpenFlAssets.getBitmapData(path);
		}
		else
		{
			Debug.logWarn('Could not find image at path $path');
			retVal = new BitmapData(100, 100, true, 0xFFEA00FF);
		}
		return FlxGraphic.fromBitmapData(retVal, false, key);
	}

	static private function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim().replace("\uFEFF", "");

		// Perform cleanup on files that have bad data at the end.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			return Json.parse(rawJson);
		}
		catch (e)
		{
			Debug.logError("AN ERROR OCCURRED parsing a JSON file.");
			Debug.logError(e.details());

			// Return null.
			return null;
		}
	}

	private static function listFoldersInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list();

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replace(queryPath, '').removeAfter('/')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replace(queryPath, '').removeAfter('/'));
			}
		}
		return results;
	}
}

enum abstract AssetTypes(String) from (String) to (String)
{
	var SOUND:AssetTypes = 'sound';
	var MUSIC:AssetTypes = 'music';
	var IMAGE:AssetTypes = 'image';
	var TEXT:AssetTypes = 'text';
	var JSON:AssetTypes = 'json';
	var XML:AssetTypes = 'xml';
	var HSCRIPT:AssetTypes = 'hscript';
	var VIDEOS:AssetTypes = 'videos';
	var DIRECTORY:AssetTypes = 'directory';
	var FONT:AssetTypes = "font";
	var UNKNOWN:AssetTypes = 'unknown';

	public static function toOpenFlType(type:AssetTypes):AssetType
	{
		switch (type)
		{
			case FONT:
				return AssetType.FONT;
			case IMAGE:
				return AssetType.IMAGE;
			case MUSIC:
				return AssetType.MUSIC;
			case SOUND:
				return AssetType.SOUND;
			case XML | HSCRIPT | JSON | TEXT:
				return AssetType.TEXT;
			default:
				return AssetType.BINARY;
		}
	}

	public static function returnExts(type:AssetTypes):Array<String>
	{
		switch (type)
		{
			case SOUND | MUSIC:
				return [#if web "mp3" #else "ogg" #end];
			case IMAGE:
				return ['png'];
			case TEXT:
				return ['txt'];
			case JSON:
				return ['json'];
			case XML:
				return ['xml'];
			case HSCRIPT:
				return ['hscript', 'hx'];
			case VIDEOS:
				return ['mp4'];
			case FONT:
				return ['otf', 'ttf'];
			default:
				return [''];
		}
	}

	public static function returnTypeByExt(ext:String):Array<AssetTypes>
	{
		switch (ext)
		{
			case #if web "mp3" #else "ogg" #end:
				return [SOUND, MUSIC];
			case 'png':
				return [IMAGE];
			case 'json':
				return [JSON];
			case 'txt':
				return [TEXT];
			case 'xml':
				return [XML];
			case 'hscript' | 'hx':
				return [HSCRIPT];
			case 'mp4':
				return [VIDEOS];
			case 'otf' | 'ttf':
				return [FONT];
			default:
				return [UNKNOWN];
		}
	}

	public static function returnAllExts():Array<String>
	{
		return [
			#if web "mp3" #else "ogg" #end,
			'png',
			'txt',
			'json',
			'xml',
			'hscript',
			'hx',
			'mp4',
			'otf',
			'ttf'
		];
	}
}
