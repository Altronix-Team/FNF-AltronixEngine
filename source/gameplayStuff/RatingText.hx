package gameplayStuff;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import states.playState.PlayState;
import states.playState.GameData as Data;

@:access(states.PlayState)
class RatingText extends FlxTypedGroup<FlxText>
{
	public var accuracyText:FlxText = new FlxText();
	public var missesText:FlxText = new FlxText();
	public var scoreText:FlxText = new FlxText();

	public var x(default, set):Float = 0;

	public var y(default, set):Float = 0;

	public var alpha(default, set):Float = 1.0;

	@:isVar
	public var width(get, null):Float;

	@:isVar
	public var height(get, null):Float;

	public var text(get, null):String;

	private var textColor(default, set):FlxColor = FlxColor.WHITE;

	private var missColorTween:FlxTween;

	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;

		add(scoreText);
		add(missesText);
		add(accuracyText);

		forEach(function(text:FlxText)
		{
			text.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.cameras = [PlayState.instance.camHUD];
		});

		updateTexts();

		updateTextsYPos(y);
	}

	public function updateTexts()
	{
		scoreText.text = '${LanguageStuff.replaceFlagsAndReturn("$Score_Text", "playState", ['<text>'], [PlayState.instance.songScore])} | ';

		missesText.text = '${LanguageStuff.replaceFlagsAndReturn("$Misses_Text", "playState", ['<text>'], [Data.misses])} | ';

		accuracyText.text = '${LanguageStuff.replaceFlagsAndReturn("$Accuracy_Text", "playState", ['<text>'], [CoolUtil.truncateFloat(PlayState.instance.accuracy, 2)])}'
			+ (PlayState.instance.accuracy > 0 ? ' | ${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}' : '');

		updateTextsXPos(x);

		if (textColor != getTextColor(PlayState.instance.accuracy) && PlayState.instance.accuracy > 0)
			textColor = getTextColor(PlayState.instance.accuracy);
	}

	public function updateTextsXPos(leftX:Float)
	{
		scoreText.x = leftX;
		missesText.x = scoreText.x + scoreText.width;
		accuracyText.x = missesText.x + missesText.width;
	}

	public function updateTextsYPos(yPos:Float)
	{
		forEach(function(text:FlxText)
		{
			text.y = yPos;
		});
	}

	public function onMiss()
	{
		missColorTween = FlxTween.tween(missesText, {color: FlxColor.RED}, 0.1, {
			onComplete: function(twn:FlxTween)
			{
				missColorTween = FlxTween.tween(missesText, {color: textColor}, 0.1, {
					onComplete: function(twn:FlxTween)
					{
						missColorTween = null;
					}
				});
			}
		});
	}

	private function getTextColor(accuracy:Float):FlxColor
	{
		var wifeConditions:Array<Bool> = [
			accuracy >= 80, // A - AAAAA
			accuracy >= 70, // B - A
			accuracy >= 60, // D - C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						return FlxColor.fromString('0xFFD700');
					case 1:
						return FlxColor.fromString('0xADFF2F');
					case 2:
						return FlxColor.fromString('0xFF4500');
					case 3:
						return FlxColor.fromString('0x8B0000');
				}
				break;
			}
		}
		return FlxColor.WHITE;
	}

	function set_y(value:Float):Float
	{
		y = value;
		updateTextsYPos(value);
		return value;
	}

	function set_alpha(value:Float):Float
	{
		alpha = value;
		forEach(function(text:FlxText)
		{
			text.alpha = value;
		});
		return value;
	}

	public inline function screenCenter(axes:FlxAxes = XY):RatingText
	{
		#if (flixel < "5.0.0")
		if (axes.match(X | XY))
			x = (FlxG.width - width) / 2;

		if (axes.match(Y | XY))
			y = (FlxG.height - height) / 2;

		return this;
		#else
		if (axes.x)
			x = (FlxG.width - width) / 2;

		if (axes.y)
			y = (FlxG.height - height) / 2;

		return this;
		#end
	}

	function get_text():String
	{
		var retVal:String = '';
		forEach(function(text:FlxText)
		{
			retVal += text.text;
		});
		return retVal;
	}

	function get_width():Float
	{
		var returnVal:Float = 0;
		forEach(function(text:FlxText)
		{
			returnVal += text.width;
		});
		return returnVal;
	}

	function get_height():Float
	{
		return members[0].height; // all texts has same height lol
	}

	function set_x(value:Float):Float
	{
		x = value;
		updateTextsXPos(value);
		return value;
	}

	function set_textColor(value:FlxColor):FlxColor
	{
		textColor = value;
		forEach(function(text:FlxText)
		{
			if (text.text.contains('Misses') && missColorTween != null)
			{
				if (!missColorTween.active)
					text.color = value;
			}
			else
				text.color = value;
		});
		return value;
	}
}
