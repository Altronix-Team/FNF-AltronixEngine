package utils;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import gameplayStuff.Note;

using StringTools;

class NoteskinHelpers
{
	public static var noteskinArray = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		for (i in Paths.listImagesInPath('noteskins/'))
		{
			var noteMetaData:NoteMeta = null;
			if (OpenFlAssets.exists(Paths.json('images/noteskins/$i')))
			{
				if (OpenFlAssets.exists(Paths.json('images/noteskins/$i')))
					noteMetaData = cast Paths.loadJSON('images/noteskins/$i');
			}
			if (noteMetaData != null)
				if (!noteMetaData.listInSettings)
					continue;

			if (i.contains("-pixel"))
				continue;

			if (!i.endsWith(".png"))
				continue;
			
			noteskinArray.push(i.replace(".png", ""));	
		}

		return noteskinArray;
	}

	public static function getNoteskins()
	{
		return noteskinArray;
	}

	public static function getIDByNoteskin(skin:String)
	{
		return noteskinArray.indexOf(skin);
	}

	public static function getNoteskinByID(id:Int)
	{
		return noteskinArray[id];
	}

	static public function generateNoteskinSprite(id:String)
	{
		return Paths.getSparrowAtlas('noteskins/' + id, "shared");	
	}

	static public function generatePixelSprite(id:String, ends:Bool = false)
	{
		var path = "noteskins/" + id + "-pixel" + (ends ? "-ends" : "");

		var defaultBitmap = BitmapData.fromFile("assets/shared/images/noteskins/Arrows-pixel" + (ends ? "-ends" : "") + ".png");

		if (!OpenFlAssets.exists(Paths.image(path, 'shared')))
		{
			return defaultBitmap;
		}
		else
		{
			if (BitmapData.fromFile(Paths.image(path, 'shared')) != null) //It can return null, lol
				return BitmapData.fromFile(Paths.image(path, 'shared'));
			else
				return defaultBitmap;
		}
	}
}	
