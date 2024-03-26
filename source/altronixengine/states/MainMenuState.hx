package altronixengine.states;

import flash.text.TextField;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import altronixengine.scriptStuff.HScriptHandler;
import altronixengine.states.LoadingState.LoadingsState;
import altronixengine.states.playState.GameData;
import altronixengine.states.playState.PlayState;
import altronixengine.data.EngineConstants;

class MainMenuState extends MusicBeatState
{
	private var camGame:FlxCamera;

	var camFollowPos:FlxObject;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MainMenuItem>;

	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		#if FEATURE_MODCORE 'mods', #end
		'credits',
		'awards',
		'options'
	];

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var gameVer:String = EngineConstants.funkinVer;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		Achievements.getAchievement('first_start', 'engine');
		camGame = new FlxCamera();
		clean();
		GameData.inDaPlay = false;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		FlxG.cameras.reset(camGame);
		// FlxCamera.defaultCameras = [camGame];
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.mouse.visible = true;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
		}

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.5));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = Main.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.loadImage('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.5));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = Main.save.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<MainMenuItem>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:MainMenuItem = new MainMenuItem(0, FlxG.height * 1.6);
			menuItem.frames = Paths.getSparrowAtlas('mainmenuassets/${optionShit[i]}');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			// menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = optionShit.length * 0.125;
			if (optionShit.length < 3)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = Main.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						menuItem.defaultY = 60 + (i * 160);
						if (i == optionShit.length - 1)
							finishedFunnyMove = true;
						// changeItem();
					}
				});
			else
			{
				menuItem.y = 60 + (i * 160);
				menuItem.defaultY = 60 + (i * 160);
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		firstStart = false;

		var altronix:FlxText;
		var gamever:FlxText;

		altronix = new FlxText(5, FlxG.height - 36, 0, 'Altronix Engine ' + EngineConstants.engineVer, 12);
		altronix.scrollFactor.set();
		altronix.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(altronix);

		gamever = new FlxText(5, FlxG.height - 18, 0, LanguageStuff.replaceFlagsAndReturn("$VERSION", 'data', ["<version>"], [gameVer]), 12);
		gamever.scrollFactor.set();
		gamever.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(gamever);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		// dance.dance();
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new altronixengine.states.editors.MasterEditorMenu());
			clean();
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP && finishedFunnyMove)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN && finishedFunnyMove)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP && finishedFunnyMove)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN && finishedFunnyMove)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (Main.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:MainMenuItem)
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
							if (Main.save.data.flashing)
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
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.mouse.visible = false;

			case 'freeplay':
				MusicBeatState.switchState(new FreeplayState());
				FlxG.mouse.visible = false;

			case 'options':
				MusicBeatState.switchState(new altronixengine.options.OptionsDirect());
				FlxG.mouse.visible = false;

			case 'awards':
				MusicBeatState.switchState(new AchievementsState());
				FlxG.mouse.visible = false;

			#if FEATURE_MODCORE
			case 'mods':
				MusicBeatState.switchState(new ModMenuState());
			#end

			case 'credits':
				MusicBeatState.switchState(new CreditsState());
				FlxG.mouse.visible = false;

			default:
				// null
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
		menuItems.forEach(function(spr:MainMenuItem)
		{
			spr.animation.play('idle');

			if (finishedFunnyMove)
			{
				if (spr.sprTween != null)
					spr.sprTween.cancel();

				if (spr.x != spr.defaultX)
					spr.x = spr.defaultX;

				if (spr.y != spr.defaultY)
					spr.y = spr.defaultY;
			}

			if (spr.ID == curSelected)
			{
				if (finishedFunnyMove)
				{
					spr.sprTween = FlxTween.tween(spr, {x: spr.x + spr.width / 4}, 0.3);
				}

				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			if (spr.animation.curAnim != null)
				spr.animation.curAnim.frameRate = 24 * (60 / Main.save.data.fpsCap);

			spr.updateHitbox();
		});
	}
}

class MainMenuItem extends FlxSprite
{
	public var defaultX:Float = 0;
	public var defaultY:Float = 0;

	public var sprTween:FlxTween;

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		defaultX = x;
		defaultY = y;

		super(x, y);
	}
}
