package gameplayStuff;

import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StaticArrow extends FlxSprite
{
	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside here
	public var resetAnim:Float = 0;

	public var noteData:Int = 0;
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var texture(default, set):String = null;
	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			loadNote();
		}
		return value;
	}

	public function new(xx:Float, yy:Float)
	{
		x = xx;
		y = yy;
		super(x, y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if (!modifiedByLua)
			angle = localAngle + modAngle;
		else
			angle = modAngle;
		super.update(elapsed);

		if (FlxG.keys.justPressed.THREE)
		{
			localAngle += 10;
		}
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		if (!AnimName.startsWith('dirCon'))
		{
			localAngle = 0;
		}
		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		offset.x -= 54;
		offset.y -= 56;

		angle = localAngle + modAngle;
	}

	function loadNote()
	{
		switch (PlayState.instance.noteTypeCheck)
		{
			case 'pixel':
				loadGraphic(NoteskinHelpers.generatePixelSprite(texture), true, 17, 17);
				animation.add('green', [6]);
				animation.add('red', [7]);
				animation.add('blue', [5]);
				animation.add('purplel', [4]);

				setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));
				updateHitbox();
				antialiasing = false;

				x += Note.swagWidth * noteData;
				animation.add('static', [noteData]);
				animation.add('pressed', [4 + noteData, 8 + noteData], 12, false);
				animation.add('confirm', [12 + noteData, 16 + noteData], 12, false);
			default:
				if (PlayState.instance.noteTypeCheck == 'normal')
				{
					frames = NoteskinHelpers.generateNoteskinSprite(texture);

					var lowerDir:String = dataSuffix[noteData].toLowerCase();

					animation.addByPrefix('static', 'arrow' + dataSuffix[noteData]);
					animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					x += Note.swagWidth * noteData;

					antialiasing = Main.save.data.antialiasing;
					setGraphicSize(Std.int(width * 0.7));	
				}
				else
				{
					frames = NoteskinHelpers.generateNoteskinSprite(PlayState.instance.noteTypeCheck);

					var lowerDir:String = dataSuffix[noteData].toLowerCase();

					animation.addByPrefix('static', 'arrow' + dataSuffix[noteData]);
					animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					x += Note.swagWidth * noteData;

					antialiasing = Main.save.data.antialiasing;
					setGraphicSize(Std.int(width * 0.7));	
				}						
		}
	}
}
