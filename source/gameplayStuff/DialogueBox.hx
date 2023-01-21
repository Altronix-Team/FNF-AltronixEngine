package gameplayStuff;

import states.FreeplayState.CharColor;
import openfl.utils.Assets;
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


class DialogueBox extends FlxSpriteGroup
{
	public var dialogueBoxJson(default, set):DialogueBoxJson;
	public var dialogueSound(default, set):String;
	public var dialogue(default, set):DialogueJson;
	
	public var isPixel:Bool = false;

	var curLine:DialogueLines = null;

	var curLineInt = 0;

	var box:DialogueBoxSprite;

	//All dialogue lines
	var dialogueLines:Array<String> = [];

	//All anims that should characters play in this dialogue
	var dialogueCharactersAnims:Array<String> = [];

	var dialogueBoxStates:Array<String> = ['normal'];

	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var skipText:FlxText;

	public var finishThing:Void->Void = PlayState.instance.startCountdown; //Set the default finish dialogue function
	public var nextLineThing:Void->Void;
	public var skipDialogueThing:Void->Void;
	public var skipLineThing:Void->Void;

	var curDialogueCharacter:DialogueCharacter = null;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var sound:FlxSound;

	var boxFile:String = 'speech_bubble';

	public function new(dialogueFile:DialogueJson, ?boxFile:String)
	{
		super();

		dialogue = dialogueFile;

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

		box = new DialogueBoxSprite(-20, 45);

		if (boxFile != null) this.boxFile = boxFile;

		if (dialogue != null)
			curLine = dialogue.dialogue[0];

		loadDialogueBoxFile(this.boxFile);
		
		skipText = new FlxText(10, 10, Std.int(FlxG.width * 0.6), "", 16);
		skipText.font = Paths.font(LanguageStuff.fontName);
		skipText.text = 'press back to skip';
		skipText.color = 0x000000;
		skipText.scrollFactor.set();
		add(skipText);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.loadImage('hand_textbox'));
		handSelect.scrollFactor.set();
		add(handSelect);

