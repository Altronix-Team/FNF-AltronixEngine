package;

import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.xml.Access;
import openfl.Lib;
import openfl.utils.Assets;

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

	@:isVar public var size(default, set):Float = 16;

	public var finishedText:Bool = false;

	var textSize:Float = 1.0;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, size:Float = 1, ?typingSpeed:Float = 0.05)
	{
		pastX = x;
		pastY = y;

		super(x, y);

		this.size = size;

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

	public function reType(text, size:Float = 1)
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

		this.size = size;

		addText();
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			var yPos:Float = 0;
			if (character == " " || character == "-")
			{
				lastWasSpace = true;
				yPos += 25 * size;
			}

			var isNumber:Bool = AlphaCharacter.numbers.indexOf(character) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(character) != -1;
			var isAlphabet:Bool = AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1;

			if (lastSprite != null)
			{
				// ThatGuy: This is the line that fixes the spacing error when the x position of this class's objects was anything other than 0
				xPos = lastSprite.x - pastX + lastSprite.width;
			}

			if (lastWasSpace)
			{
				// ThatGuy: Also this line
				xPos += 12 * size;
			}
			var letter:AlphaCharacter = new AlphaCharacter(xPos, yPos);

			// ThatGuy: These are the lines that change the individual scaling of each character
			letter.scale.set(size, size);
			letter.updateHitbox();

			listOAlphabets.add(letter);

			if (character != " " && character != '\n')
			{
				letter.createLetter(character.toLowerCase(), isBold, true);
				/*if (isAlphabet)
					{
						if (isBold)
							letter.createBold(character.toLowerCase());
						else
						{
							letter.createLetter(character.toLowerCase());
						}
					}
					else if (isNumber)
						letter.createNumber(character);
					else
						letter.createSymbol(character); */
			}
			else
			{
				letter.createLetter('#', false, false);
				letter.visible = false;
				lastWasSpace = false;
			}

			add(letter);

			lastSprite = letter;

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

	var consecutiveSpaces:Int = 0;

	var typeTimer:FlxTimer = null;
	var xPos:Float = 0;

	public function startTypedText(speed:Float):Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		if (speed <= 0)
		{
			while (!finishedText)
			{
				timerCheck();
			}
		}
		else
		{
			typeTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				typeTimer = new FlxTimer().start(speed, function(tmr:FlxTimer)
				{
					timerCheck(tmr);
				}, 0);
			});
		}
	}

	var LONG_TEXT_ADD:Float = -24; // text is over 2 rows long, make it go up a bit

	public function timerCheck(?tmr:FlxTimer = null)
	{
		var autoBreak:Bool = false;
		if ((loopNum <= splitWords.length - 2 && splitWords[loopNum] == "\\" && splitWords[loopNum + 1] == "n")
			|| ((autoBreak = true) && xPos >= FlxG.width * 0.65 && splitWords[loopNum] == ' '))
		{
			if (autoBreak)
			{
				if (tmr != null)
					tmr.loops -= 1;
				loopNum += 1;
			}
			else
			{
				if (tmr != null)
					tmr.loops -= 2;
				loopNum += 2;
			}
			yMulti += 1;
			xPosResetted = true;
			xPos = 0;
			curRow += 1;
			if (curRow == 2)
				y += LONG_TEXT_ADD;
		}

		if (loopNum <= splitWords.length && splitWords[loopNum] != null)
		{
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

				letter.createLetter(splitWords[loopNum].toLowerCase(), isBold, true);

				/*if (isNumber)
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
				}*/

				letter.x += 90;

				add(letter);

				lastSprite = letter;
			}
		}

		loopNum++;
		if (loopNum >= splitWords.length)
		{
			if (tmr != null)
			{
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

	public function killTheTimer()
	{
		if (typeTimer != null)
		{
			typeTimer.cancel();
			typeTimer.destroy();
		}
		typeTimer = null;
	}

	// ThatGuy: Ooga booga function for resizing text, with the option of wanting it to have the same midPoint
	// Side note: Do not, EVER, do updateHitbox() unless you are retyping the whole thing. Don't know why, but the position gets retarded if you do that
	public function resizeText(size:Float, xStaysCentered:Bool = true, yStaysCentered:Bool = false):Void
	{
		var oldMidpoint:FlxPoint = this.getMidpoint();
		reType(text, size);
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
		this.x = midpoint.x - this.width / 2;
		this.y = midpoint.y - this.height / 2;
	}

	function set_size(value:Float):Float
	{
		if (value < 0)
			return size;
		size = value;
		if (finishedText)
			resizeText(size);
		return value;
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!? /\\";

	public static var letters:Map<String, Letter> = [
		'a' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'b' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'c' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'd' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'e' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'f' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'g' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'h' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'i' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'j' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'k' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'l' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'm' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'n' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'o' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'p' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'q' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'r' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		's' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		't' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'u' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'v' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'w' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'x' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'y' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'z' => {anim: null, states: [BOLD, LOWERCASE, UPPERCASE]},
		'0' => {anim: null, states: [BOLD, NORMAL]},
		'1' => {anim: null, states: [BOLD, NORMAL]},
		'2' => {anim: null, states: [BOLD, NORMAL]},
		'3' => {anim: null, states: [BOLD, NORMAL]},
		'4' => {anim: null, states: [BOLD, NORMAL]},
		'5' => {anim: null, states: [BOLD, NORMAL]},
		'6' => {anim: null, states: [BOLD, NORMAL]},
		'7' => {anim: null, states: [BOLD, NORMAL]},
		'8' => {anim: null, states: [BOLD, NORMAL]},
		'9' => {anim: null, states: [BOLD, NORMAL]},
		'&' => {anim: null, states: [BOLD, NORMAL]},
		'(' => {anim: null, states: [BOLD, NORMAL]},
		')' => {anim: null, states: [BOLD, NORMAL]},
		'*' => {anim: null, states: [BOLD, NORMAL]},
		'+' => {anim: null, states: [BOLD, NORMAL]},
		'-' => {anim: null, states: [BOLD, NORMAL]},
		'<' => {anim: null, states: [BOLD, NORMAL]},
		'>' => {anim: null, states: [BOLD, NORMAL]},
		'\'' => {anim: 'apostrophe', states: [BOLD, NORMAL]},
		'"' => {anim: 'quote', states: [BOLD, NORMAL]},
		'!' => {anim: 'exclamation', states: [BOLD, NORMAL]},
		'?' => {anim: 'question', states: [BOLD, NORMAL]},
		'.' => {anim: 'period', states: [BOLD, NORMAL]},
		'❝' => {anim: 'start quote', states: [BOLD, NORMAL]},
		'❞' => {anim: 'end quote', states: [BOLD, NORMAL]},
		'_' => {anim: null, states: [NORMAL]},
		'#' => {anim: null, states: [NORMAL]},
		'$' => {anim: null, states: [NORMAL]},
		'%' => {anim: null, states: [NORMAL]},
		':' => {anim: null, states: [NORMAL]},
		';' => {anim: null, states: [NORMAL]},
		'@' => {anim: null, states: [NORMAL]},
		'[' => {anim: null, states: [NORMAL]},
		']' => {anim: null, states: [NORMAL]},
		'^' => {anim: null, states: [NORMAL]},
		',' => {anim: 'comma', states: [NORMAL]},
		'\\' => {anim: 'back slash', states: [NORMAL]},
		'/' => {anim: 'forward slash', states: [NORMAL]},
		'|' => {anim: null, states: [NORMAL]},
		'~' => {anim: null, states: [NORMAL]}
	];

	public var row:Int = 0;

	public var textSize(default, set):Float = 1;

	public function new(x:Float, y:Float, ?textSize:Float = 1)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('alphabet', 'core');
		this.textSize = textSize;
		if (Main.save.data.antialiasing)
		{
			antialiasing = true;
		}
	}

	public function createLetter(letter:String, isBold:Bool = true, Uppercase:Bool = false)
	{
		if (letter == "")
			return;
		if (isBold && safeStateCheck(letter, BOLD))
		{
			var anim = safeGetAnim(letter);
			animation.addByPrefix(letter, anim + " bold instance 1", 24);
			animation.play(letter);
			animation.curAnim.frameRate = 24 * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
			updateHitbox();
		}
		else
		{
			if (Uppercase && safeStateCheck(letter, UPPERCASE))
			{
				var anim = safeGetAnim(letter);
				animation.addByPrefix(letter, anim + " uppercase instance 1", 24);
				animation.play(letter);
				updateHitbox();

				y = (110 - height);
				y += row * 60;
			}
			else if (safeStateCheck(letter, LOWERCASE))
			{
				var anim = safeGetAnim(letter);
				animation.addByPrefix(letter, anim + " lowercase instance 1", 24);
				animation.play(letter);
				updateHitbox();

				y = (110 - height);
				y += row * 60;
			}
			else if (safeStateCheck(letter, NORMAL))
			{
				var anim = safeGetAnim(letter);
				animation.addByPrefix(letter, anim + ' normal instance 1', 24);
				animation.play(letter);
				if (letter == '.' || letter == '_')
					y += 50;
			}
			else
				return;
		}
	}

	private function safeGetAnim(letter:String):String {
		var anim = letter;
		if (AlphaCharacter.letters.get(letter) != null)
			if (AlphaCharacter.letters.get(letter).anim != null)
				return AlphaCharacter.letters.get(letter).anim;
			else
				return anim;
		else
			return anim;
	}

	private function safeStateCheck(letter:String, state:AlphaCharacterStates):Bool
	{
		try
		{
			var let:Letter = {
				anim: letter,
				states: [NORMAL]
			};
			if (AlphaCharacter.letters.get(letter) != null)
				let = AlphaCharacter.letters.get(letter);
			return let.states.contains(state);
		}
		catch (e)
		{
			Debug.logError(e.details());
			return false;
		}
	}

	function set_textSize(value:Float):Float
	{
		textSize = value;
		scale.set(textSize, textSize);
		return value;
	}
}

typedef Letter =
{
	var anim:Null<String>;
	var states:Array<AlphaCharacterStates>;
}

enum abstract AlphaCharacterStates(String) from String to String
{
	var BOLD = 'bold';
	var UPPERCASE = 'uppercase';
	var LOWERCASE = 'lowercase';
	var NORMAL = 'normal';
}
