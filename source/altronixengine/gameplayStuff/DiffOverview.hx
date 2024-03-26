package altronixengine.gameplayStuff;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import altronixengine.gameplayStuff.Section.SwagSection;
import altronixengine.gameplayStuff.Song.SongData;
import altronixengine.states.FreeplayState;
import altronixengine.states.MusicBeatSubstate;

@:access(states.FreeplayState)
class DiffOverview extends MusicBeatSubstate
{
	public static var instance:DiffOverview = null;

	var blackBox:FlxSprite;

	public var SONG:SongData;

	var strumLine:FlxSprite;
	var camHUD:FlxCamera;

	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var opponentStrums:FlxTypedGroup<StaticArrow> = null;

	public function new(_song:SongData)
	{
		SONG = _song;

		super();
	}

	override function create()
	{
		instance = this;

		FlxG.sound.music.pause();

		Conductor.songPosition = 0;
		Conductor.lastSongPos = 0;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		var camGame = new FlxCamera();

		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD);

		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		opponentStrums = new FlxTypedGroup<StaticArrow>();

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBox.alpha = 0;
		add(blackBox);

		generateStrumLineArrows();

		add(opponentStrums);
		add(playerStrums);

		generateSong();

		playerStrums.cameras = [camHUD];
		opponentStrums.cameras = [camHUD];
		notes.cameras = [camHUD];
		blackBox.cameras = [camHUD];

		blackBox.height = camHUD.height;

		camHUD.alpha = 0;

