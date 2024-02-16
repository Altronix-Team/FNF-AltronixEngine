package altronixengine.states;

import altronixengine.gameplayStuff.Ratings;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import altronixengine.options.Options;
import altronixengine.core.Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import altronixengine.gameplayStuff.PlayStateChangeables;
import altronixengine.states.playState.PlayState;
import altronixengine.states.playState.GameData as Data;

class OptionCata extends FlxSprite
{
	public var title:String;
	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<FlxText>;

	public var titleObject:FlxText;

	public var middle:Bool = false;

	public function new(x:Float, y:Float, _title:String, _options:Array<Option>, middleType:Bool = false)
	{
		super(x, y);
		title = _title;
		middle = middleType;
		if (!middleType)
			makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;

		options = _options;

		optionObjects = new FlxTypedGroup();

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
		titleObject.setFormat(Paths.font(LanguageStuff.fontName), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.borderSize = 3;

		if (middleType)
		{
			titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		}
		else
			titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);

		titleObject.scrollFactor.set();

		scrollFactor.set();

		for (i in 0...options.length)
		{
			var opt = options[i];
			var text:FlxText = new FlxText((middleType ? 1180 / 2 : 72), titleObject.y + 54 + (46 * i), 0, opt.getValue());
			if (middleType)
			{
				text.screenCenter(X);
			}
			text.setFormat(Paths.font(LanguageStuff.fontName), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();
			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor)
	{
		makeGraphic(295, 64, color);
	}
}

class OptionsMenu extends FlxSubState
{
	public static var instance:OptionsMenu;

	public var background:FlxSprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public static var visibleRange = [114, 640];

	public function new(pauseMenu:Bool = false)
	{
		super();

		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;

	override function create()
	{
		options = [
			new OptionCata(50, 40, LanguageStuff.getOptionDesc("$GAMEPLAY_CATA"), [
				new ScrollSpeedOption(LanguageStuff.getOptionDesc("$SCROLLSPEED_OPTION")),
				new OffsetThing(LanguageStuff.getOptionDesc("$OFFSET_OPTION")),
				new AccuracyDOption(LanguageStuff.getOptionDesc("$ACCURACYD_OPTION")),
				new GhostTapOption(LanguageStuff.getOptionDesc("$GHOSTTAP_OPTION")),
				new DownscrollOption(LanguageStuff.getOptionDesc("$DOWNSCROLL_OPTION")),
				new BotPlay(LanguageStuff.getOptionDesc("$BOTPLAY_OPTION")),
				#if desktop
				new FPSCapOption(LanguageStuff.getOptionDesc("$FPSCAP_OPTION")),
				#end
				new ResetButtonOption(LanguageStuff.getOptionDesc("$RESETBUTTON_OPTION")),
				new InstantRespawn(LanguageStuff.getOptionDesc("$INSTANTRESPAWN_OPTION")),
				new CamZoomOption(LanguageStuff.getOptionDesc("$CAMZOOM_OPTION")),
				new NoteSplashOption(LanguageStuff.getOptionDesc("$NOTESPLASH_OPTION")),
				new DFJKOption(),
				new Judgement(LanguageStuff.getOptionDesc("$JUDGEMENT")),
				new CustomizeGameplay(LanguageStuff.getOptionDesc("$CUSTOMIZE_GAMEPLAY"))
			]),
			new OptionCata(345, 40, LanguageStuff.getOptionDesc("$APPEARANCE_CATA"), [
				new NoteskinOption(LanguageStuff.getOptionDesc("$NOTESKIN_OPTION")),
				new EditorRes(LanguageStuff.getOptionDesc("$EDITORBG_OPTION")),
				new DistractionsAndEffectsOption(LanguageStuff.getOptionDesc("$DISTANDEFF_OPTION")),
				new MiddleScrollOption(LanguageStuff.getOptionDesc("$MIDDLESCROLL_OPTION")),
				new HealthBarOption(LanguageStuff.getOptionDesc("$HEALTHBAR_OPTION")),
				new JudgementCounter(LanguageStuff.getOptionDesc("$JUDGEMENTCOUNTER_OPTION")),
				new LaneUnderlayOption(LanguageStuff.getOptionDesc("$LANEUNDERLAY_OPTION")),
				new AccuracyOption(LanguageStuff.getOptionDesc("$ACCURACY_OPTION")),
				new SongPositionOption(LanguageStuff.getOptionDesc("$SONGPOS_OPTION")),
				new Colour(LanguageStuff.getOptionDesc("$COLOUR_OPTION")),
				new RainbowFPSOption(LanguageStuff.getOptionDesc("$RAINBOWFPS_OPTION")),
			]),
			new OptionCata(640, 40, LanguageStuff.getOptionDesc("$MISC_CATA"), [
				new MenuMusicOption(LanguageStuff.getOptionDesc("$MENUMUSIC_OPTION")),
				new FPSOption(LanguageStuff.getOptionDesc("$FPS_OPTION")),
				new FlashingLightsOption(LanguageStuff.getOptionDesc("$FLASHLIGHTS_OPTION")),
				new WatermarkOption(LanguageStuff.getOptionDesc("$WATERMARK_OPTION")),
				new AntialiasingOption(LanguageStuff.getOptionDesc("$ANTIALIASING_OPTION")),
				new MissSoundsOption(LanguageStuff.getOptionDesc("$MISSSOUNDS_OPTION")),
				new ScoreScreen(LanguageStuff.getOptionDesc("$SCORESCREEEN_OPTION")),
				new ShowInput(LanguageStuff.getOptionDesc("$SHOWINPUT_OPTION")),
				new LanguageOption(LanguageStuff.getOptionDesc("$LANGUAGE_OPTION")),
				new MemoryCountOption(LanguageStuff.getOptionDesc("$MEMORYCOUNT_OPTION")),
				new FullscreenOnStartOption(LanguageStuff.getOptionDesc("$FULLSCREENONSTART_OPTION")),
				// new ScreenResolutionOption("Fullscreen test")
			]),
			new OptionCata(935, 40, LanguageStuff.getOptionDesc("$SAVES_CATA"), [
				new ResetScoreOption(LanguageStuff.getOptionDesc("$RESETSCORE_OPTION")),
				new LockWeeksOption(LanguageStuff.getOptionDesc("$LOCKWEEKS_OPTION")),
				new ResetSettings(LanguageStuff.getOptionDesc("$RESETSETTINGS"))
			]),
			new OptionCata(-1, 125, LanguageStuff.getOptionDesc("$KEYBINDS_CATA"), [
				new LeftKeybind(LanguageStuff.getOptionDesc("$LEFTKEYBIND")),
				new DownKeybind(LanguageStuff.getOptionDesc("$DOWNKEYBIND")),
				new UpKeybind(LanguageStuff.getOptionDesc("$UPKEYBIND")),
				new RightKeybind(LanguageStuff.getOptionDesc("$RIGHTKEYBIND")),
				new PauseKeybind(LanguageStuff.getOptionDesc("$PAUSEKEYBIND")),
				new ResetBind(LanguageStuff.getOptionDesc("$RESETKEYBIND")),
				new MuteBind(LanguageStuff.getOptionDesc("$MUTEKEYBIND")),
				new VolUpBind(LanguageStuff.getOptionDesc("$VOLUPKEYBIND")),
				new VolDownBind(LanguageStuff.getOptionDesc("$VOLDOWNKEYBIND")),
				new AttackKeybind(LanguageStuff.getOptionDesc("$ATTACKKEYBIND")),
				new LeftP2Keybind(LanguageStuff.getOptionDesc("$LEFTKEYBIND")),
				new DownP2Keybind(LanguageStuff.getOptionDesc("$DOWNKEYBIND")),
				new UpP2Keybind(LanguageStuff.getOptionDesc("$UPKEYBIND")),
				new RightP2Keybind(LanguageStuff.getOptionDesc("$RIGHTKEYBIND"))
			], true),
			new OptionCata(-1, 125, LanguageStuff.getOptionDesc("$JUDGEMENTS_CATA"), [
				new SickMSOption(LanguageStuff.getOptionDesc("$SICKMS_OPTION")),
				new GoodMsOption(LanguageStuff.getOptionDesc("$GOODMS_OPTION")),
				new BadMsOption(LanguageStuff.getOptionDesc("$BASMS_OPTION")),
				new ShitMsOption(LanguageStuff.getOptionDesc("$SHITMS_OPTION"))
			], true)
		];

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();

		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		descBack = new FlxSprite(50, 640).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		FlxG.mouse.visible = true;

		if (isInPause)
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			menu.add(bg);

			background.alpha = 0.5;
			bg.alpha = 0.6;

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		selectedCat = options[0];

		selectedOption = selectedCat.options[0];

		add(menu);

		add(shownStuff);

		for (i in 0...options.length - 1)
		{
			if (i >= 4)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject);
		}

		descText = new FlxText(62, 648);
		descText.setFormat(Paths.font(LanguageStuff.fontName), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		descText.borderSize = 2;

		add(descBack);
		add(descText);

		isInCat = true;

		switchCat(selectedCat);

		selectedOption = selectedCat.options[0];

		super.create();
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try
		{
			visibleRange = [114, 640];
			if (cat.middle)
				visibleRange = [Std.int(cat.titleObject.y), 640];
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - 3 && checkForOutOfBounds)
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.titleObject.y + 54 + (46 * i);
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			for (i in selectedCat.optionObjects)
				shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
			}

			selectedOptionIndex = 0;

			if (!isInCat)
				selectOption(selectedOption);

			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
		catch (e)
		{
			Debug.logError("oops\n" + e);
			selectedCatIndex = 0;
		}

		Debug.logTrace("Changed cat: " + selectedCatIndex);
	}

	public function selectOption(option:Option)
	{
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInCat)
		{
			object.text = "> " + option.getValue();

			descText.text = option.getDescription();
		}
		Debug.logTrace("Changed opt: " + selectedOptionIndex);

		Debug.logTrace("Bounds: " + visibleRange[0] + "," + visibleRange[1]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var accept = false;
		var right = false;
		var left = false;
		var up = false;
		var down = false;
		var any = false;
		var escape = false;

		accept = FlxG.keys.justPressed.ENTER || (gamepad != null ? gamepad.justPressed.A : false);
		right = FlxG.keys.justPressed.RIGHT || (gamepad != null ? gamepad.justPressed.DPAD_RIGHT : false);
		left = FlxG.keys.justPressed.LEFT || (gamepad != null ? gamepad.justPressed.DPAD_LEFT : false);
		up = FlxG.keys.justPressed.UP || (gamepad != null ? gamepad.justPressed.DPAD_UP : false);
		down = FlxG.keys.justPressed.DOWN || (gamepad != null ? gamepad.justPressed.DPAD_DOWN : false);

		any = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		escape = FlxG.keys.justPressed.ESCAPE || (gamepad != null ? gamepad.justPressed.B : false);

		for (cata in options)
		{
			if (FlxG.mouse.overlaps(cata))
			{
				if (FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex = options.indexOf(cata);

					switchCat(cata);
				}
			}
		}

		if (selectedCat != null && !isInCat)
		{
			for (i in selectedCat.optionObjects.members)
			{
				if (selectedCat.middle)
				{
					i.screenCenter(X);
				}

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}

		try
		{
			if (isInCat)
			{
				descText.text = LanguageStuff.getOptionDesc("$SELECTCAT");
				if (right)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex++;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[0]);
				}

				if (escape)
				{
					FlxG.mouse.visible = false;
					if (!isInPause)
						FlxG.switchState(new MainMenuState());
					else
					{
						PauseSubState.goBack = true;
						PlayStateChangeables.scrollSpeed = Main.save.data.scrollSpeed * Data.songMultiplier;
						close();
					}
				}
			}
			else
			{
				if (selectedOption != null)
					if (selectedOption.acceptType)
					{
						if (escape && selectedOption.waitingType)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
							return;
						}
						else if (any)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
						}
					}
				if (selectedOption.acceptType || !selectedOption.acceptType)
				{
					if (accept)
					{
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();

						if (selectedOptionIndex == prev)
						{
							Main.save.flush();

							object.text = "> " + selectedOption.getValue();
						}
					}

					if (down)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex++;

						// just kinda ignore this math lol

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= 46;
								}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}
					else if (up)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						// just kinda ignore this math lol

						if (selectedOptionIndex < 0)
						{
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2));
								}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y += 46;
								}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}

					if (right)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();

						Main.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
						if (selectedOptionIndex == 8 && selectedCatIndex == 2)
						{
							var lang = Main.save.data.localeStr;
							LanguageStuff.loadLanguage(lang);
							FlxG.resetState();
						}
					}
					else if (left)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();

						Main.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
						if (selectedOptionIndex == 8 && selectedCatIndex == 2)
						{
							var lang = Main.save.data.localeStr;
							LanguageStuff.loadLanguage(lang);
							FlxG.resetState();
						}
					}

					if (escape)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));

						if (selectedCatIndex >= 4)
							selectedCatIndex = 0;

						PlayerSettings.player1.controls.loadKeyBinds();

						Ratings.timingWindows = [
							Main.save.data.shitMs,
							Main.save.data.badMs,
							Main.save.data.goodMs,
							Main.save.data.sickMs
						];

						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.titleObject.y + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						isInCat = true;
						if (selectedCat.optionObjects != null)
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
							}
						if (selectedCat.middle)
							switchCat(options[0]);
					}
				}
			}
		}
		catch (e)
		{
			Debug.logError("wtf we actually did something wrong, but we dont crash bois.\n" + e);
			selectedCatIndex = 0;
			selectedOptionIndex = 0;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (selectedCat != null)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				isInCat = true;
			}
		}
	}
}
