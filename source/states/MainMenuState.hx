package states;

import flixel.addons.api.FlxGameJolt;
import flixel.FlxBasic;
import scriptStuff.HScriptHandler;
import flixel.input.gamepad.FlxGamepad;
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
import states.LoadingState.LoadingsState;
import GameJolt.GameJoltLogin;
import flixel.math.FlxMath;
import states.playState.PlayState;

class MainMenuState extends MusicBeatState
{
	private var camGame:SwagCamera;

	var camFollowPos:FlxObject;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MenuItem>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay',/* 'extras', */#if desktop 'mods',#end 'credits', 'awards', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var gameVer:String = "0.2.8";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var gjButton:CustomButton;

	public static var finishedFunnyMove:Bool = false;
	var dance:gameplayStuff.Character;

	override function create()
	{
		Achievements.getAchievement(160503, 'engine');
		camGame = new SwagCamera();
		clean();
		PlayState.inDaPlay = false;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		FlxG.cameras.reset(camGame);
		//FlxCamera.defaultCameras = [camGame];
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

		menuItems = new FlxTypedGroup<MenuItem>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:MenuItem = new MenuItem(0, FlxG.height * 1.6);
			menuItem.frames = Paths.getSparrowAtlas('mainmenuassets/${optionShit[i]}');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
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
						//changeItem();
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

		gjButton = new CustomButton(1100, 600, Paths.loadImage('mainmenuassets/GameJoltLogo'));
		gjButton.doOnClick = goToGJ;
		gjButton.scrollFactor.set();
		@:privateAccess
		if (FlxGameJolt.gameInit)
			add(gjButton);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		//dance.dance();
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new editors.MasterEditorMenu());
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

					menuItems.forEach(function(spr:MenuItem)
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

	function goToGJ() {
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		if (Main.save.data.flashing)
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		menuItems.forEach(function(spr:MenuItem)
		{
			if (Main.save.data.flashing)
			{
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new GameJoltLogin());
				});
			}
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new GameJoltLogin());
				});
			}
		});
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
				MusicBeatState.switchState(new OptionsDirect());
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
				//null
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
		menuItems.forEach(function(spr:MenuItem)
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

class MenuItem extends FlxSprite
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