		swagDialogue = new FlxTypeText(240, 480, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = Paths.font(LanguageStuff.fontName);
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.scrollFactor.set();
		swagDialogue.skipCallback = function(){if (skipLineThing != null)skipLineThing();};

		if (dialogueBoxJson.textYOffset != null)
			swagDialogue.y += dialogueBoxJson.textYOffset;

		if (dialogueBoxJson.textXOffset != null)
			swagDialogue.x += dialogueBoxJson.textXOffset;

		dropText = new FlxText(swagDialogue.x + 2, swagDialogue.y + 2, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = Paths.font(LanguageStuff.fontName);
		dropText.color = 0xFFD89494;
		dropText.scrollFactor.set();
		add(dropText);

		add(swagDialogue);

		curDialogueCharacter = new DialogueCharacter(curLine.character);
		add(curDialogueCharacter);

		//Set up after create all
		box.onAppearCallback = function()
		{
			if (!dialogueStarted && dialogue != null && curLine != null)
			{
				startDialogue();
				dialogueStarted = true;
			}
		}

		if (dialogue == null && curLine == null)
		{
			Debug.logError('Oh, fuck, dialogue is broken');
			if (finishThing != null) finishThing();
			kill();
		}
	}

	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (PlayerSettings.player1.controls.BACK && isEnding != true)
		{
			dialogueEnd();
			if (skipDialogueThing != null) skipDialogueThing();
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (curLineInt == dialogueLines.length - 1)
			{
				if (!isEnding)
				{
					dialogueEnd();
				}
			}
			else
			{
				if (isTyping)
					swagDialogue.skip();
				nextDialogueLine();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;
	var isTyping:Bool = false;

	function nextDialogueLine():Void
	{
		curLineInt += 1;
		startDialogue();
	}

	function startDialogue():Void
	{
		reloadLine();

		swagDialogue.sounds = [FlxG.sound.load(Paths.sound(curLine.sound != null ? curLine.sound : 'pixelText'), 0.6)];
		swagDialogue.resetText(dialogueLines[curLineInt]);
		swagDialogue.start(curLine.speed != null ? curLine.speed : 0.03, true, false, [], function(){isTyping = false;});
		isTyping = true;

		curDialogueCharacter.reloadCharacter(curDialogueCharacter.reloadJson(curLine.character));

		curDialogueCharacter.playAnim(dialogueCharactersAnims[curLineInt]);

		box.flipX = false;

		box.boxState = /*box.returnBoxState(*/curLine.boxState/*)*/;

		switch (curDialogueCharacter.position)
		{
			case LEFT:
				box.flipX = true;
				box.playAnim(box.boxState/*box.returnStateAnim()*/);
			case MIDDLE:
				box.playAnim(box.boxState/*box.returnStateAnim()*/);
			default:
				box.playAnim(box.boxState/*box.returnStateAnim()*/);
		}	

		if (nextLineThing != null) nextLineThing();
	}

	function reloadLine(){
		if (dialogue != null)
			curLine = dialogue.dialogue[curLineInt];
	}

	function dialogueEnd()
	{
		Debug.logInfo('Dialogue ending');
		box.closeBox();
		isEnding = true;
		if (sound != null)
			sound.fadeOut(2.2, 0);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			box.alpha -= 1 / 5;
			bgFade.alpha -= 1 / 5 * 0.7;
			curDialogueCharacter.visible = false;
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
			if (finishThing != null) finishThing();
			kill();
		});
	}


	function generateBoxSprite(json:DialogueBoxJson)
	{
		Debug.logInfo('Generating dialogue box sprite');
		box.frames = FlxAtlasFrames.fromSparrow(Paths.file('ui/' + (isPixel ? 'pixel/' : 'normal/') + '${json.image}.png', 'core'), Paths.file('ui/' + (isPixel ? 'pixel/' : 'normal/') + '${json.image}.xml', 'core'));
		for (anim in json.anims)
		{
			if (anim.animIndices.length > 0)
			{
				box.animation.addByIndices(anim.animName, anim.animPrefix, anim.animIndices, "", anim.animFramerate, anim.isLooped);
			}
			else
			{
				box.animation.addByPrefix(anim.animName, anim.animPrefix, anim.animFramerate, anim.isLooped);
			}
		}
		box.boxState = /*box.returnBoxState(*/dialogueBoxStates[0]/*)*/;
		switch (box.boxState)
		{
			case ANGRY:
				box.playAnim('angryOpen');
			case MIDDLE:
				box.playAnim('center-normalOpen');
			case ANGRY_MIDDLE:
				box.playAnim('center-angryOpen');
			default:
				box.playAnim('normalOpen');
		}
		box.setGraphicSize(Std.int(box.width * json.scale));
		box.scrollFactor.set();
		box.updateHitbox();
		add(box);
		box.screenCenter(X);
		box.x += json.xOffset;
		box.y += json.yOffset;
		Debug.logInfo('Dialogue box succesfully generated');
	}

	public function loadDialogueBoxFile(file:String)
	{
		var rawJson = null;

		if (Assets.exists(Paths.json('data/dialogue/boxes/$file')))
		{
			rawJson = Paths.loadJSON('data/dialogue/boxes/$file');
		}
		else
		{
			rawJson = Paths.loadJSON('data/dialogue/boxes/speech_bubble');
		}
		if (rawJson == null)
		{
			Debug.logError('Failed to found ${file}');
			return;
		}

		dialogueBoxJson = cast rawJson;
	}

	public function parseDialogueFile(dialogueFile:DialogueJson)
	{
		Debug.logInfo('Starting parsing dialogue file');
		if (dialogueFile != null)
		{
			dialogueBoxStates = [];
			if (dialogueFile.boxType != null)
				boxFile = dialogueFile.boxType;

			if (dialogueFile.sound != null)
				dialogueSound = dialogueFile.sound;

			for (line in dialogueFile.dialogue)
			{
				dialogueLines.push(line.line);
				dialogueCharactersAnims.push(line.expression);
				dialogueBoxStates.push(line.boxState);
			}
			Debug.logInfo('Succesfully loaded dialogue file');
		}	
	}

	function set_dialogue(value:DialogueJson):DialogueJson {
		if (value != null && dialogue != value){ parseDialogueFile(value);
			dialogue = value;}
		return value;
	}

	function set_dialogueSound(value:String):String
	{
		if (value != null && value != '' && dialogueSound != value)
		{
			if (sound != null)
			{
				if (sound.playing)
				{
					sound.stop();
					FlxG.sound.list.remove(sound);
				}
				sound = null;
			}

			sound = new FlxSound().loadEmbedded(Paths.music(value), true);
			sound.volume = 0;
			FlxG.sound.list.add(sound);
			sound.fadeIn(1, 0, 0.8);
			dialogueSound = value;
		}
		return value;
	}

	function set_dialogueBoxJson(value:DialogueBoxJson):DialogueBoxJson
	{
		if (value != null && dialogueBoxJson != value)
		{
			generateBoxSprite(value);
			dialogueBoxJson = value;
		}
		return value;
	}
}

class DialogueCharacter extends FlxSprite
{
	var animOffsets:Map<String, Array<Int>> = new Map();
	public var animations:Map<String, DialogueAnimArrayJson> = new Map();
	public var jsonFile:DialogueCharacterJson = null;
	public var characterName:String = 'bf';
	public var position:CharacterPositions = RIGHT;
	var curAnim:String = null;

