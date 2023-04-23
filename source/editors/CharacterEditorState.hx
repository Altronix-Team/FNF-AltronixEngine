package editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import gameplayStuff.Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import core.FlxUIDropDownMenuCustom;
import flixel.addons.ui.FlxUIText;
import gameplayStuff.StageData;
import states.MusicBeatState;
import gameplayStuff.Stage;
import gameplayStuff.HealthIcon;
#if FEATURE_MODCORE
import sys.FileSystem;
#end

class CharacterEditorState extends MusicBeatState
{
	var Stage:Stage;
	var char:Character;
	var ghostChar:Character;
	var textAnim:FlxText;
	var bgLayer:FlxTypedGroup<FlxSprite>;
	var charLayer:FlxTypedGroup<Character>;
	var dumbTexts:FlxTypedGroup<FlxText>;
	// var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'spooky';
	var daStage:String = 'stage';
	var goToPlayState:Bool = false;
	var camFollow:FlxObject;

	public function new(daAnim:String = 'spooky', goToPlayState:Bool = false)
	{
		super();
		this.daAnim = daAnim;
		this.goToPlayState = goToPlayState;
	}

	var UI_box:FlxUITabMenu;
	var UI_characterbox:FlxUITabMenu;
	var UI_stages:FlxUITabMenu;

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

	var leHealthIcon:HealthIcon;
	var characterList:Array<String> = [];

	var charFolder:String = 'bf';

	var cameraFollowPointer:FlxSprite;
	var healthBarBG:FlxSprite;

	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	override function create()
	{
		// FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camMenu, false);
		// FlxCamera.defaultCameras = [camEditor];
		FlxG.cameras.setDefaultDrawTarget(camEditor, true);

		bgLayer = new FlxTypedGroup<FlxSprite>();
		add(bgLayer);
		charLayer = new FlxTypedGroup<Character>();
		add(charLayer);

		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraFollowPointer = new FlxSprite().loadGraphic(pointer);
		cameraFollowPointer.setGraphicSize(40, 40);
		cameraFollowPointer.updateHitbox();
		cameraFollowPointer.color = FlxColor.WHITE;
		add(cameraFollowPointer);

		loadChar(!daAnim.startsWith('bf') || !daAnim.endsWith('bf'), false);

		healthBarBG = new FlxSprite(30, FlxG.height - 75).loadGraphic(Paths.image('healthBar'));
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBarBG.cameras = [camHUD];

		leHealthIcon = new HealthIcon('', 'face', false);
		leHealthIcon.y = FlxG.height - 150;
		add(leHealthIcon);
		leHealthIcon.cameras = [camHUD];

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);
		dumbTexts.cameras = [camHUD];

		textAnim = new FlxText(300, 16);
		textAnim.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.borderSize = 1;
		textAnim.size = 32;
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0, "SCROLLMOUSE - Camera Zoom In/Out
			\nRMOUSE - Move Camera
			\nW/S - Previous/Next Animation
			\nSpace - Play Animation
			\nArrow Keys - Move Character Offset
			\nR - Reset Current Offset
			\nHold Shift to Move 10x faster\n", 12);
		tipText.cameras = [camHUD];
		tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.x -= tipText.width;
		tipText.y -= tipText.height - 10;
		add(tipText);

		FlxG.camera.follow(camFollow);

		var tabs = [
			// {name: 'Offsets', label: 'Offsets'},
			{name: 'Settings', label: 'Settings'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];

		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		var stageTabs = [{name: 'Stages', label: 'Stages'},];

		UI_stages = new FlxUITabMenu(null, stageTabs, true);
		UI_stages.cameras = [camHUD];

		UI_stages.resize(100, 120);
		UI_stages.x = FlxG.width - 375;
		UI_stages.y = 25;
		UI_stages.scrollFactor.set();

		var tabs = [
			{name: 'Character', label: 'Character'},
			{name: 'Animations', label: 'Animations'},
		];
		UI_characterbox = new FlxUITabMenu(null, tabs, true);
		UI_characterbox.cameras = [camHUD];

		UI_characterbox.resize(350, 250);
		UI_characterbox.x = UI_box.x - 100;
		UI_characterbox.y = UI_box.y + UI_box.height;
		UI_characterbox.scrollFactor.set();
		add(UI_characterbox);
		add(UI_box);
		add(UI_stages);

		addStagesUI();
		addSettingsUI();

		addCharacterUI();
		addAnimationsUI();
		UI_characterbox.selected_tab_id = 'Character';

		FlxG.mouse.visible = true;
		reloadCharacterOptions();

		super.create();
	}

	var stageDropDown:FlxUIDropDownMenuCustom;

