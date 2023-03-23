package gameplayStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import states.playState.GameData as Data;


class NoteSplash extends FlxSprite
{
	var curNoteskinSprite:String = 'Default';

	private var idleAnim:String;
	private var textureLoaded:String = null;

    override public function new(x:Float = 0, y:Float = 0)
    {
		super(x, y);

		if (OpenFlAssets.exists(Paths.image("notesplashes/" + NoteskinHelpers.getNoteskinByID(Main.save.data.noteskin))))
			curNoteskinSprite = NoteskinHelpers.getNoteskinByID(Main.save.data.noteskin);
		else
			curNoteskinSprite = 'Default';

		loadAnims(curNoteskinSprite);
		
		setupNoteSplash(x, y, null);
		antialiasing = Main.save.data.antialiasing;
    }

    public function setupNoteSplash(x:Float, y:Float, note:Note)
    {
		var texture:String;
		if (Data.isPixel)
			setPosition(x + 30, (y + Note.swagWidth) / 2);
		else
			setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
    	alpha = 0.6;

		var noteType = 'Default Note';
		var data = 0;
		texture = curNoteskinSprite;

		if (note != null)
		{
			noteType = note.noteType;
			data = note.noteData;
			texture = note.noteSplashTexture;
		}

		if (!OpenFlAssets.exists(Paths.image("notesplashes/" + texture)))
			texture = curNoteskinSprite;

		if(textureLoaded != texture)
			loadAnims(texture);

		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + data + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
    }

	function loadAnims(skin:String = 'default')
	{
		if (Data.isPixel)
		{
			if (OpenFlAssets.exists(Paths.image('notesplashes/' + skin + '-pixel')))
			{
				loadGraphic(Paths.loadImage('notesplashes/' + skin + '-pixel'));
				width = width / 8;
				height = height / 4;
				loadGraphic(Paths.loadImage('notesplashes/' + skin + '-pixel'), true, Math.floor(width), Math.floor(height));

				antialiasing = false;
				setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));

				animation.add("note0-1", [0, 1, 2, 3], 12, false);
				animation.add("note0-2", [4, 5, 6, 7], 12, false);
				animation.add("note1-1", [8, 9, 10, 11], 12, false);
				animation.add("note1-2", [12, 13, 14, 15], 12, false);
				animation.add("note2-1", [16, 17, 18, 19], 12, false);
				animation.add("note2-2", [20, 21, 22, 23], 12, false);
				animation.add("note3-1", [24, 25, 26, 27], 12, false);
				animation.add("note3-2", [28, 29, 30, 31], 12, false);
			}
			else
			{
				loadGraphic(Paths.loadImage('notesplashes/Default-pixel'));
				width = width / 8;
				height = height / 4;
				loadGraphic(Paths.loadImage('notesplashes/Default-pixel'), true, Math.floor(width), Math.floor(height));

				antialiasing = false;
				setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));

				animation.add("note0-1", [0, 1, 2, 3], 12, false);
				animation.add("note0-2", [4, 5, 6, 7], 12, false);
				animation.add("note1-1", [8, 9, 10, 11], 12, false);
				animation.add("note1-2", [12, 13, 14, 15], 12, false);
				animation.add("note2-1", [16, 17, 18, 19], 12, false);
				animation.add("note2-2", [20, 21, 22, 23], 12, false);
				animation.add("note3-1", [24, 25, 26, 27], 12, false);
				animation.add("note3-2", [28, 29, 30, 31], 12, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas("notesplashes/" + skin);
			for (i in 1...3) {
				animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
				animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
				animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
				animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			}
		}
	}

    override public function update(elapsed:Float)
    {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
    }
}