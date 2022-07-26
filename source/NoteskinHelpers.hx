import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class NoteskinHelpers
{
	public static var noteskinArray = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		var count:Int = 0;
		for (i in Paths.listImagesInPath('noteskins/'))
		{
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

	public static function getNoteskinByID(id:Int)
	{
		return noteskinArray[id];
	}

	static public function generateNoteskinSprite(id:Int)
	{
		return Paths.getSparrowAtlas('noteskins/' + getNoteskinByID(id), "shared");	
	}

	static public function generateSpecialPixelSprite(id:String, ends:Bool = false)
	{
		var path = "assets/shared/images/specialnotes" + "/" + id + "-pixel" + (ends ? "-ends" : "");
		return BitmapData.fromFile(path + ".png");
	}

	static public function generatePixelSprite(id:Int, ends:Bool = false)
	{
		var path = "assets/shared/images/noteskins/" + getNoteskinByID(id) + "-pixel" + (ends ? "-ends" : "");

		if (Paths.isFileReplaced("shared/images/noteskins/" + getNoteskinByID(id) + "-pixel" + (ends ? "-ends" : "") + '.png'))
		{
			if (!OpenFlAssets.exists(OpenFlAssets.getPath(path + '.png')))
			{
				return BitmapData.fromFile(OpenFlAssets.getPath("assets/shared/images/noteskins" + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png"));
			}
			return BitmapData.fromFile(OpenFlAssets.getPath(path + '.png'));
		}
		else
		{
			if (!OpenFlAssets.exists(Paths.image('noteskins/${getNoteskinByID(id)}-pixel' + (ends ? '-ends' : ''), 'shared')))
			{
				Debug.logTrace("getting default pixel skin");
				return BitmapData.fromFile("assets/shared/images/noteskins" + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
			}
			return BitmapData.fromFile(path + '.png');
		}
	}
}	
