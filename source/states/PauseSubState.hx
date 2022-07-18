package states;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if FEATURE_LUAMODCHART
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameplayStuff.PlayStateChangeables;
import gameplayStuff.Song;

using hx.strings.Strings;
class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	public static var goToOptions:Bool = false;
	public static var goBack:Bool = false;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;
	var difficultyChoices = [];

	var pauseMusic:FlxSound;

	var perSongOffset:FlxText;

	var offsetChanged:Bool = false;
	var startOffset:Float = PlayState.songOffset;

	var bg:FlxSprite;

	var detailsText:String = "";
	var storyDifficultyText:String = "";
	var iconRPC:String = "";

	public function new()
	{
		super();


		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.ID = 9000;

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.songName;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Hello chat", 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if (PlayState.isStoryMode){
			if (!FlxG.save.data.language) detailsText = "Story Mode: Week " + PlayState.storyWeek + ":";
			else detailsText = "Режим истории: Неделя " + PlayState.storyWeek + ":";}
		if (PlayState.isFreeplay){
			if (!FlxG.save.data.language)
				detailsText = "Freeplay";
			else
				detailsText = "Свободная игра";}
		if (PlayState.isExtras){
			if (!FlxG.save.data.language)
				detailsText = 'Extras';
			else
				detailsText = 'Дополнительно';}
		if (PlayState.fromPasswordMenu){
			if (!FlxG.save.data.language)
				detailsText = 'Extras';
			else
				detailsText = 'Дополнительно';}

		iconRPC = PlayState.SONG.player2;

		switch (iconRPC){
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';}

		storyDifficultyText = CoolUtil.difficultyFromInt(PlayState.storyDifficulty);

		#if desktop
			if (PlayStateChangeables.botPlay){
				if (!FlxG.save.data.language) DiscordClient.changePresence("Paused on " + PlayState.SONG.songName + " (" + storyDifficultyText + ") " + 'Botplay',null, iconRPC);
				else DiscordClient.changePresence("Стоит на паузе " + PlayState.SONG.songName + " (" + storyDifficultyText + ") " + 'Бот-плей',null, iconRPC);}
			else if (!PlayStateChangeables.botPlay){
				if (!FlxG.save.data.language){DiscordClient.changePresence("PAUSED on "+ PlayState.SONG.songId+ " ("+ storyDifficultyText+ ") ",null, iconRPC);}
				else{DiscordClient.changePresence("Стоит на паузе "+ PlayState.SONG.songId+ " ("+ storyDifficultyText+ ") ",null, iconRPC);}}
			#end

		#if FEATURE_FILESYSTEM
		add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		difficultyChoices = CoolUtil.songDiffs.get(PlayState.SONG.songId);

		difficultyChoices.push('BACK');

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);


		for (i in FlxG.sound.list)
		{
			if (i.playing && i.ID != 9000)
				i.pause();
		}

		if (bg.alpha > 0.6)
			bg.alpha = 0.6;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		var songPath = 'assets/data/songs/${PlayState.SONG.songId}/';

		#if FEATURE_STEPMANIA
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P || upPcontroller)
		{
			changeSelection(-1);
		}
		else if (controls.DOWN_P || downPcontroller)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT && !FlxG.keys.pressed.ALT)
		{
			var daSelected:String = menuItems[curSelected];

			if (menuItems == difficultyChoices)
				{
					if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) 
					{
						if (PlayState.isFreeplay)
						{
							var currentSongData = FreeplayState.songData.get(PlayState.SONG.songId)[difficultyChoices.indexOf(daSelected)];
							//var name:String = PlayState.SONG.songId;
							//var poop = Highscore.formatSongDiff(name, CoolUtil.difficultyArray.indexOf(daSelected));
							PlayState.SONG = currentSongData;
							PlayState.storyDifficulty = CoolUtil.difficultyArray.indexOf(daSelected);
							restartSong();
							FlxG.sound.music.volume = 0;
							return;	
						}
						else
						{
							var diff:String = '';
							switch (daSelected)
							{
								case 'Easy':
									diff = "-easy";
								case 'Hard':
									diff = "-hard";
								case 'Hard P':
									diff = "-hardplus";
								case 'Normal':
									diff = '';
								default:
									diff = "-" + daSelected.toLowerCase();
							}
							PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.SONG.songId, diff));
							PlayState.storyDifficulty = CoolUtil.difficultyArray.indexOf(daSelected);
							restartSong();
							FlxG.sound.music.volume = 0;
							return;	
						}
					}
	
					menuItems = menuItemsOG;
					regenMenu();
				}

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					restartSong();
					PlayState.stageTesting = false;

				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();

				case "Options":
					goToOptions = true;
					close();

				case "Exit to menu":
					PlayState.startTime = 0;
					PlayState.stageTesting = false;
					if (FlxG.save.data.fpsCap > 340)
						(cast(Lib.current.getChildAt(0), Main)).setFPSCap(120);

					PlayState.instance.clean();

					if (PlayState.isStoryMode)
					{
						GameplayCustomizeState.freeplayBf = 'bf';
						GameplayCustomizeState.freeplayDad = 'dad';
						GameplayCustomizeState.freeplayGf = 'gf';
						GameplayCustomizeState.freeplayNoteStyle = 'normal';
						GameplayCustomizeState.freeplayStage = 'stage';
						GameplayCustomizeState.freeplaySong = 'bopeebo';
						GameplayCustomizeState.freeplayWeek = 1;
						MusicBeatState.switchState(new StoryMenuState());
					}
					else if (PlayState.isFreeplay)
						MusicBeatState.switchState(new FreeplayState());
					else if (PlayState.isExtras)
						MusicBeatState.switchState(new SecretState());
					else if (PlayState.fromPasswordMenu)
						MusicBeatState.switchState(new MainMenuState());
					PlayState.isStoryMode = false;
					PlayState.isExtras = false;
					PlayState.fromPasswordMenu = false;
					PlayState.isFreeplay = false;
					PlayState.chartingMode = false;
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	public static function restartSong(noTrans:Bool = false)
		{
			PlayState.instance.paused = true;
			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;
	
			if(noTrans)
			{
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.resetState();
			}
			else
			{
				FlxG.resetState();
			}
		}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}

	override function destroy()
	{
		if (!goToOptions)
		{
			Debug.logTrace("destroying music for pauseeta");
			pauseMusic.destroy();
		}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	override function onWindowFocusOut():Void
	{
		pauseMusic.pause();
	}
	override function onWindowFocusIn():Void
	{
		pauseMusic.resume();
	}
}