	function addStagesUI()
	{
		var tab_group = new FlxUI(null, UI_stages);
		tab_group.name = "Stages";

		stageDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String)
		{
			daStage = stageDropDown.selectedLabel;
			reloadBGs();
		}, new FlxUIDropDownHeader(85, null, new FlxUIText(10, 12, 0, 'Stage: ')));
		stageDropDown.selectedLabel = daStage;
		blockPressWhileScrolling.push(stageDropDown);
		reloadStagesDropDown();

		tab_group.add(new FlxText(stageDropDown.x, stageDropDown.y - 18, 0, 'Stage:'));
		tab_group.add(stageDropDown);
		UI_stages.addGroup(tab_group);
	}

	function reloadStagesDropDown()
	{
		var stageList = EngineConstants.defaultStages;

		stageDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(stageList, true));
		stageDropDown.selectedLabel = daStage;
	}

	var char_X:Float = 100;
	var char_Y:Float = 100;

	var loadedStageOnce:Bool = false;
	var onPixelBG:Bool = false;
	var OFFSET_X:Float = 300;

	function reloadBGs()
	{
		if (loadedStageOnce)
		{
			remove(cameraFollowPointer);
			remove(charLayer);
			for (bg in Stage.toAdd)
			{
				remove(bg);
			}

			for (fuck in Stage.layInFront)
				for (shit in fuck)
					remove(shit);

			for (group in Stage.swagGroup)
			{
				remove(group);
			}

			Stage = new Stage(daStage);
			var stageData:StageFile = Stage.stageData;
			for (char in charLayer)
			{
				if (check_player.checked)
				{
					char.setPosition(stageData.boyfriend[0], stageData.boyfriend[1]);
					char_X = stageData.boyfriend[0];
					char_Y = stageData.boyfriend[1];
				}
				else
				{
					char.setPosition(stageData.dad[0], stageData.dad[1]);
					char_X = stageData.dad[0];
					char_Y = stageData.dad[1];
				}

				char.x += char.positionArray[0];
				char.y += char.positionArray[1];
			}
			for (i in Stage.toAdd)
			{
				add(i);
			}
			for (group in Stage.swagGroup)
			{
				add(group);
			}
			add(charLayer);
			for (array in Stage.layInFront)
			{
				for (bg in array)
					add(bg);
			}
			add(cameraFollowPointer);
		}
		else
		{
			remove(cameraFollowPointer);
			remove(charLayer);
			Stage = new Stage(daStage);

			for (i in Stage.toAdd)
			{
				add(i);
			}
			for (group in Stage.swagGroup)
			{
				add(group);
			}
			loadedStageOnce = true;
			var stageData:StageFile = Stage.stageData;
			for (char in charLayer)
			{
				char.setPosition(stageData.boyfriend[0], stageData.boyfriend[1]);
				char_X = stageData.boyfriend[0];
				char_Y = stageData.boyfriend[1];
				char.x += char.positionArray[0];
				char.y += char.positionArray[1];
			}
			add(charLayer);
			for (array in Stage.layInFront)
			{
				for (bg in array)
					add(bg);
			}
			add(cameraFollowPointer);
		}
	}

	var charDropDown:FlxUIDropDownMenuCustom;
	var check_player:FlxUICheckBox;

	function addSettingsUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Settings";

		check_player = new FlxUICheckBox(10, 60, null, null, "Playable Character", 100);
		check_player.checked = (daAnim.startsWith('bf') || daAnim.endsWith('bf') || daAnim.endsWith('-player'));
		check_player.callback = function()
		{
			char.isPlayer = !char.isPlayer;
			char.flipX = !char.flipX;
			updatePointerPos();
			ghostChar.flipX = char.flipX;
			if (check_player.checked)
			{
				var stageData:StageFile = Stage.stageData;
				for (char in charLayer)
				{
					char.setPosition(stageData.boyfriend[0], stageData.boyfriend[1]);

					char.x += char.positionArray[0];
					char.y += char.positionArray[1];
				}
			}
			else
			{
				var stageData:StageFile = Stage.stageData;
				for (char in charLayer)
				{
					char.setPosition(stageData.dad[0], stageData.dad[1]);

					char.x += char.positionArray[0];
					char.y += char.positionArray[1];
				}
			}
		};

		charDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String)
		{
			daAnim = characterList[Std.parseInt(character)];
			check_player.checked = (daAnim.startsWith('bf') || daAnim.endsWith('bf') || daAnim.endsWith('-player'));
			loadChar(!check_player.checked);
			if (char.psychChar)
			{
				Debug.logWarn('Character editor not supports Psych Engine characters');
				charDropDown.selectedLabel = 'bf';
				daAnim = 'bf';
				loadChar(false);
			}
			charFolder = daAnim;
			updatePresence();
			reloadCharacterDropDown();
			reloadBGs();
		});
		charDropDown.selectedLabel = daAnim;
		blockPressWhileScrolling.push(charDropDown);
		reloadCharacterDropDown();

		var reloadCharacter:FlxButton = new FlxButton(140, 20, "Reload Char", function()
		{
			loadChar(!check_player.checked);
			reloadCharacterDropDown();
		});

		var templateCharacter:FlxButton = new FlxButton(140, 50, "Load Template", function()
		{
			var parsedJson:CharacterData = EmptyCharacters.createEmptyCharacter();
			var characters:Array<Character> = [char, ghostChar];
			for (character in characters)
			{
				character.animOffsets.clear();
				character.animationsArray = parsedJson.animations;
				for (anim in character.animationsArray)
				{
					character.addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
				}
				if (character.animationsArray[0] != null)
				{
					character.playAnim(character.animationsArray[0].name, true);
				}

				character.holdLength = parsedJson.holdLength;
				character.positionArray = parsedJson.charPos;
				character.camPos = parsedJson.camPos;

				character.asset = parsedJson.asset;
				character.jsonScale = parsedJson.scale;
				character.charAntialiasing = parsedJson.antialiasing;
				character.originalFlipX = parsedJson.flipX;
				character.characterIcon = parsedJson.characterIcon;
				character.healthColorArray = parsedJson.barColorJson;
				character.setPosition(character.positionArray[0] + OFFSET_X + 100, character.positionArray[1]);
			}

			reloadCharacterImage();
			reloadCharacterDropDown();
			reloadCharacterOptions();
			resetHealthBarColor();
			updatePointerPos();
			genBoyOffsets();
		});
		templateCharacter.color = FlxColor.RED;
		templateCharacter.label.color = FlxColor.WHITE;

		tab_group.add(new FlxText(charDropDown.x, charDropDown.y - 18, 0, 'Character:'));
		tab_group.add(check_player);
		tab_group.add(reloadCharacter);
		tab_group.add(charDropDown);
		tab_group.add(reloadCharacter);
		tab_group.add(templateCharacter);
		UI_box.addGroup(tab_group);
	}

	var imageInputText:FlxUIInputText;
	var folderInputText:FlxUIInputText;
	var startingAnimInputText:FlxUIInputText;
	var healthIconInputText:FlxUIInputText;

	var singDurationStepper:FlxUINumericStepper;
	var scaleStepper:FlxUINumericStepper;
	var positionXStepper:FlxUINumericStepper;
	var positionYStepper:FlxUINumericStepper;
	var positionCameraXStepper:FlxUINumericStepper;
	var positionCameraYStepper:FlxUINumericStepper;

	var replacesGFCheckBox:FlxUICheckBox;
	var flipXCheckBox:FlxUICheckBox;
	var noAntialiasingCheckBox:FlxUICheckBox;
	var hasTrailCheckBox:FlxUICheckBox;

	var healthColorStepperR:FlxUINumericStepper;
	var healthColorStepperG:FlxUINumericStepper;
	var healthColorStepperB:FlxUINumericStepper;

	function addCharacterUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Character";

		imageInputText = new FlxUIInputText(130, 30, 100, 'BOYFRIEND', 8);
		folderInputText = new FlxUIInputText(15, 30, 100, 'bf', 8);
		var reloadImage:FlxButton = new FlxButton(imageInputText.x + 110, imageInputText.y - 3, "Reload Image", function()
		{
			char.asset = imageInputText.text;
			reloadCharacterImage();
			if (char.animation.curAnim != null)
			{
				char.playAnim(char.animation.curAnim.name, true);
			}
		});

		var decideIconColor:FlxButton = new FlxButton(reloadImage.x, reloadImage.y + 30, "Get Icon Color", function()
		{
			var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(leHealthIcon));
			healthColorStepperR.value = coolColor.red;
			healthColorStepperG.value = coolColor.green;
			healthColorStepperB.value = coolColor.blue;
			getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperR, null);
			getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperG, null);
			getEvent(FlxUINumericStepper.CHANGE_EVENT, healthColorStepperB, null);
		});

		healthIconInputText = new FlxUIInputText(15, imageInputText.y + 35, 75, char.characterIcon, 8);

		startingAnimInputText = new FlxUIInputText(120, imageInputText.y + 35, 75, daAnim, 8);

		singDurationStepper = new FlxUINumericStepper(15, startingAnimInputText.y + 45, 0.1, 4, 0, 999, 1);

		scaleStepper = new FlxUINumericStepper(15, singDurationStepper.y + 40, 0.1, 1, 0.05, 10, 1);

		flipXCheckBox = new FlxUICheckBox(singDurationStepper.x + 80, singDurationStepper.y, null, null, "Flip X", 50);
		flipXCheckBox.checked = char.flipX;
		if (char.isPlayer)
			flipXCheckBox.checked = !flipXCheckBox.checked;
		flipXCheckBox.callback = function()
		{
			char.originalFlipX = !char.originalFlipX;
			char.flipX = char.originalFlipX;
			if (char.isPlayer)
				char.flipX = !char.flipX;

			ghostChar.flipX = char.flipX;
		};

		replacesGFCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y - 20, null, null, "Replaces GF", 50);
		replacesGFCheckBox.checked = char.replacesGF;
		replacesGFCheckBox.callback = function()
		{
			char.replacesGF = false;
			if (hasTrailCheckBox.checked)
			{
				char.replacesGF = true;
			}
			char.replacesGF = replacesGFCheckBox.checked;
		};

		noAntialiasingCheckBox = new FlxUICheckBox(flipXCheckBox.x, flipXCheckBox.y + 20, null, null, "Enable Antialiasing", 80);
		noAntialiasingCheckBox.checked = char.charAntialiasing;
		noAntialiasingCheckBox.callback = function()
		{
			char.charAntialiasing = true;
			if (!noAntialiasingCheckBox.checked && Main.save.data.antialiasing)
			{
				char.charAntialiasing = false;
			}
			char.charAntialiasing = noAntialiasingCheckBox.checked;
		};

		hasTrailCheckBox = new FlxUICheckBox(flipXCheckBox.x, noAntialiasingCheckBox.y + 20, null, null, "Has Trail", 80);
		hasTrailCheckBox.checked = char.hasTrail;
		hasTrailCheckBox.callback = function()
		{
			char.hasTrail = false;
			if (hasTrailCheckBox.checked)
			{
				char.hasTrail = true;
			}
			char.hasTrail = hasTrailCheckBox.checked;
		};

		positionXStepper = new FlxUINumericStepper(flipXCheckBox.x + 110, flipXCheckBox.y, 10, char.positionArray[0], -9000, 9000, 0);
		positionYStepper = new FlxUINumericStepper(positionXStepper.x + 60, positionXStepper.y, 10, char.positionArray[1], -9000, 9000, 0);

		positionCameraXStepper = new FlxUINumericStepper(positionXStepper.x, positionXStepper.y + 40, 10, char.camPos[0], -9000, 9000, 0);
		positionCameraYStepper = new FlxUINumericStepper(positionYStepper.x, positionYStepper.y + 40, 10, char.camPos[1], -9000, 9000, 0);

		var saveCharacterButton:FlxButton = new FlxButton(reloadImage.x, hasTrailCheckBox.y + 40, "Save Character", function()
		{
			saveCharacter();
		});

		healthColorStepperR = new FlxUINumericStepper(singDurationStepper.x, saveCharacterButton.y, 20, char.healthColorArray[0], 0, 255, 0);
		healthColorStepperG = new FlxUINumericStepper(singDurationStepper.x + 65, saveCharacterButton.y, 20, char.healthColorArray[1], 0, 255, 0);
		healthColorStepperB = new FlxUINumericStepper(singDurationStepper.x + 130, saveCharacterButton.y, 20, char.healthColorArray[2], 0, 255, 0);

		tab_group.add(new FlxText(130, imageInputText.y - 18, 0, 'Image file name:'));
		tab_group.add(new FlxText(10, folderInputText.y - 18, 0, 'Character folder name:'));
		tab_group.add(new FlxText(120, startingAnimInputText.y - 18, 0, 'Starting anim name:'));
		tab_group.add(new FlxText(15, healthIconInputText.y - 18, 0, 'Health icon name:'));
		tab_group.add(new FlxText(15, singDurationStepper.y - 25, 0, 'Sing Animation\nlength:'));
		tab_group.add(new FlxText(15, scaleStepper.y - 18, 0, 'Scale:'));
		tab_group.add(new FlxText(positionXStepper.x, positionXStepper.y - 18, 0, 'Character X/Y:'));
		tab_group.add(new FlxText(positionCameraXStepper.x, positionCameraXStepper.y - 18, 0, 'Camera X/Y:'));
		tab_group.add(new FlxText(healthColorStepperR.x, healthColorStepperR.y - 18, 0, 'Health bar R/G/B:'));
		tab_group.add(folderInputText);
		tab_group.add(imageInputText);
		tab_group.add(reloadImage);
		tab_group.add(decideIconColor);
		tab_group.add(startingAnimInputText);
		tab_group.add(healthIconInputText);
		tab_group.add(singDurationStepper);
		tab_group.add(scaleStepper);
		tab_group.add(replacesGFCheckBox);
		tab_group.add(flipXCheckBox);
		tab_group.add(noAntialiasingCheckBox);
		tab_group.add(hasTrailCheckBox);
		tab_group.add(positionXStepper);
		tab_group.add(positionYStepper);
		tab_group.add(positionCameraXStepper);
		tab_group.add(positionCameraYStepper);
		tab_group.add(healthColorStepperR);
		tab_group.add(healthColorStepperG);
		tab_group.add(healthColorStepperB);
		tab_group.add(saveCharacterButton);
		UI_characterbox.addGroup(tab_group);
	}

	var ghostDropDown:FlxUIDropDownMenuCustom;
	var animationDropDown:FlxUIDropDownMenuCustom;
	var nextAnimationInputText:FlxUIInputText;
	var animationInputText:FlxUIInputText;
	var animationNameInputText:FlxUIInputText;
	var animationIndicesInputText:FlxUIInputText;
	var animationNameFramerate:FlxUINumericStepper;
	var animationLoopCheckBox:FlxUICheckBox;
	var animationInterruptCheckBox:FlxUICheckBox;
	var animationFlipXCheckBox:FlxUICheckBox;
	var animationFlipYCheckBox:FlxUICheckBox;

	function addAnimationsUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Animations";

		animationInputText = new FlxUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new FlxUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationIndicesInputText = new FlxUIInputText(animationNameInputText.x, animationNameInputText.y + 40, 250, '', 8);
		animationNameFramerate = new FlxUINumericStepper(animationInputText.x + 100, animationInputText.y, 1, 24, 0, 240, 0);
		nextAnimationInputText = new FlxUIInputText(animationNameInputText.x + 170, animationNameFramerate.y, 150, '', 8);
		animationLoopCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, nextAnimationInputText.y + 20, null, null, "Should it Loop?", 100);
		animationInterruptCheckBox = new FlxUICheckBox(animationNameInputText.x + 170, animationLoopCheckBox.y + 20, null, null, "Can idle interrupt anim?",
			100);
		animationFlipXCheckBox = new FlxUICheckBox(animationLoopCheckBox.x + 110, nextAnimationInputText.y + 20, null, null, "Flip X", 100);
		animationFlipYCheckBox = new FlxUICheckBox(animationInterruptCheckBox.x + 110, animationLoopCheckBox.y + 20, null, null, "Flix Y", 100);

		animationDropDown = new FlxUIDropDownMenuCustom(15, animationInputText.y - 55, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true),
			function(pressed:String)
			{
				var selectedAnimation:Int = Std.parseInt(pressed);
				var anim:AnimationData = char.animationsArray[selectedAnimation];
				animationInputText.text = anim.name;
				animationNameInputText.text = anim.prefix;
				animationLoopCheckBox.checked = anim.looped;
				animationFlipXCheckBox.checked = anim.flipX;
				animationFlipYCheckBox.checked = anim.flipY;
				if (anim.nextAnim != null)
					nextAnimationInputText.text = anim.nextAnim;
				else
					nextAnimationInputText.text = 'idle';

				if (anim.frameRate > 0)
					animationNameFramerate.value = anim.frameRate;
				else
					animationNameFramerate.value = 24;

				if (anim.interrupt != null)
					animationInterruptCheckBox.checked = anim.interrupt;
				else
					animationInterruptCheckBox.checked = true;

				var indicesStr:String = anim.frameIndices.toString();
				animationIndicesInputText.text = indicesStr.substr(1, indicesStr.length - 2);
			});
		blockPressWhileScrolling.push(animationDropDown);

		ghostDropDown = new FlxUIDropDownMenuCustom(animationDropDown.x + 150, animationDropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true),
			function(pressed:String)
			{
				var selectedAnimation:Int = Std.parseInt(pressed);
				ghostChar.visible = false;
				char.alpha = 1;
				if (selectedAnimation > 0)
				{
					ghostChar.visible = true;
					ghostChar.playAnim(ghostChar.animationsArray[selectedAnimation - 1].name, true);
					char.alpha = 0.85;
				}
			});
		blockPressWhileScrolling.push(ghostDropDown);

		var addUpdateButton:FlxButton = new FlxButton(70, animationIndicesInputText.y + 30, "Add/Update", function()
		{
			var indices:Array<Int> = [];
			var indicesStr:Array<String> = animationIndicesInputText.text.trim().split(',');
			if (indicesStr.length > 1)
			{
				for (i in 0...indicesStr.length)
				{
					var index:Int = Std.parseInt(indicesStr[i]);
					if (indicesStr[i] != null && indicesStr[i] != '' && !Math.isNaN(index) && index > -1)
					{
						indices.push(index);
					}
				}
			}

			var lastAnim:String = '';
			if (char.animationsArray[curAnim] != null)
			{
				lastAnim = char.animationsArray[curAnim].name;
			}

			var lastOffsets:Array<Int> = [0, 0];
			for (anim in char.animationsArray)
			{
				if (animationInputText.text == anim.name)
				{
					lastOffsets = anim.offsets;
					if (char.animation.getByName(animationInputText.text) != null)
					{
						char.animation.remove(animationInputText.text);
					}
					char.animationsArray.remove(anim);
				}
			}

			var newAnim:AnimationData = {
				name: animationInputText.text,
				prefix: animationNameInputText.text,
				frameRate: Math.round(animationNameFramerate.value),
				looped: animationLoopCheckBox.checked,
				nextAnim: nextAnimationInputText.text,
				interrupt: animationInterruptCheckBox.checked,
				frameIndices: indices,
				flipX: animationFlipXCheckBox.checked,
				flipY: animationFlipYCheckBox.checked,
				offsets: lastOffsets
			};
			if (indices != null && indices.length > 0)
			{
				char.animation.addByIndices(newAnim.name, newAnim.prefix, newAnim.frameIndices, "", newAnim.frameRate, newAnim.looped, newAnim.flipX,
					newAnim.flipY);
			}
			else
			{
				char.animation.addByPrefix(newAnim.name, newAnim.prefix, newAnim.frameRate, newAnim.looped, newAnim.flipX, newAnim.flipY);
			}

			if (!char.animOffsets.exists(newAnim.name))
			{
				char.addOffset(newAnim.name, 0, 0);
			}
			char.animationsArray.push(newAnim);

			if (lastAnim == animationInputText.text)
			{
				var leAnim:FlxAnimation = char.animation.getByName(lastAnim);
				if (leAnim != null && leAnim.frames.length > 0)
				{
					char.playAnim(lastAnim, true);
				}
				else
				{
					for (i in 0...char.animationsArray.length)
					{
						if (char.animationsArray[i] != null)
						{
							leAnim = char.animation.getByName(char.animationsArray[i].name);
							if (leAnim != null && leAnim.frames.length > 0)
							{
								char.playAnim(char.animationsArray[i].name, true);
								curAnim = i;
								break;
							}
						}
					}
				}
			}

			reloadAnimationDropDown();
			genBoyOffsets();
			trace('Added/Updated animation: ' + animationInputText.text);
		});

		var removeButton:FlxButton = new FlxButton(180, animationIndicesInputText.y + 30, "Remove", function()
		{
			for (anim in char.animationsArray)
			{
				if (animationInputText.text == anim.name)
				{
					var resetAnim:Bool = false;
					if (char.animation.curAnim != null && anim.name == char.animation.curAnim.name)
						resetAnim = true;

					if (char.animation.getByName(anim.name) != null)
					{
						char.animation.remove(anim.name);
					}
					if (char.animOffsets.exists(anim.name))
					{
						char.animOffsets.remove(anim.name);
					}
					char.animationsArray.remove(anim);

					if (resetAnim && char.animationsArray.length > 0)
					{
						char.playAnim(char.animationsArray[0].name, true);
					}
					reloadAnimationDropDown();
					genBoyOffsets();
					trace('Removed animation: ' + animationInputText.text);
					break;
				}
			}
		});

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 0, 'Animations:'));
		tab_group.add(new FlxText(ghostDropDown.x, ghostDropDown.y - 18, 0, 'Animation Ghost:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 0, 'Animation name:'));
		tab_group.add(new FlxText(nextAnimationInputText.x, nextAnimationInputText.y - 18, 0, 'Next animation name:'));
		tab_group.add(new FlxText(animationNameFramerate.x, animationNameFramerate.y - 18, 0, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 0, 'Animation on .XML/.TXT file:'));
		tab_group.add(new FlxText(animationIndicesInputText.x, animationIndicesInputText.y - 18, 0, 'ADVANCED - Animation Indices:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationIndicesInputText);
		tab_group.add(animationNameFramerate);
		tab_group.add(nextAnimationInputText);
		tab_group.add(animationLoopCheckBox);
		tab_group.add(animationFlipXCheckBox);
		tab_group.add(animationFlipYCheckBox);
		tab_group.add(animationInterruptCheckBox);
		tab_group.add(addUpdateButton);
		tab_group.add(removeButton);
		tab_group.add(ghostDropDown);
		tab_group.add(animationDropDown);
		UI_characterbox.addGroup(tab_group);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == healthIconInputText)
			{
				leHealthIcon.changeIcon(charFolder, healthIconInputText.text);
				char.characterIcon = healthIconInputText.text;
			}
			if (sender == imageInputText)
			{
				char.asset = imageInputText.text;
			}
			if (sender == folderInputText)
			{
				charFolder = folderInputText.text;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			if (sender == scaleStepper)
			{
				reloadCharacterImage();
				char.jsonScale = sender.value;
				char.setGraphicSize(Std.int(char.width * char.jsonScale));
				char.updateHitbox();
				reloadGhost();
				updatePointerPos();

				if (char.animation.curAnim != null)
				{
					char.playAnim(char.animation.curAnim.name, true);
				}
			}
			else if (sender == positionXStepper)
			{
				char.positionArray[0] = positionXStepper.value;
				char.x = char.positionArray[0] + OFFSET_X + 100;
				updatePointerPos();
			}
			else if (sender == singDurationStepper)
			{
				char.holdLength = singDurationStepper.value; // ermm you forgot this??
			}
			else if (sender == positionYStepper)
			{
				char.positionArray[1] = positionYStepper.value;
				char.y = char.positionArray[1];
				updatePointerPos();
			}
			else if (sender == positionCameraXStepper)
			{
				char.camPos[0] = positionCameraXStepper.value;
				updatePointerPos();
			}
			else if (sender == positionCameraYStepper)
			{
				char.camPos[1] = positionCameraYStepper.value;
				updatePointerPos();
			}
			else if (sender == healthColorStepperR)
			{
				char.healthColorArray[0] = Math.round(healthColorStepperR.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
			else if (sender == healthColorStepperG)
			{
				char.healthColorArray[1] = Math.round(healthColorStepperG.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
			else if (sender == healthColorStepperB)
			{
				char.healthColorArray[2] = Math.round(healthColorStepperB.value);
				healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
			}
		}
	}

	function reloadCharacterImage()
	{
		var lastAnim:String = '';
		if (char.animation.curAnim != null)
		{
			lastAnim = char.animation.curAnim.name;
		}
		var anims:Array<AnimationData> = char.animationsArray.copy();

		char.frames = Paths.getCharacterFrames(charFolder, char.asset.replaceAll('characters/', ''));

		if (char.animationsArray != null && char.animationsArray.length > 0)
		{
			for (anim in char.animationsArray)
			{
				var animAnim:String = '' + anim.name;
				var animName:String = '' + anim.prefix;
				var animFps:Int;
				var flipX:Bool = anim.flipX;
				var flipY:Bool = anim.flipY;
				if (anim.frameRate > 0)
					animFps = anim.frameRate;
				else
					animFps = 24;
				var animLoop:Bool = !!anim.looped; // Bruh
				var animIndices:Array<Int> = anim.frameIndices;
				if (animIndices != null && animIndices.length > 0)
				{
					char.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop, flipX, flipY);
				}
				else
				{
					char.animation.addByPrefix(animAnim, animName, animFps, animLoop, flipX, flipY);
				}
			}
		}
		else
		{
			char.quickAnimAdd('idle', 'BF idle dance');
		}

		if (lastAnim != '')
		{
			char.playAnim(lastAnim, true);
		}
		else
		{
			char.dance();
		}
		ghostDropDown.selectedLabel = '';
		reloadGhost();
	}

	function genBoyOffsets():Void
	{
		var daLoop:Int = 0;

		var i:Int = dumbTexts.members.length - 1;
		while (i >= 0)
		{
			var memb:FlxText = dumbTexts.members[i];
			if (memb != null)
			{
				memb.kill();
				dumbTexts.remove(memb);
				memb.destroy();
			}
			--i;
		}
		dumbTexts.clear();

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(null, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 1;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			daLoop++;
		}

		textAnim.visible = true;
		if (dumbTexts.length < 1)
		{
			var text:FlxText = new FlxText(10, 38, 0, "ERROR! No animations found.", 15);
			text.scrollFactor.set();
			text.borderSize = 1;
			dumbTexts.add(text);
			textAnim.visible = false;
		}
	}

	function loadChar(isDad:Bool, blahBlahBlah:Bool = true)
	{
		var i:Int = charLayer.members.length - 1;
		while (i >= 0)
		{
			var memb:Character = charLayer.members[i];
			if (memb != null)
			{
				memb.kill();
				charLayer.remove(memb);
				memb.destroy();
			}
			--i;
		}
		charLayer.clear();
		ghostChar = new Character(char_X, char_Y, daAnim, !isDad);
		ghostChar.debugMode = true;
		ghostChar.alpha = 0.6;

		char = new Character(char_X, char_Y, daAnim, !isDad);
		if (char.animationsArray[0] != null)
		{
			char.playAnim(char.animationsArray[0].name, true);
		}
		char.debugMode = true;

		charLayer.add(ghostChar);
		charLayer.add(char);

		char.x += char.positionArray[0] + OFFSET_X;
		char.y += char.positionArray[1];

		if (blahBlahBlah)
		{
			genBoyOffsets();
		}
		reloadCharacterOptions();
		reloadBGs();
		updatePointerPos();
	}

	function updatePointerPos()
	{
		var x:Float = char.getMidpoint().x;
		var y:Float = char.getMidpoint().y;
		if (!char.isPlayer)
		{
			x += 150 + char.camPos[0];
		}
		else
		{
			x -= 100 + char.camPos[0];
		}
		y -= 100 - char.camPos[1];

		x -= cameraFollowPointer.width / 2;
		y -= cameraFollowPointer.height / 2;
		cameraFollowPointer.setPosition(x, y);
	}

	function findAnimationByName(name:String):AnimationData
	{
		for (anim in char.animationsArray)
		{
			if (anim.name == name)
			{
				return anim;
			}
		}
		return null;
	}

	function reloadCharacterOptions()
	{
		if (UI_characterbox != null)
		{
			charFolder = char.curCharacter;
			folderInputText.text = charFolder;
			imageInputText.text = char.asset.replaceAll('characters/', '');
			startingAnimInputText.text = char.startingAnim;
			healthIconInputText.text = char.characterIcon;
			singDurationStepper.value = char.holdLength;
			replacesGFCheckBox.checked = char.replacesGF;
			if (char.jsonScale > 0)
				scaleStepper.value = char.jsonScale;
			else
				scaleStepper.value = 1;

			flipXCheckBox.checked = char.flipX;
			noAntialiasingCheckBox.checked = char.charAntialiasing;
			hasTrailCheckBox.checked = char.hasTrail;
			resetHealthBarColor();
			leHealthIcon.changeIcon(charFolder, healthIconInputText.text);
			if (char.positionArray != null)
			{
				positionXStepper.value = char.positionArray[0];
				positionYStepper.value = char.positionArray[1];
			}
			else
			{
				positionXStepper.value = 0;
				positionYStepper.value = 0;
			}
			if (char.camPos != null)
			{
				positionCameraXStepper.value = char.camPos[0];
				positionCameraYStepper.value = char.camPos[1];
			}
			else
			{
				positionCameraXStepper.value = 0;
				positionCameraYStepper.value = 0;
			}
			reloadAnimationDropDown();
			updatePresence();
		}
	}

	function reloadAnimationDropDown()
	{
		var anims:Array<String> = [];
		var ghostAnims:Array<String> = [''];
		for (anim in char.animationsArray)
		{
			anims.push(anim.name);
			ghostAnims.push(anim.name);
		}
		if (anims.length < 1)
			anims.push('NO ANIMATIONS'); // Prevents crash

		animationDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(anims, true));
		ghostDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(ghostAnims, true));
		reloadGhost();
	}

	function reloadGhost()
	{
		ghostChar.frames = char.frames;
		for (anim in char.animationsArray)
		{
			var animAnim:String = '' + anim.name;
			var animName:String = '' + anim.prefix;
			var animFps:Int;
			var flipX:Bool = anim.flipX;
			var flipY:Bool = anim.flipY;
			if (anim.frameRate > 0)
				animFps = anim.frameRate;
			else
				animFps = 24;
			var animLoop:Bool = !!anim.looped; // Bruh
			var animIndices:Array<Int> = anim.frameIndices;
			if (animIndices != null && animIndices.length > 0)
			{
				ghostChar.animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop, flipX, flipY);
			}
			else
			{
				ghostChar.animation.addByPrefix(animAnim, animName, animFps, animLoop, flipX, flipY);
			}

			if (anim.offsets != null && anim.offsets.length > 1)
			{
				ghostChar.addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
			}
		}

		char.alpha = 0.85;
		ghostChar.visible = true;
		if (ghostDropDown.selectedLabel == '')
		{
			ghostChar.visible = false;
			char.alpha = 1;
		}
		ghostChar.color = 0xFF666688;

		ghostChar.setGraphicSize(Std.int(ghostChar.width * char.jsonScale));
		ghostChar.updateHitbox();
	}

	function reloadCharacterDropDown()
	{
		var charsLoaded:Map<String, Bool> = new Map();

		characterList = CharactersStuff.characterList;

		charDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
		charDropDown.selectedLabel = daAnim;
	}

	function resetHealthBarColor()
	{
		healthColorStepperR.value = char.healthColorArray[0];
		healthColorStepperG.value = char.healthColorArray[1];
		healthColorStepperB.value = char.healthColorArray[2];
		healthBarBG.color = FlxColor.fromRGB(char.healthColorArray[0], char.healthColorArray[1], char.healthColorArray[2]);
	}

	function updatePresence()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Character Editor", "Character: " + daAnim, daAnim);
		#end
	}

	private var lastPosition:FlxPoint = new FlxPoint();
	private var mouseDiff:FlxPoint = new FlxPoint();

	override function update(elapsed:Float)
	{
		Stage.update(elapsed);

		MusicBeatState.camBeat = FlxG.camera;

		var blockInput = false;

		if (!blockInput)
		{
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (char.animationsArray[curAnim] != null)
		{
			textAnim.text = char.animationsArray[curAnim].name;

			var curAnim:FlxAnimation = char.animation.getByName(char.animationsArray[curAnim].name);
			if (curAnim == null || curAnim.frames.length < 1)
			{
				textAnim.text += ' (ERROR!)';
			}
		}
		else
		{
			textAnim.text = '';
		}

		var inputTexts:Array<FlxUIInputText> = [
			animationInputText,
			imageInputText,
			folderInputText,
			healthIconInputText,
			startingAnimInputText,
			animationNameInputText,
			animationIndicesInputText,
			nextAnimationInputText
		];
		for (i in 0...inputTexts.length)
		{
			if (inputTexts[i].hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = [FlxKey.fromString(Main.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(Main.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(Main.save.data.volUpBind)];

		if (!charDropDown.dropPanel.visible)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				if (goToPlayState)
				{
					MusicBeatState.switchState(new states.PlayState());
				}
				else
				{
					MusicBeatState.switchState(new MasterEditorMenu());
					FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
				}
				FlxG.mouse.visible = false;
				return;
			}

			if (FlxG.keys.justPressed.R)
			{
				FlxG.camera.zoom = 1;
				if (FlxG.keys.pressed.SHIFT)
					camFollow.screenCenter();
			}

			if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
			{
				FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
				if (FlxG.camera.zoom > 3)
					FlxG.camera.zoom = 3;
			}
			if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
			{
				FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
				if (FlxG.camera.zoom < 0.1)
					FlxG.camera.zoom = 0.1;
			}

			if (char.animationsArray.length > 0)
			{
				if (FlxG.keys.justPressed.W)
				{
					curAnim -= 1;
				}

				if (FlxG.keys.justPressed.S)
				{
					curAnim += 1;
				}

				if (curAnim < 0)
					curAnim = char.animationsArray.length - 1;

				if (curAnim >= char.animationsArray.length)
					curAnim = 0;

				if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				{
					char.playAnim(char.animationsArray[curAnim].name, true);
					genBoyOffsets();
				}

				if (FlxG.keys.justPressed.R)
				{
					char.animationsArray[curAnim].offsets = [0, 0];

					char.addOffset(char.animationsArray[curAnim].name, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
					ghostChar.addOffset(char.animationsArray[curAnim].name, char.animationsArray[curAnim].offsets[0],
						char.animationsArray[curAnim].offsets[1]);
					genBoyOffsets();
				}

				var controlArray:Array<Bool> = [
					FlxG.keys.justPressed.LEFT,
					FlxG.keys.justPressed.RIGHT,
					FlxG.keys.justPressed.UP,
					FlxG.keys.justPressed.DOWN
				];

				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
					{
						var holdShift = FlxG.keys.pressed.SHIFT;
						var multiplier = 1;
						if (holdShift)
							multiplier = 10;

						var arrayVal = 0;
						if (i > 1)
							arrayVal = 1;

						var negaMult:Int = 1;
						if (i % 2 == 1)
							negaMult = -1;
						char.animationsArray[curAnim].offsets[arrayVal] += negaMult * multiplier;
						char.addOffset(char.animationsArray[curAnim].name, char.animationsArray[curAnim].offsets[0], char.animationsArray[curAnim].offsets[1]);
						ghostChar.addOffset(char.animationsArray[curAnim].name, char.animationsArray[curAnim].offsets[0],
							char.animationsArray[curAnim].offsets[1]);

						char.playAnim(char.animationsArray[curAnim].name, false);
						if (ghostChar.animation.curAnim != null
							&& char.animation.curAnim != null
							&& char.animation.curAnim.name == ghostChar.animation.curAnim.name)
						{
							ghostChar.playAnim(char.animation.curAnim.name, false);
						}
						genBoyOffsets();
					}
				}
			}
		}
		camMenu.zoom = FlxG.camera.zoom;
		ghostChar.setPosition(char.x, char.y);
		super.update(elapsed);

		if (FlxG.mouse.justPressedRight)
		{
			lastPosition.set(CoolUtil.boundTo(FlxG.mouse.getScreenPosition().x, 0, FlxG.width),
				CoolUtil.boundTo(FlxG.mouse.getScreenPosition().y, 0, FlxG.height));
		}

		if (FlxG.mouse.pressedRight) // draggable camera with mouse movement
		{
			FlxG.mouse.visible = false;

			mouseDiff.set((lastPosition.x - FlxG.mouse.getScreenPosition().x), (lastPosition.y - FlxG.mouse.getScreenPosition().y));

			if (FlxG.mouse.justMoved)
			{
				var mult:Float = 1;

				if (FlxG.keys.pressed.SHIFT)
					mult = 4;

				camFollow.x = camFollow.x - -CoolUtil.boundTo(mouseDiff.x, -FlxG.width, FlxG.width) * mult;
				camFollow.y = camFollow.y - -CoolUtil.boundTo(mouseDiff.y, -FlxG.height, FlxG.height) * mult;

				lastPosition.set(CoolUtil.boundTo(FlxG.mouse.getScreenPosition().x, 0, FlxG.width),
					CoolUtil.boundTo(FlxG.mouse.getScreenPosition().y, 0, FlxG.height));
			}
		}
		else
		{
			FlxG.mouse.visible = true;
		}

		if (FlxG.mouse.wheel != 0 && !blockInput)
		{
			FlxG.camera.zoom += FlxG.mouse.wheel / 10;
		}
	}

	var _file:FileReference;

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	function saveCharacter()
	{
		var json = {
			"name": char.asset.replaceAll('characters/', ''),
			"asset": char.asset.replaceAll('characters/', ''),
			"characterIcon": char.characterIcon,
			"scale": char.jsonScale,
			"holdLength": char.holdLength,
			"hasTrail": char.hasTrail,
			"replacesGF": char.replacesGF,
			"startingAnim": char.startingAnim,

			"charPos": char.positionArray,
			"camPos": char.camPos,

			"flipX": char.originalFlipX,
			"antialiasing": char.charAntialiasing,
			"barColorJson": char.healthColorArray,
			"animations": char.animationsArray
		};

		var data:String = Json.stringify(json, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, daAnim + ".json");
		}
	}

	function ClipboardAdd(prefix:String = ''):String
	{
		if (prefix.toLowerCase().endsWith('v')) // probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length - 1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}