	public static var LEFT_CHAR_X:Float = -60;
	public static var RIGHT_CHAR_X:Float = -100;
	public static var DEFAULT_CHAR_Y:Float = 60;

	var offsetPos:Float = -600;

	public function new(character:String = 'bf')
	{
		Debug.logInfo('generating new dialogue character $character');

		characterName = character;
		jsonFile = reloadJson(character);

		super();
		
		reloadCharacter(jsonFile);
		antialiasing = Main.save.data.antialiasing;
		antialiasing = jsonFile.antialiasing;
	}

	public function reloadJson(char:String):DialogueCharacterJson {
		var rawJson = null;

		if (Assets.exists(Paths.json('data/dialogue/characters/$char')))
		{
			rawJson = Paths.loadJSON('data/dialogue/characters/$char');
		}
		else
		{
			rawJson = Paths.loadJSON('data/dialogue/characters/bf');
		}
		if (rawJson == null)
		{
			Debug.logError('Failed to found ${char}');
			return null;
		}

		return cast rawJson;   
	}

	public function reloadCharacter(json:DialogueCharacterJson) {
		Debug.logTrace('Reloading character');
		frames = Paths.getSparrowAtlas('dialogue/' + json.image);
		reloadAnims(json);

		setGraphicSize(Std.int(width * json.scale * 0.9));
		updateHitbox();

		scrollFactor.set();

		switch (jsonFile.pos)
		{
			case 'right':
				position = RIGHT;
			case 'left':
				position = LEFT;
			case 'middle':
				position = MIDDLE;
		}

		y = DEFAULT_CHAR_Y;

		switch (position)
		{
			case RIGHT:
				x = FlxG.width - width + RIGHT_CHAR_X - offsetPos;

			case LEFT:
				x = LEFT_CHAR_X;

			case MIDDLE:
				x = FlxG.width / 2;
				x -= width / 2;
				y = FlxG.height + 50;
		}

		if (json.portraitX != null)
			x += json.portraitX;

		if (json.portraitY != null)
			y += json.portraitY;

		playAnim(json.startingAnim);
	}

	public function reloadAnims(?json:DialogueCharacterJson)
	{
		var anims = json != null ? json.animations : jsonFile.animations;
		if (anims == null) return;
		for (anim in anims)
		{
			animation.addByPrefix(anim.prefix, anim.idle_name, 24, false);
			animation.addByPrefix(anim.prefix + '-loop', anim.loop_name, 24, false);
			animOffsets.set(anim.prefix, anim.idle_offsets);
			animOffsets.set(anim.prefix + '-loop', anim.loop_offsets);
			animations.set(anim.prefix, anim);
		}
	}

