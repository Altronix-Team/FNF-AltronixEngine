package gameplayStuff;

import hx.strings.String8;
import openfl.display.Preloader.DefaultPreloader;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import states.PlayState;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.text.FlxText;

using StringTools;

typedef NoteMeta = {
	var imageFile:String;
	var size:Float;
	var listInSettings:Bool;
} 

//TODO Try to rework sustain note system
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
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

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

	var noteTypeCheck:String = PlayState.SONG.noteStyle;
	public var noteStyle:String;

	public var texture:String = null;

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

	var noteMetaData:NoteMeta = {
		imageFile: '',
		size: 0.7,
		listInSettings : true
	};

	private function set_noteType(value:String):String {
		if(noteData > -1 && noteType != value) {
			switch(value) {
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
			?bet:Float = 0, ?noteStyle:String)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		this.isAlt = isAlt;
		this.chartNote = inCharter;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		texture = PlayState.SONG.specialSongNoteSkin != null ? PlayState.SONG.specialSongNoteSkin : FlxG.save.data.noteskin;

		if (noteStyle == null)
			this.noteStyle = noteTypeCheck;
		else
			this.noteStyle = noteStyle;

		if (isAlt)
			animSuffix = '-alt';

		if (OpenFlAssets.exists(Paths.json('images/noteskins/$texture')))
		{
			noteMetaData = cast Paths.loadJSON('images/noteskins/$texture');
			texture = noteMetaData.imageFile;
		}
		else if (OpenFlAssets.exists(Paths.json('images/noteskins/$noteStyle')))
		{
			noteMetaData = cast Paths.loadJSON('images/noteskins/$noteStyle');
			texture = noteMetaData.imageFile;
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
			y += FlxG.save.data.offset + PlayState.songOffset;

		this.noteData = noteData;

		if (noteStyle == 'pixel')
			sustainNoteOffset = 30;
			
		if (sprTracker != null)
			x = sprTracker.x;
		else
			x += swagWidth * noteData;	

		animation.play(dataColor[noteData] + 'Scroll');

		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2)) / PlayState.songMultiplier;

		startAnim();

		created = true;
	}

	function reloadNote(meta:NoteMeta) {
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

			antialiasing = FlxG.save.data.antialiasing;
		}

		if (created)
			startAnim();
	}

	function startAnim(){
		animation.play(dataColor[noteData] + 'Scroll', true);

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originAngle = prevNote.originAngle;

			animation.play(dataColor[noteData] + 'holdend');
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
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = modAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (lasttexture != texture)
		{
			lasttexture = texture;
			if (OpenFlAssets.exists(Paths.json('images/noteskins/$texture')))
			{
				noteMetaData = cast Paths.loadJSON('images/noteskins/$texture');
				texture = noteMetaData.imageFile;
			}
			else if (OpenFlAssets.exists(Paths.json('images/noteskins/$noteStyle')))
			{
				noteMetaData = cast Paths.loadJSON('images/noteskins/$noteStyle');
					texture = noteMetaData.imageFile;
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

		if (sprTracker != null)
		{
			if (!isSustainNote)
			{
				if (x != sprTracker.x)
					x = sprTracker.x;
			}
			else
			{
				if (parent != null && x != parent.x + sustainNoteOffset)
				{
					x = parent.x + sustainNoteOffset;
				}
			}
		}

		if (mustPress || PlayStateChangeables.twoPlayersMode)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime - Conductor.songPosition < (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))) && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;
			// if (strumTime <= Conductor.songPosition)
			//	wasGoodHit = true;
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
		for (i in 0...4)
		{
			animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
			animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
			animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
		}
	}

	function loadPixelAnims()
	{
		for (i in 0...4)
		{
			animation.add(dataColor[i] + 'Scroll', [i + 4]);
			animation.add(dataColor[i] + 'hold', [i]);
			animation.add(dataColor[i] + 'holdend', [i + 4]);
		}
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
