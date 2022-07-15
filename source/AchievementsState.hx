package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import openfl.Lib;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;
import Achievements;
#if desktop
import DiscordClient;
#end

class AchievementsState extends MusicBeatState
{
    public static var achievementsArray:Array<Dynamic> = [ //Name, Description, save id, GJ id, hidden, image name
        ['First Play!', 'Start an Altronix Engine', 'first_start', 160503, false, 'engine'],
        ['Friday Night Funkin`', 'Complete the standart game without misses', 'vanila_game_completed', 167263, false, 'vanilaGame'],
        ['New opponents!', 'Download mod for Altronix Engine', 'download_mod', 167264, false, 'mods'],
        ['Lemon?', 'Start Monster song', 'monster_song', 167272, true, 'lemon'],
        ['HE CAN SHOOT!!!', 'Lose on week 3', 'week3_lose', 167273, true, 'dead'],
        ['Oh, it doesn`t hurt them?', 'Watch the Henchmen die over 100 times.', 'henchmen_dies', 167274, true, 'fuck_you'],
        ['Biginning of corruption mod', 'Die on Winter Horrorland', 'corruption', 167275, true, 'corruption'],
        ['Hooray, freedom', 'Lose on Thorns song', 'thorns_lose', 167276, true, 'dead-pixel'],
		['This is WAR!!!', 'Lose on Stress song', 'stress_lose', 167277, true, 'dead-withGf'],
        ['DadBattled', 'Complete week 1 on Hard or Hard Plus without misses', 'week1_nomiss', 167265, false, 'week1'],
        ['Spooky month!!', 'Complete week 2 on Hard or Hard Plus without misses', 'week2_nomiss', 167266, false, 'week2'],
        ['Go Pico yeah!', 'Complete week 3 on Hard or Hard Plus without misses', 'week3_nomiss', 167267, false, 'week3'],
        ['WoW, M.I.L.F!!', 'Complete week 4 on Hard or Hard Plus without misses', 'week4_nomiss', 167268, false, 'week4'],
        ['Did Santa survive?', 'Complete week 5 on Hard or Hard Plus without misses', 'week5_nomiss', 167269, false, 'week5'],
		['We need antivirus!','Complete week 6 on Hard or Hard Plus without misses', 'week6_nomiss', 167270, false, 'week6'],
        ['Ugh, Pretty Good', 'Complete week 7 on Hard or Hard Plus without misses', 'week7_nomiss', 167271, false, 'week7'],
        ['RAINBOW YEAAAAH!!!', 'Complete Blammed song for 50 times', 'blammed_completed', 167278, true, 'lammed'],
    ];

	public static function getWeekSaveId(weekid:Int):String
	{
		switch (weekid)
        {
            case 1:
				return 'week1_nomiss';
            case 2:
				return 'week2_nomiss';
            case 3:
				return 'week3_nomiss';
            case 4:
				return 'week4_nomiss';
            case 5:
				return 'week5_nomiss';
            case 6:
				return 'week6_nomiss';
            case 7:
				return 'week7_nomiss';
            default:
                return 'null';
        }
	}

    public static function findDescById(id:Int):String
    {
        for (i in achievementsArray)
        {
            if (i[3] == id)
                return i[1];
            else
                continue;
        }
        return 'Unidentified achievement';
    }

    public static function findNameById(id:Int):String
    {
        for (i in achievementsArray)
           {
            if (i[3] == id)
                 return i[0];
            else
                 continue;
        }
         return 'Unidentified achievement';
    }

	public static function findSaveIdById(id:Int):String
	{
		for (i in achievementsArray)
		{
			if (i[3] == id)
				return i[2];
			else
				continue;
		}
		return 'null';
	}

    public static function findImageById(id:Int):String
    {
        for (i in achievementsArray)
        {
            if (i[3] == id)
                return i[5];
            else
                continue;
        }
        return 'pattern';
    }

    public static function getSaveTagByName(name:String):String
    {
		for (i in achievementsArray)
		{
			if (i[0] == name)
				return i[2];
			else
				continue;
		}
        return 'null';
    }

	public static function getDescByName(name:String):String
	{
		for (i in achievementsArray)
		{
			if (i[0] == name)
				return i[1];
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	public static function getImageByName(name:String):String
	{
		for (i in achievementsArray)
		{
			if (i[0] == name)
				return i[5];
			else
				continue;
		}
		return 'Unidentified achievement';
	}

	var bg:FlxSprite;
	private var grpAchievements:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AchievementSprite> = [];
	var curSelected:Int = 0;
	var descText:FlxText;
    var checkedAchievements:Array<String> = [];

	override function create()
	{
		clean();

		var savedAchievements:Array<String> = FlxG.save.data.savedAchievements;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);

		#if desktop
		// Updating Discord Rich Presence
		if (!FlxG.save.data.language)
			DiscordClient.changePresence("In the Achievements Menu", null);
		else
			DiscordClient.changePresence("В меню достижений", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.loadImage('menuDesat'));
        bg.color = 0x33ff00;
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpAchievements = new FlxTypedGroup<Alphabet>();
		add(grpAchievements);

		for (i in 0...achievementsArray.length)
		{
			if (achievementsArray[i][4] && savedAchievements.contains(achievementsArray[i][2]))
			{
				checkedAchievements.push(achievementsArray[i][0]);
			}
			else if (!achievementsArray[i][4])
            {
				checkedAchievements.push(achievementsArray[i][0]);
            }
		}

		for (i in 0...checkedAchievements.length)
		{
			var nameText:Alphabet = new Alphabet(0, (100 * i) + 200, checkedAchievements[i], true, false, true);
            nameText.isMenuItem = true;
            nameText.targetY = i;
			nameText.x += 280;
            nameText.xAdd = 200;
            grpAchievements.add(nameText);

			var icon:AchievementSprite = new AchievementSprite(nameText.x - 100, nameText.y - 50, getImageByName(checkedAchievements[i]), getSaveTagByName(checkedAchievements[i]));
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

		descText.text = getDescByName(checkedAchievements[curSelected]);

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