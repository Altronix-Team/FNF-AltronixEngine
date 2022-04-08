package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import flixel.FlxCamera;
import lime.app.Application;
import flash.text.TextField;
import flixel.addons.ui.FlxInputText;
import LoadingState.LoadingsState;
#if desktop
import Discord.DiscordClient;
#end
import flixel.math.FlxMath;

using StringTools;

class MainMenuState extends MusicBeatState
{
	private var camGame:FlxCamera;
	var enterText:FlxText;
	var hintText:FlxText;
	var passwordText:FlxInputText;

	var camFollowPos:FlxObject;

	public static var canMove:Bool = true;

	var extras:FlxSprite;
	var blackScreen:FlxSprite;

	public static var inMain:Bool = true;

	public static var extra:Int = 1;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'extras', 'credits', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.8" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;
	var dance:Character;

	override function create()
	{
		FlxG.mouse.visible = true;
		camGame = new FlxCamera();
		inMain = true;
		canMove = true;
		trace(0 / 2);
		clean();
		PlayState.inDaPlay = false;
		#if desktop
		// Updating Discord Rich Presence
		if (!FlxG.save.data.language)
			DiscordClient.changePresence("In the Menus", null);
		else
			DiscordClient.changePresence("В главном меню", null);
		#end
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = FlxG.save.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		var random = new FlxRandom();
		var charlist:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/characterList'));
		var rand = random.int(0, charlist.length);

		dance = new Character(0, 0, charlist[rand]);
		dance.screenCenter(XY);
		dance.x = FlxG.width - (dance.width + 100);
		dance.y = FlxG.height - dance.height;
		dance.scrollFactor.set();
		dance.dance();
		add(dance);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		blackScreen = new FlxSprite(-200, -100).makeGraphic(Std.int(FlxG.width * 0.5), Std.int(FlxG.height * 0.5), FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.scrollFactor.set(0, 0);
		blackScreen.visible = false;
		add(blackScreen);

		enterText = new FlxText(0, 0, 0, "Enter Password:", 48);
		enterText.setFormat('Pixel Arial 11 Bold', 48, FlxColor.WHITE, CENTER);
		enterText.screenCenter();
		enterText.y -= 40;
		enterText.scrollFactor.set(0, 0);
		enterText.visible = false;
		add(enterText);

		hintText = new FlxText(0, 0, 0, "You can find it in game files", 24);
		hintText.setFormat('Pixel Arial 11 Bold', 24, FlxColor.WHITE, CENTER);
		hintText.screenCenter();
		hintText.y = enterText.y + 80;
		hintText.scrollFactor.set(0, 0);
		hintText.visible = false;
		add(hintText);

		passwordText = new FlxInputText(0, 300, 550, '', 36, FlxColor.WHITE, FlxColor.BLACK);
		passwordText.fieldBorderColor = FlxColor.WHITE;
		passwordText.fieldBorderThickness = 3;
		passwordText.maxLength = 20;
		passwordText.screenCenter(X);
		passwordText.y += 120;
		passwordText.scrollFactor.set(0, 0);
		passwordText.visible = false;
		add(passwordText);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = optionShit.length * 0.125;
			if (optionShit.length < 3)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				menuItem.y = 60 + (i * 160);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		firstStart = false;

		//FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));
		var versionShit:FlxText;
		var altronix:FlxText;
		var gamever:FlxText;
		if (!FlxG.save.data.language)
			versionShit = new FlxText(5, FlxG.height - 36, 0, 'Using modified version of Kade Engine ' + kadeEngineVer, 12);
		else
			versionShit = new FlxText(5, FlxG.height - 36, 0, 'Использует модифицированную версию Kade Engine ' + kadeEngineVer, 12);
		versionShit.scrollFactor.set();
		if (!FlxG.save.data.language)
			versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			versionShit.setFormat("Comic Sans MS", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		altronix = new FlxText(5, FlxG.height - 54, 0, 'Altronix Engine', 12);
		altronix.scrollFactor.set();
		if (!FlxG.save.data.language)
			altronix.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			altronix.setFormat("Comic Sans MS", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(altronix);

		if (!FlxG.save.data.language)
			gamever = new FlxText(5, FlxG.height - 18, 0, 'Game version ' + gameVer, 12);
		else
			gamever = new FlxText(5, FlxG.height - 18, 0, 'Версия игры ' + gameVer, 12);
		gamever.scrollFactor.set();
		if (!FlxG.save.data.language)
			gamever.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		else
			gamever.setFormat("Comic Sans MS", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(gamever);

		// NG.core.calls.event.logEvent('swag').send();

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	function checkpassword(?passwordText:String)
		{
			if (passwordText == 'fun')
			{
				extra = 1;
				FlxG.sound.music.stop();
				goToState();
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
				Main.isHidden = true;
				waitforpass = false;
			}
			else if (passwordText == 'tankman')
			{
				extra = 2;
				FlxG.sound.music.stop();
				goToState();
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
				Main.isHidden = true;
				waitforpass = false;
			}
			else if (passwordText == 'debug')
			{
				extra = 3;
				FlxG.sound.music.stop();
				goToState();
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
				Main.isHidden = true;
				waitforpass = false;
			}
			else if ((passwordText != 'fun' || passwordText != 'tankman' || passwordText != 'debug')&& !inMain)
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'));
			}
		}

	var waitforpass = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug());
			clean();
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			dance.dance();

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK && inMain)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else if (optionShit[curSelected] == 'extras')
				{
					blackScreen.visible = true;
					enterText.visible = true;
					hintText.visible = true;
					passwordText.visible = true;
					canMove = false;
					inMain = false;

					if (controls.BACK && !inMain)
					{
						blackScreen.visible = false;
						enterText.visible = false;
						passwordText.visible = false;
						hintText.visible = false;
						passwordText.text = '';
						inMain = true;
						canMove = true;
						waitforpass = false;
					}
					waitforpass = true;

					if (controls.ACCEPT && waitforpass)
						checkpassword(passwordText.text);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{									
									goToState();
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.x = 0;
			spr.scrollFactor.x = 0;
			//spr.scrollFactor.y = 0;
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				openSubState(new LoadingsState());
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
				FlxG.mouse.visible = false;
				
			case 'freeplay':
				openSubState(new LoadingsState());
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");
				FlxG.mouse.visible = false;

			case 'options':
				openSubState(new LoadingsState());
				FlxG.switchState(new OptionsDirect());
				FlxG.mouse.visible = false;
			case 'extras':
				FlxG.switchState(new SecretState());
				trace('extras menu selected');
				FlxG.mouse.visible = false;

			case 'credits':
				FlxG.switchState(new CreditsState());
				FlxG.mouse.visible = false;
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.animation.curAnim.frameRate = 24 * (60 / FlxG.save.data.fpsCap);

			spr.updateHitbox();
		});
	}
}