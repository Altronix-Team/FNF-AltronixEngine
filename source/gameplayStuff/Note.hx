package gameplayStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameplayStuff.DiffOverview;
import gameplayStuff.Song;
import openfl.display.BitmapData;
import openfl.display.Preloader.DefaultPreloader;
import openfl.utils.Assets as OpenFlAssets;
import states.FreeplayState;
import states.playState.GameData as Data;
import states.playState.PlayState;

typedef NoteMeta =
{
	var imageFile:String;
	var ?noteSplashFile:String;
	var size:Float;
	var listInSettings:Bool;
}

// TODO Try to rework sustain note system
class Note extends FlxSprite
{
	public var sprTracker:FlxSprite = null;
	public var sustainNoteOffset:Int = 35;

	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;
	public var noteType(default, set):String = null;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isEnd:Bool = false;
	public var noteSection:Int = 0;

	public var isAlt:Bool = false;

	public var noteTypeText:AttachedFlxText;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public var beat:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	var noteTypeCheck:String = 'normal';

	public var noteStyle:String;

	public var texture(default, set):String = null;

	public var noteSplashTexture:String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var gfNote:Bool = false;
	public var hurtNote:Bool = false;
	public var bulletNote:Bool = false;
	public var ignoreNote:Bool = false;
	public var missHealth:Float = 0.0475;

	public var hitByP2:Bool = false;

	public var animSuffix:String = '';

	var animName:String = null;

	var lasttexture:String = null;

	var chartNote:Bool = false;

	var stepHeight:Float = 0;

	var created:Bool = false;

	public var fromDiffOverviev:Bool = true;

	var SONG:SongData = null;

	var songMultiplier:Float = 1.0;

	var noteColor:String = '';

	var noteMetaData:NoteMeta = {
		imageFile: '',
		size: 0.7,
		listInSettings: true
	};