		inst.fadeIn();
		vocals.fadeIn();
		FlxTween.tween(blackBox, {alpha: 0.5}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.expoInOut});

		var songTxt:FlxText = new FlxText(0, 5, 0, SONG.songName);
		songTxt.setFormat(Paths.font(LanguageStuff.fontName), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
		songTxt.scrollFactor.set();
		songTxt.cameras = [camHUD];
		songTxt.screenCenter(X);
		add(songTxt);

		trace('pog');

		super.create();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		inst.play();
		Conductor.songPosition = inst.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var stopDoingShit = false;

	override function stepHit()
	{
		if (inst != null)
		{
			if (inst.time > Conductor.songPosition + 20 || inst.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		super.stepHit();
	}

	function offsetChange()
	{
		for (i in unspawnNotes)
			i.strumTime = i.baseStrum + Main.save.data.offset;
		for (i in notes)
			i.strumTime = i.baseStrum + Main.save.data.offset;
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		// input

		if (frames < 10)
		{
			frames++;
			return;
		}

		if (stopDoingShit)
			return;

		if (FlxG.keys.pressed.SPACE)
		{
			stopDoingShit = true;
			quit();
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
			if (gamepad.justPressed.X)
			{
				stopDoingShit = true;
				quit();
			}

		if (vocals != null)
			if (vocals.playing)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = vocals.time;
			}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * FreeplayState.rate)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				dunceNote.cameras = [camHUD];

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			daNote.y = (daNote.sprTracker.y
				- 0.45 * ((Conductor.songPosition - daNote.strumTime) / FreeplayState.rate) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
					2)))
				+ daNote.noteYOff;

			if (daNote.isSustainNote)
			{
				if ((!daNote.mustPress || daNote.wasGoodHit && !daNote.ignoreNote)
					&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
				{
					// Clip to strumline
					var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					swagRect.y = (daNote.sprTracker.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}
			}

			daNote.visible = daNote.sprTracker.visible;
			daNote.x = daNote.sprTracker.x;
			if (!daNote.isSustainNote)
				daNote.angle = daNote.sprTracker.angle;
			daNote.alpha = daNote.sprTracker.alpha;

			// auto hit
			if (daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (daNote.canBeHit || daNote.tooLate || !daNote.mustPress)
				{
					var time:Float = 0.15;
					if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
					{
						time += 0.15;
					}

					pressArrow(daNote.sprTracker, daNote.noteData, daNote, time);

					daNote.wasGoodHit = true;
					vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}

			if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
			{
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}

			if (daNote.isSustainNote)
			{
				daNote.x += daNote.width / 2 + 20;
				if (SONG.noteStyle == 'pixel')
					daNote.x -= 11;
			}
		});

		super.update(elapsed);
	}

	function pressArrow(spr:FlxSprite, idCheck:Int, daNote:Note, ?time:Float)
	{
		var arrow:StaticArrow = null;
		if (Std.isOfType(spr, StaticArrow))
			arrow = cast(spr, StaticArrow);

		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (arrow != null)
				arrow.playAnim('confirm', true);
			if (time != null)
				arrow.resetAnim = time;
		}
	}

	public function quit()
	{
		notes.clear();

		FlxTween.tween(blackBox, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.expoInOut});

		vocals.fadeOut();

		FreeplayState.openedPreview = false;

		inst.fadeOut(1, 0, function(twn:FlxTween)
		{
			FlxG.sound.music.play();
			close();
		});
	}

	override function destroy()
	{
		clean();

		vocals.stop();
		vocals.destroy();
		vocals = null;

		inst.stop();
		inst.destroy();
		inst = null;

		super.destroy();
	}

	var vocals:FlxSound;

	var inst:FlxSound;

	var notes:FlxTypedGroup<Note>;
	var unspawnNotes:Array<Note> = [];

	public function generateSong():Void
	{
		Conductor.changeBPM(SONG.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.songId, SONG.diffSoundAssets));
		else
			vocals = new FlxSound();

		if (vocals != null)
			vocals.volume = 0;

		inst = new FlxSound().loadEmbedded(Paths.inst(SONG.songId, SONG.diffSoundAssets), false, false, endSong);
		FlxG.sound.list.add(inst);
		inst.volume = 0;

		trace('loaded sounds');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		trace('loading notes');
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / FreeplayState.rate;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && (!section.mustHitSection || section.gfSection))
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var daType = null;

				if (songNotes[5] != null)
					daType = songNotes[5];
				else
					daType = 'Default Note';

				var altNote = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				var noteStyle = 'normal';

				if (songNotes[6] != null)
					noteStyle = songNotes[6];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, altNote, songNotes[4], noteStyle, true);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / FreeplayState.rate)));
				swagNote.scrollFactor.set(0, 0);
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = daType;
				if (!gottaHitNote)
					swagNote.sprTracker = opponentStrums.members[daNoteData];
				else
					swagNote.sprTracker = playerStrums.members[daNoteData];

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				swagNote.isAlt = altNote;

				if (songNotes[3])
					swagNote.animSuffix = '-alt';

				if (susLength > 0)
					swagNote.isParent = true;

				unspawnNotes.push(swagNote);

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					var altSusNote = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var noteStyle = 'normal';
					if (songNotes[6] != null)
						noteStyle = songNotes[6];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false,
						altSusNote, 0, noteStyle, true);
					sustainNote.scrollFactor.set();
					sustainNote.isAlt = altSusNote;
					sustainNote.parent = swagNote;

					sustainNote.mustPress = gottaHitNote;
					sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
					sustainNote.noteType = daType;
					if (!gottaHitNote)
						sustainNote.sprTracker = opponentStrums.members[daNoteData];
					else
						sustainNote.sprTracker = playerStrums.members[daNoteData];

					if (songNotes[3])
						sustainNote.animSuffix = '-alt';

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					unspawnNotes.push(sustainNote);
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}
		trace('loaded notes');

		unspawnNotes.sort(sortByShit);

		if (inst != null)
			inst.play();

		if (vocals != null)
			vocals.play();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStrumLineArrows()
	{
		for (player in 0...2)
		{
			for (i in 0...4)
			{
				var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y, SONG);
				babyArrow.noteData = i;
				babyArrow.texture = Main.save.data.noteskin;

				babyArrow.updateHitbox();
				babyArrow.scrollFactor.set();

				babyArrow.ID = i;

				switch (player)
				{
					case 0:
						babyArrow.x += 20;
						opponentStrums.add(babyArrow);
					case 1:
						playerStrums.add(babyArrow);
				}

				babyArrow.playAnim('static');
				babyArrow.x += 110;
				babyArrow.x += ((FlxG.width / 2) * player);

				opponentStrums.forEach(function(spr:StaticArrow)
				{
					spr.centerOffsets(); // CPU arrows start out slightly off-center
				});
			}
		}
	}

	function endSong()
	{
		quit();
	}
}