	public function playAnim(?animName:String, ?Force:Bool = false, ?Reversed:Bool = false, ?Frame:Int = 0):Void
	{
		if (animName != null)
		{
			if (animation.getByName(animName) == null)
			{
				#if debug
				Debug.logWarn(['Such animation doesnt exist: ' + animName]);
				#end
				return;
			}

			animation.play(animName, Force, Reversed, Frame);

			curAnim = animName;

			var daOffset = animOffsets.get(animName);
			if (animOffsets.exists(animName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}
		else
		{
			animation.play(animation.getNameList()[0], Force, Reversed, Frame);

			curAnim = animation.getNameList()[0];

			var daOffset = animOffsets.get(animation.getNameList()[0]);
			if (animOffsets.exists(animation.getNameList()[0]))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}	
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (animations.get(curAnim) != null)
		{
			var animTypedef = animations.get(curAnim);
			if (curAnim == animTypedef.prefix && animation.curAnim.finished)
				playAnim(animTypedef.prefix + '-loop');
		}
	}
}

class DialogueBoxSprite extends FlxSprite
{
	public var onAppearCallback:Void->Void;

	public var boxState:DialogueBoxStates = NORMAL;

	var curAnim:String = null;

	/*public function returnBoxState(str:String):DialogueBoxStates
	{
		if (str != null)
		{
			switch (str)
			{
				case 'angry' | 'ANGRY':
					return ANGRY;
				case 'middle' | 'MIDDLE':
					return MIDDLE;
				case 'angry_middle' | 'ANGRY_MIDDLE':
					return ANGRY_MIDDLE;				
			}	
			return NORMAL;
		}
		return NORMAL;
	}

	public function returnStateAnim():String
	{
		switch (boxState)
		{
			case ANGRY:
				return 'angry';
			case MIDDLE:
				return 'center-normal';
			case ANGRY_MIDDLE:
				return 'center-angry';
			default:
				return 'normal';
		}
	}*/

	public function closeBox(){
		switch (boxState)
		{
			case ANGRY:
				playAnim('angryOpen', true, true);
			case MIDDLE:
				playAnim('center-normalOpen', true, true);
			case ANGRY_MIDDLE:
				playAnim('center-angryOpen', true, true);
			default:
				playAnim('normalOpen', true, true);
		}
	}

	public function playAnim(animName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(animName) == null)
		{
			#if debug
			Debug.logWarn(['Such animation doesnt exist: ' + animName]);
			#end
			return;
		}

		animation.play(animName, Force, Reversed, Frame);

		curAnim = animName;
	}

	var openned = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!openned && animation.curAnim.finished)
		{
			switch (boxState)
			{
				case NORMAL:
					playAnim('normal');
				case ANGRY:
					playAnim('angry');
				case MIDDLE:
					playAnim('center-normal');
				case ANGRY_MIDDLE:
					playAnim('center-angry');
			}
			onAppearCallback();
			openned = true;
		}
	}
}

/*enum CharacterPositions {
	RIGHT;
	LEFT;
	MIDDLE;
}

enum DialogueBoxStates {
	NORMAL;
	ANGRY;
	MIDDLE;
	ANGRY_MIDDLE;
}*/

@:enum abstract CharacterPositions(String) from (String) to (String)
{
	var RIGHT = 'right';
	var LEFT = 'left';
	var MIDDLE = 'middle';
}

@:enum abstract DialogueBoxStates(String) from (String) to (String)
{
	var NORMAL = 'normal';
	var ANGRY = 'angry';
	var MIDDLE = 'middle';
	var ANGRY_MIDDLE = 'angry_middle';
}

typedef DialogueJson = {
	var boxType:String;
	var sound:String;
	var dialogue:Array<DialogueLines>;
}

typedef DialogueLines = {
	var character:String;
	var expression:String;
	var line:String;
	var boxState:String;
	var speed:Null<Float>;
	var sound:Null<String>;
}

typedef DialogueBoxJson =
{
	var image:String;
	var scale:Int;
	var textYOffset:Null<Int>;
	var textXOffset:Null<Int>;
	var yOffset:Int;
	var xOffset:Int;
	var anims:Array<DialogueBoxAnims>;
}
typedef DialogueBoxAnims = 
{
	var animName:String;
	var animPrefix:String;
	var animFramerate:Int;
	var isLooped:Bool;
	var animIndices:Array<Int>;
}
typedef DialogueCharacterJson =
{
	var image:String;
	var pos:String;
	var animations:Array<DialogueAnimArrayJson>;
	var startingAnim:String;
	var scale:Int;
	var antialiasing:Bool;
	var ?portraitX:Int;
	var ?portraitY:Int;
}

typedef DialogueAnimArrayJson =
{
	var prefix:String;
	var idle_name:String;
	var idle_offsets:Array<Int>;
	var loop_name:String;
	var loop_offsets:Array<Int>;
}
