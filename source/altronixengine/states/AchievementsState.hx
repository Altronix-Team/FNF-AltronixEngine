package states;

import core.Achievements;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.media.Sound;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.Future;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class AchievementsState extends MusicBeatState
{
	var bg:FlxSprite;
	private var grpAchievements:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AchievementSprite> = [];
	var curSelected:Int = 0;
	var descText:FlxText;
	var checkedAchievements:Array<String> = [];

	override function create()
	{
		clean();

		var savedAchievements:Array<String> = Main.save.data.savedAchievements;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Achievements Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.loadImage('menuDesat'));
		bg.color = 0x33ff00;
		bg.antialiasing = Main.save.data.antialiasing;
		add(bg);

		grpAchievements = new FlxTypedGroup<Alphabet>();
		add(grpAchievements);

		for (i in 0...Achievements.achievementsArray.length)
		{
			if (Achievements.achievementsArray[i].isHidden && savedAchievements.contains(Achievements.achievementsArray[i].saveId))
			{
				checkedAchievements.push(Achievements.achievementsArray[i].displayedName);
			}
			else if (!Achievements.achievementsArray[i].isHidden)
			{
				checkedAchievements.push(Achievements.achievementsArray[i].displayedName);
			}
		}

		for (i in 0...checkedAchievements.length)
		{
			var nameText:Alphabet = new Alphabet(0, (100 * i) + 200, checkedAchievements[i], true, false);
			nameText.isMenuItem = true;
			nameText.targetY = i;
			nameText.x += 280;
			nameText.xAdd = 200;
			grpAchievements.add(nameText);

			var icon:AchievementSprite = new AchievementSprite(nameText.x - 100, nameText.y - 50, Achievements.getImageByName(checkedAchievements[i]),
				Achievements.getSaveTagByName(checkedAchievements[i]));
			icon.sprTracker = nameText;

			iconArray.push(icon);
			add(icon);
		}

		var leText:String = checkedAchievements[0];
		var descBG:FlxSprite = new FlxSprite(0, 600).makeGraphic(FlxG.width, 600, 0xFF000000);
		descBG.alpha = 0.6;
		add(descBG);
		descText = new FlxText(100, 650, FlxG.width, leText, 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		descText.screenCenter(X);
		add(descText);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpAchievements.members.length - 1;
		if (curSelected >= grpAchievements.members.length)
			curSelected = 0;

		descText.text = Achievements.getDescByName(checkedAchievements[curSelected]);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpAchievements.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
