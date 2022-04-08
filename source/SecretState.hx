package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.effects.FlxFlicker;
import openfl.Lib;
import flixel.tweens.FlxTween;
import LoadingState.LoadingsState;
import openfl.utils.Assets as OpenFlAssets;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class SecretState extends MusicBeatState
{
	var songs:Array<SongMetadata4> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 2;
	var songListen:Bool = false;

	var scoreText:FlxText;
	var diffText:FlxText;
	var comboText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	public static var downscroll:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	private var bgColorArray:Array<Int> = [];
	public var intendedColor:FlxColor;
	public var extrasBgColor:FlxColor;
	var colorTween:FlxTween;

	override function create()
	{
		FlxG.mouse.visible = false;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeIn(2, 0, 0.8);
			FlxG.sound.playMusic(Paths.music('south'), 0);
		}

		#if desktop
		// Updating Discord Rich Presence
		if (MainMenuState.extra == 1)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence("In Fun Secret Menu", null);
			else
				DiscordClient.changePresence("В секретном меню 'Веселья'", null);
		}
		else if (MainMenuState.extra == 2)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence("In Tankman Secret Menu", null);
			else
				DiscordClient.changePresence("В секретном меню 'Танкмена'", null);
		}
		else if (MainMenuState.extra == 3)
		{
			if (!FlxG.save.data.language)
				DiscordClient.changePresence("In Debug Secret Menu", null);
			else
				DiscordClient.changePresence("В секретном меню отладки", null);
		}	
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end
		if (MainMenuState.extra == 1)
		{
			addWeek(['rainglint(old)'], 1, ['bassmachine']);
			addWeek(['Happy', 'Crimsong'], 2, ['bassmachine']);
			addWeek(['manifest'], 2, ['riftmanifest']);
			bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
			add(bg);
		}
		else if (MainMenuState.extra == 2)
		{
			addWeek(['Ugh', 'Guns', 'Stress'], 1, ['tankman']);
			bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
			add(bg);
		}
		else if (MainMenuState.extra == 3)
		{
			addWeek(['South'], 1, ['pico']);
			addWeek(['Last-Hope'], 1, ['mom']);
			addWeek(['test'], 1, ['senpai']);
			bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
			add(bg);
			var debugText = new FlxText(0, 600, 0, "This is something shit, which you don't want to see", 24);
			debugText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			add(debugText);

		}	
		// LOAD MUSIC

		// LOAD CHARACTERS

		

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press 7 to go to the Charting Menu";
		var size:Int = 16;
		#else
		var leText:String = "Press 7 to go to the Charting Menu.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		add(scoreText);

		changeSelection();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	function getCharacterColor()
	{
		Debug.logInfo('Getting character color (${songs[curSelected].songCharacter})');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData;
		if (OpenFlAssets.exists(Paths.json('characters/${songs[curSelected].songCharacter}')))
			jsonData = Paths.loadJSON('characters/${songs[curSelected].songCharacter}');
		else
			jsonData = Paths.loadJSON('modcharacters/${songs[curSelected].songCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${songs[curSelected].songCharacter}');
			extrasBgColor = FlxColor.fromRGB(255, 255, 255);
			return;
		}

		var data:ExtrasCharColor = cast jsonData;

		if (data.barColorJson != null && data.barColorJson.length > 2)
			bgColorArray = data.barColorJson;
		extrasBgColor = FlxColor.fromRGB(bgColorArray[0], bgColorArray[1], bgColorArray[2]);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata4(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	private static var vocals:FlxSound = null;

	var instPlaying:Int = -1;

	public static function destroyExtrasVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			changeDiff(-1);
		}
		if (FlxG.keys.justPressed.RIGHT)
		{
			changeDiff(1);
		}

		if (controls.BACK)
		{
			PlayState.isFreeplay = true;
			PlayState.isExtras = false;
			FlxG.sound.music.stop();
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			if (!songListen)
			{
				#if PRELOAD_ALL
				destroyExtrasVocals();
				FlxG.sound.music.volume = 0;
				var poop:String = Highscore.formatSongDiff(songs[curSelected].songName.toLowerCase(), curDifficulty);

				PlayState.SONG = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), poop);
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				songListen = true;
				#end
			}
			else
			{
				destroyExtrasVocals();
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
				songListen = false;
			}
		}

		if (accepted)
		{
			destroyExtrasVocals();

			var poop:String = Highscore.formatSongDiff(songs[curSelected].songName.toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), poop);
			PlayState.isStoryMode = false;
			PlayState.isFreeplay = false;
			PlayState.isExtras = true;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			var llll = FlxG.sound.play(Paths.sound('confirmMenu')).length;
			grpSongs.forEach(function(e:Alphabet)
			{
				if (e.text != songs[curSelected].songName)
				{
					FlxTween.tween(e, {x: -6000}, llll / 1000, {
						onComplete: function(e:FlxTween)
						{
							if (FlxG.keys.pressed.ALT)
							{
								FlxG.switchState(new ChartingState());
							}
							else
							{
								openSubState(new LoadingsState());
								LoadingState.loadAndSwitchState(new PlayState());
							}
						}
					});
				}
				else
				{
					FlxFlicker.flicker(e);
					trace(curSelected);
					FlxTween.tween(e, {x: e.x + 20}, llll / 1000);
				}
			});
		}
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
			case 'rain-glint':
				songHighscore = 'RainGlint';
			case 'rain-glint-(old)':
				songHighscore = 'RainGlint(old)';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 2:
				diffText.text = "HARD";
			case 3:
				diffText.text = "HARD P";
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 2)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 2;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
			case 'rain-glint':
				songHighscore = 'RainGlint';
			case 'rain-glint-(old)':
				songHighscore = 'RainGlint(old)';
		}


		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
			case 'rain-glint':
				songHighscore = 'RainGlint';
			case 'rain-glint-(old)':
				songHighscore = 'RainGlint(old)';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		getCharacterColor();
		if (extrasBgColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = extrasBgColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		FlxG.sound.music.pause();
		vocals.pause();
	}

	override function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		FlxG.sound.music.resume();
		vocals.resume();
	}
}

class SongMetadata4
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
typedef ExtrasCharColor =
{
	var barColorJson:Array<Int>;
}