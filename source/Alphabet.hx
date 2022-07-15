package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flash.media.Sound;
import openfl.Lib;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var listOAlphabets:List<AlphaCharacter> = new List<AlphaCharacter>();

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	var pastX:Float = 0;
	var pastY:Float = 0;

	// ThatGuy: Variables here to be used later
	var xScale:Float;
	var yScale:Float;

	public var finishedText:Bool = false;
	var textSize:Float = 1.0;

	// ThatGuy: Added 2 more variables, xScale and yScale for resizing text
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, shouldMove:Bool = false, xScale:Float = 1,
			yScale:Float = 1, ?typingSpeed:Float = 0.05)
	{
		pastX = x;
		pastY = y;

		// ThatGuy: Have to assign these variables
		this.xScale = xScale;
		this.yScale = yScale;

		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText(typingSpeed);
			}
			else
			{
				addText();
			}
		}
		else
			finishedText = false;
	}

	public function reType(text, xScale:Float = 1, yScale:Float = 1)
	{
		for (i in listOAlphabets)
			remove(i);
		_finalText = text;
		this.text = text;

		lastSprite = null;

		updateHitbox();

		listOAlphabets.clear();
		x = pastX;
		y = pastY;

		this.xScale = xScale;
		this.yScale = yScale;

		addText();
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1)
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
				if (lastSprite != null)
				{
					// ThatGuy: This is the line that fixes the spacing error when the x position of this class's objects was anything other than 0
					xPos = lastSprite.x - pastX + lastSprite.width;
				}

				if (lastWasSpace)
				{
					// ThatGuy: Also this line
					xPos += 40 * xScale;
					lastWasSpace = false;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);

				// ThatGuy: These are the lines that change the individual scaling of each character
				letter.scale.set(xScale, yScale);
				letter.updateHitbox();

				listOAlphabets.add(letter);

				if (isBold)
					letter.createBold(character);
				else
				{
					letter.createLetter(character);
				}

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	var loopNum:Int = 0;
	public var curRow:Int = 0;
	var dialogueSound:FlxSound = null;
	private static var soundDialog:Sound = null;
	var consecutiveSpaces:Int = 0;

	public static function setDialogueSound(name:String = '')
		{
			if (name == null || name.trim() == '') name = 'dialogue';
			soundDialog = Paths.dialogueSound(name);
			if(soundDialog == null) soundDialog = Paths.dialogueSound('dialogue');
		}

	var typeTimer:FlxTimer = null;
	var xPos:Float = 0;

	public function startTypedText(speed:Float):Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		if(soundDialog == null)
		{
			Alphabet.setDialogueSound();
		}

		if(speed <= 0) {
			while(!finishedText) { 
				timerCheck();
			}
			if(dialogueSound != null) dialogueSound.stop();
			dialogueSound = FlxG.sound.play(soundDialog);
		} else {
			typeTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				typeTimer = new FlxTimer().start(speed, function(tmr:FlxTimer) {
					timerCheck(tmr);
				}, 0);
			});
		}
	}

	var LONG_TEXT_ADD:Float = -24; //text is over 2 rows long, make it go up a bit
	public function timerCheck(?tmr:FlxTimer = null) {
		var autoBreak:Bool = false;
		if ((loopNum <= splitWords.length - 2 && splitWords[loopNum] == "\\" && splitWords[loopNum+1] == "n") ||
			((autoBreak = true) && xPos >= FlxG.width * 0.65 && splitWords[loopNum] == ' ' ))
		{
			if(autoBreak) {
				if(tmr != null) tmr.loops -= 1;
				loopNum += 1;
			} else {
				if(tmr != null) tmr.loops -= 2;
				loopNum += 2;
			}
			yMulti += 1;
			xPosResetted = true;
			xPos = 0;
			curRow += 1;
			if(curRow == 2) y += LONG_TEXT_ADD;
		}

		if(loopNum <= splitWords.length && splitWords[loopNum] != null) {
			var spaceChar:Bool = (splitWords[loopNum] == " " || (isBold && splitWords[loopNum] == "_"));
			if (spaceChar)
			{
				consecutiveSpaces++;
			}

			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			var isAlphabet:Bool = AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1;

			if ((isAlphabet || isSymbol || isNumber) && (!isBold || !spaceChar))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (consecutiveSpaces > 0)
				{
					xPos += 20 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0, textSize);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				letter.row = curRow;
				
				if (isNumber)
				{
					letter.createNumber(splitWords[loopNum]);
				}
				else if (isSymbol)
				{
					letter.createSymbol(splitWords[loopNum]);
				}
				else
				{
					letter.createLetter(splitWords[loopNum]);
				}
				
				letter.x += 90;

				if(tmr != null) {
					if(dialogueSound != null) dialogueSound.stop();
					dialogueSound = FlxG.sound.play(soundDialog);
				}

				add(letter);

				lastSprite = letter;
			}
		}

		loopNum++;
		if(loopNum >= splitWords.length) {
			if(tmr != null) {
				typeTimer = null;
				tmr.cancel();
				tmr.destroy();
			}
			finishedText = true;
		}
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48) + yAdd, 0.30);
			x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, 0.30);
		}

		super.update(elapsed);
	}

	public function killTheTimer() {
		if(typeTimer != null) {
			typeTimer.cancel();
			typeTimer.destroy();
		}
		typeTimer = null;
	}

	// ThatGuy: Ooga booga function for resizing text, with the option of wanting it to have the same midPoint
	// Side note: Do not, EVER, do updateHitbox() unless you are retyping the whole thing. Don't know why, but the position gets retarded if you do that
	public function resizeText(xScale:Float, yScale:Float, xStaysCentered:Bool = true, yStaysCentered:Bool = false):Void
	{
		var oldMidpoint:FlxPoint = this.getMidpoint();
		reType(text, xScale, yScale);
		if (!(xStaysCentered && yStaysCentered))
		{
			if (xStaysCentered)
			{
				// I can just use this juicy new function i made
				moveTextToMidpoint(new FlxPoint(oldMidpoint.x, getMidpoint().y));
			}
			if (yStaysCentered)
			{
				moveTextToMidpoint(new FlxPoint(getMidpoint().x, oldMidpoint.y));
			}
		}
		else
		{
			moveTextToMidpoint(new FlxPoint(oldMidpoint.x, oldMidpoint.y));
		}
	}

	// ThatGuy: Function used to keep text centered on one point instead of manually having to come up with offsets for each sentence
	public function moveTextToMidpoint(midpoint:FlxPoint):Void
	{
		/*
			e.g. You want your midpoint at (100, 100)
			and your text is 200 wide, 50 tall
			then, x = 100 - 200/2, y = 100 - 50/2
		 */
		this.x = midpoint.x - this.width / 2;
		this.y = midpoint.y - this.height / 2;
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? ";

	public var row:Int = 0;

	private var textSize:Float = 1;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;
		if (FlxG.save.data.antialiasing)
		{
			antialiasing = true;
		}
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		animation.curAnim.frameRate = 24 * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			case '_':
				animation.addByPrefix(letter, '_', 24);
				animation.play(letter);
				y += 50;
			case "#":
				animation.addByPrefix(letter, '#', 24);
				animation.play(letter);
			case "$":
				animation.addByPrefix(letter, '$', 24);
				animation.play(letter);
			case "%":
				animation.addByPrefix(letter, '%', 24);
				animation.play(letter);
			case "&":
				animation.addByPrefix(letter, '&', 24);
				animation.play(letter);
			case "(":
				animation.addByPrefix(letter, '(', 24);
				animation.play(letter);
			case ")":
				animation.addByPrefix(letter, ')', 24);
				animation.play(letter);
			case "+":
				animation.addByPrefix(letter, '+', 24);
				animation.play(letter);
			case "-":
				animation.addByPrefix(letter, '-', 24);
				animation.play(letter);
			case '"':
				animation.addByPrefix(letter, '"', 24);
				animation.play(letter);
				y -= 0;
			case '@':
				animation.addByPrefix(letter, '@', 24);
				animation.play(letter);
			case "^":
				animation.addByPrefix(letter, '^', 24);
				animation.play(letter);
				y -= 0;
			case ' ':
				animation.addByPrefix(letter, 'space', 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
