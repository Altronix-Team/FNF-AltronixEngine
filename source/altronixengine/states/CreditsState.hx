package altronixengine.states;

import altronixengine.gameplayStuff.Conductor;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;
import openfl.Assets;

typedef Credit =
{
	var nickname:String;
	var ?icon:String;
	var ?description:String;
	var ?url:String;
	var ?color:String;
}

typedef CreditsFile =
{
	var modName:String;
	var credits:Array<Credit>;
}

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var textborder:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		textborder = new FlxSprite().loadGraphic(Paths.image('textborder'));
		add(textborder);
		textborder.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		if (Assets.exists(Paths.json('data/credits')))
		{
			var file:CreditsFile = cast Paths.loadJSON('data/credits');
			creditsStuff.push([file.modName]);

			for (credit in file.credits)
			{
				creditsStuff.push([credit.nickname, credit.icon, credit.description, credit.url, credit.color]);
			}
			creditsStuff.push(['']);
		}

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			['Altronix Engine by'],
			[
				'AltronMaxX',
				'altronmaxx',
				'Programmer of Altronix Engine',
				'https://discord.com/users/324794944042565643',
				'00ff00'
			],
			[
				'Tut byl ya',
				'broken',
				'Tester of Altronix Engine',
				'https://twitter.com/tut_byl_ya',
				'676A75'
			],
			[''],
			['Kade Engine by'],
			[
				'KadeDeveloper',
				'kadedev',
				'Main Developer of Kade Engine',
				'https://twitter.com/kade0912',
				'4b6448'
			],
			[''],
			[''],
			["Funkin' Crew"],
			[
				'ninjamuffin99',
				'ninjamuffin99',
				"Programmer of Friday Night Funkin'",
				'https://twitter.com/ninja_muffin99',
				'F73838'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Animator of Friday Night Funkin'",
				'https://twitter.com/PhantomArcade3K',
				'FFBB1B'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Artist of Friday Night Funkin'",
				'https://twitter.com/evilsk8r',
				'53E52C'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Composer of Friday Night Funkin'",
				'https://twitter.com/kawaisprite',
				'6475F3'
			]
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !(creditsStuff[i].length <= 1);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if (isSelectable)
			{
				optionText.x -= 70;
			}
			grpOptions.add(optionText);

			if (isSelectable)
			{
				var icon:AttachedSprite;
				if (Assets.exists(Paths.image('crediticons/' + creditsStuff[i][1])))
					icon = new AttachedSprite('crediticons/' + creditsStuff[i][1]);
				else
					icon = new AttachedSprite('crediticons/noname');
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				if (curSelected == -1)
					curSelected = i;
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT)
		{
			FlxG.openURL(creditsStuff[curSelected][3]);
		}

		if (controls.BACK)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (creditsStuff[curSelected].length <= 1);

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!(creditsStuff[bullShit - 1].length <= 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	function getCurrentBGColor()
	{
		var bgColor:String = creditsStuff[curSelected][4];
		if (!bgColor.startsWith('0x'))
		{
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}
}