	private function set_noteType(value:String):String
	{
		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Bullet Note':
					texture = 'Bullet_Note';
					noteMetaData.imageFile = 'Bullet_Note';
					reloadNote(noteMetaData);
					bulletNote = true;

				case 'Hurt Note':
					texture = 'HURTNOTE_assets';
					ignoreNote = true;
					noteMetaData.imageFile = 'HURTNOTE_assets';
					reloadNote(noteMetaData);
					hurtNote = true;

				case 'No Animation':
					noAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false,
			?bet:Float = 0, ?noteStyle:String = 'normal', ?fromPreview:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		this.isAlt = isAlt;
		this.chartNote = inCharter;
		this.noteData = noteData;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		this.fromDiffOverviev = fromPreview;

		noteColor = dataColor[this.noteData];

		if (fromPreview)
		{
			SONG = DiffOverview.instance.SONG;
			songMultiplier = FreeplayState.rate;
		}
		else
		{
			SONG = Data.SONG;
			songMultiplier = Data.songMultiplier;
		}

		texture = SONG.specialSongNoteSkin != null ? SONG.specialSongNoteSkin : Main.save.data.noteskin;

		if (noteStyle == null)
			this.noteStyle = SONG.noteStyle;
		else
			this.noteStyle = noteStyle;

		if (isAlt)
			animSuffix = '-alt';

		if (OpenFlAssets.exists(Paths.json('images/noteskins/$texture')))
		{
			noteMetaData = cast Paths.loadJSON('images/noteskins/$texture');
		}
		else if (OpenFlAssets.exists(Paths.json('images/noteskins/$noteStyle')))
		{
			noteMetaData = cast Paths.loadJSON('images/noteskins/$noteStyle');
		}
		else
		{
			noteMetaData = {
				imageFile: texture,
				size: 0.7,
				listInSettings: true
			}
		}

		if (noteMetaData.noteSplashFile != null)
			noteSplashTexture = noteMetaData.noteSplashFile;
		else
			noteSplashTexture = noteMetaData.imageFile;

		reloadNote(noteMetaData);

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		if (!inCharter)
			y += Main.save.data.offset;

		if (noteStyle == 'pixel')
			sustainNoteOffset = 30;

		if (sprTracker != null)
			x = sprTracker.x;
		else
			x += swagWidth * noteData;

		animation.play(noteColor + 'Scroll');

		stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
			2)) / songMultiplier;

		startAnim();

		created = true;

		if (isSustainNote)
			alpha = 0.5;
	}

	function reloadNote(meta:NoteMeta)
	{
		if (noteStyle == 'pixel')
		{
			loadGraphic(NoteskinHelpers.generatePixelSprite(meta.imageFile), true, 17, 17);
			if (isSustainNote)
				loadGraphic(NoteskinHelpers.generatePixelSprite(meta.imageFile, true), true, 7, 6);

			loadPixelAnims();

			if (chartNote)
				setGraphicSize(40, 40);
			else
				setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));

			updateHitbox();
		}
		else
		{
			frames = NoteskinHelpers.generateNoteskinSprite(meta.imageFile);
			loadDefaultAnims();

			if (chartNote)
				setGraphicSize(40, 40);
			else
				setGraphicSize(Std.int(width * meta.size));

			updateHitbox();

			antialiasing = Main.save.data.antialiasing;
		}

		if (created)
			startAnim();
	}

	function startAnim()
	{
		animation.play(noteColor + 'Scroll', true);

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originAngle = prevNote.originAngle;

			animation.play(noteColor + 'holdend');
			updateHitbox();

			x -= width / 2;

			if (chartNote)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.noteData] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();

				if (antialiasing)
					prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
			}
		}

		if (animation.curAnim != null)
		{
			if (animation.curAnim.name.endsWith('holdend'))
				isEnd = true;
			else
				isEnd = false;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		if (!sustainActive)
		{
			alpha = 0.3;
		}

		if (Main.save.data.downscroll != flipY && isSustainNote)
			flipY = Main.save.data.downscroll;

		if (sprTracker != null)
		{
			visible = sprTracker.visible;
			x = sprTracker.x;
			if (!isSustainNote)
				modAngle = cast(sprTracker, StaticArrow).modAngle;
			if (sustainActive)
			{
				alpha = sprTracker.alpha;
			}
			modAngle = cast(sprTracker, StaticArrow).modAngle;

			if (isSustainNote)
			{
				x += width / 2 + 20;
				if (noteTypeCheck == 'pixel')
					x -= 11;
			}
		}

		if (mustPress || PlayStateChangeables.twoPlayersMode)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (songMultiplier < 1 ? songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (songMultiplier < 1 ? songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (songMultiplier < 1 ? songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime - Conductor.songPosition < (((-166 * Conductor.timeScale) / (songMultiplier < 1 ? songMultiplier : 1)))
				&& !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function changeStyle()
	{
		if (noteTypeCheck == 'pixel')
			noteTypeCheck = 'normal';
		else
			noteTypeCheck = 'pixel';

		reloadNote(noteMetaData);
	}

	function loadDefaultAnims()
	{
		var allPrefixes = NoteskinHelpers.getPrefixesList(noteMetaData.imageFile);
		if (!isSustainNote)
		{
			// Normal notes
			if (allPrefixes.contains(noteColor))
				animation.addByPrefix(noteColor + 'Scroll', noteColor + '0');
			else
				animation.addByPrefix(noteColor + 'Scroll', noteColor + ' alone');
		}
		else
		{
			// Hold
			if (allPrefixes.contains(noteColor + ' hold piece'))
				animation.addByPrefix(noteColor + 'hold', noteColor + ' hold piece');
			else
				animation.addByPrefix(noteColor + 'hold', noteColor + ' hold');

			// Tails
			if (allPrefixes.contains(noteColor + ' hold end'))
				animation.addByPrefix(noteColor + 'holdend', noteColor + ' hold end');
			else if (allPrefixes.contains('pruple end hold') && noteColor == 'purple') // Funny
				animation.addByPrefix(noteColor + 'holdend', 'pruple end hold');
			else
				animation.addByPrefix(noteColor + 'holdend', noteColor + ' tail');
		}
	}

	function loadPixelAnims()
	{
		if (!isSustainNote)
		{
			animation.add(noteColor + 'Scroll', [noteData + 4]);
		}
		else
		{
			animation.add(noteColor + 'hold', [noteData]);
			animation.add(noteColor + 'holdend', [noteData + 4]);
		}
	}

	function set_texture(value:String):String
	{
		if (value != null)
		{
			texture = value;

			if (created)
			{
				if (OpenFlAssets.exists(Paths.json('images/noteskins/$texture')))
				{
					noteMetaData = cast Paths.loadJSON('images/noteskins/$texture');
				}
				else if (OpenFlAssets.exists(Paths.json('images/noteskins/$noteStyle')))
				{
					noteMetaData = cast Paths.loadJSON('images/noteskins/$noteStyle');
				}
				else
				{
					noteMetaData = {
						imageFile: texture,
						size: 0.7,
						listInSettings: true
					}
				}
				reloadNote(noteMetaData);
			}
		}
		return value;
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var strumTime:Float = 0;
	public var position:Int = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}