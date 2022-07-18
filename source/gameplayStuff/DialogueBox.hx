package gameplayStuff;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.PlayState;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var skipText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var sound:FlxSound;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai':
				sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox'), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
			case 'thorns':
				sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary'), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		bgFade.scrollFactor.set();
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.songId.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.play('normalOpen');
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				box.scrollFactor.set();
				box.updateHitbox();
				add(box);
				box.screenCenter(X);

			case 'roses':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.play('normalOpen');
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				box.scrollFactor.set();
				box.updateHitbox();
				add(box);
				box.screenCenter(X);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				box.animation.play('normalOpen');
				box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
				box.scrollFactor.set();
				box.updateHitbox();
				add(box);
				box.screenCenter(X);

			default:
				if (PlayState.SONG.noteStyle == 'pixel')
					{
						hasDialog = true;
						box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
						box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
						box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
						box.animation.play('normalOpen');
						box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
						box.scrollFactor.set();
						box.updateHitbox();
						add(box);
						box.screenCenter(X);
					}
				else
					{
						hasDialog = true;
						box.frames = Paths.getSparrowAtlas('speech_bubble');
						box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
						box.animation.addByPrefix('loudOpen', 'speech bubble loud open', 24, false);
						box.animation.addByPrefix('loud', 'AHH speech bubble', 24, true);
						box.animation.addByPrefix('normal', 'speech bubble normal0', 24, true);
						box.animation.play('normalOpen');
						box.setGraphicSize(Std.int(box.width * 0.9));
						box.scrollFactor.set();
						box.updateHitbox();
						add(box);
						box.y += 300;
						box.screenCenter(X);
					}	
		}

		portraitRight = new FlxSprite(0, 40);

		portraitLeft = new FlxSprite(-20, 40);

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;
		
		skipText = new FlxText(10, 10, Std.int(FlxG.width * 0.6), "", 16);
		if (!FlxG.save.data.language)
		{
			skipText.font = 'Pixel Arial 11 Bold';
			skipText.text = 'press back to skip';
		}
		else
		{
			skipText.font = Paths.font("UbuntuBold.ttf");
			skipText.size = 24;
			skipText.text = 'нажми ESC или BACKSPACE для пропуска';
		}

		skipText.color = 0x000000;
		skipText.scrollFactor.set();
		add(skipText);
		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.loadImage('hand_textbox'));
		handSelect.scrollFactor.set();
		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 482, Std.int(FlxG.width * 0.6), "", 32);
		if (!FlxG.save.data.language)
			dropText.font = 'Pixel Arial 11 Bold';
		else
		{
			dropText.font = Paths.font("UbuntuBold.ttf");
			dropText.size = 48;
		}
		dropText.color = 0xFFD89494;
		dropText.scrollFactor.set();
		add(dropText);

		swagDialogue = new FlxTypeText(240, 480, Std.int(FlxG.width * 0.6), "", 32);
		if (!FlxG.save.data.language)
			swagDialogue.font = 'Pixel Arial 11 Bold';
		else
		{
			swagDialogue.font = Paths.font("UbuntuBold.ttf");
			swagDialogue.size = 48;
		}
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		swagDialogue.scrollFactor.set();
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}
		if (PlayerSettings.player1.controls.BACK && isEnding != true)
		{
			remove(dialogue);
			isEnding = true;
			switch (PlayState.SONG.songId.toLowerCase())
			{
				case "senpai" | "thorns":
					sound.fadeOut(2.2, 0);
				case "roses":
					trace("roses");
				default:
					trace("other song");
			}
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitLeft.visible = false;
				portraitRight.visible = false;
				swagDialogue.alpha -= 1 / 5;
				dropText.alpha = swagDialogue.alpha;
				if (sound != null)
				{
					if (sound.playing)
						sound.stop();
				}
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
						if (sound != null)
						{
							if (sound.playing)
								sound.stop();
						}
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;
	var oldCharacter:String;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		if (curCharacter != oldCharacter)
		{
			parseDataFile();
			oldCharacter = curCharacter;
		}
		else
			return;
		
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating dialogue character (${curCharacter})');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.loadJSON('dialogue/${curCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:DialogueCharacterJson = cast jsonData;

		if (data.isDad)
		{
			portraitLeft.frames = Paths.getSparrowAtlas('dialogue/' + data.image);
			for (anim in data.animations)
			{
				portraitLeft.animation.addByPrefix(anim.name, anim.prefix, 24, false);
			}

			if (!data.pixelZoom)
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
			else
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * CoolUtil.daPixelZoom * 0.9));

			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();

			if (data.portraitX != null)
				portraitLeft.x += data.portraitX;

			if (data.portraitY != null)
				portraitLeft.y += data.portraitY;

			add(portraitLeft);
			portraitLeft.visible = false;

			portraitRight.visible = false;
			if (!portraitLeft.visible)
			{
				portraitLeft.visible = true;
				portraitLeft.animation.play(data.startingAnim);
			}
		}
		else
		{
			portraitRight.frames = Paths.getSparrowAtlas('dialogue/' + data.image);
			for (anim in data.animations)
			{
				portraitRight.animation.addByPrefix(anim.name, anim.prefix, 24, false);
			}
			if (!data.pixelZoom)
				portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
			else
				portraitRight.setGraphicSize(Std.int(portraitRight.width * CoolUtil.daPixelZoom * 0.9));

			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();

			if (data.portraitX != null)
				portraitRight.x += data.portraitX;

			if (data.portraitY != null)
				portraitRight.y += data.portraitY;

			add(portraitRight);

			portraitRight.visible = false;

			portraitLeft.visible = false;
			if (!portraitRight.visible)
			{
				portraitRight.visible = true;
				portraitRight.animation.play(data.startingAnim);
			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
typedef DialogueCharacterJson =
{
	var image:String;
	var isDad:Bool;
	var animations:Array<DialogueAnimArrayJson>;
	var startingAnim:String;
	var pixelZoom:Bool;
	var ?portraitX:Int;
	var ?portraitY:Int;
}

typedef DialogueAnimArrayJson =
{
	var name:String;
	var prefix:String;
	var offsets:Array<Int>;
}
