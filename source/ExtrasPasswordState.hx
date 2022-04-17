package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flash.text.TextField;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;


class ExtrasPasswordState extends MusicBeatState
{
    public static var extra:Int = 1;
	var passwordText:FlxInputText;
	var bg:FlxSprite;
	var mistakebg:FlxSprite;

	override function create()
	{
        bg = new FlxSprite(-100).loadGraphic(Paths.loadImage('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.color = FlxColor.WHITE;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		mistakebg = new FlxSprite(-100).loadGraphic(Paths.loadImage('menuDesat'));
		mistakebg.scrollFactor.x = 0;
		mistakebg.scrollFactor.y = 0.10;
		mistakebg.color = FlxColor.RED;
		mistakebg.setGraphicSize(Std.int(mistakebg.width * 1.1));
		mistakebg.updateHitbox();
		mistakebg.screenCenter();
		mistakebg.visible = false;
		mistakebg.antialiasing = FlxG.save.data.antialiasing;
		add(mistakebg);

		var blackScreen:FlxSprite = new FlxSprite(-200, -100).makeGraphic(Std.int(FlxG.width * 0.5), Std.int(FlxG.height * 0.5), FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.scrollFactor.set(0, 0);
		add(blackScreen);

		var enterText:FlxText = new FlxText(0, 0, 0, "Enter Password:", 48);
		enterText.setFormat('Pixel Arial 11 Bold', 48, FlxColor.WHITE, CENTER);
		enterText.screenCenter();
		enterText.y -= 40;
		enterText.scrollFactor.set(0, 0);
		add(enterText);

		var hintText:FlxText = new FlxText(0, 0, 0, "You can find it in game files", 24);
		hintText.setFormat('Pixel Arial 11 Bold', 24, FlxColor.WHITE, CENTER);
		hintText.screenCenter();
		hintText.y = enterText.y + 80;
		hintText.scrollFactor.set(0, 0);
		add(hintText);

		passwordText = new FlxInputText(0, 300, 550, '', 36, FlxColor.WHITE, FlxColor.BLACK);
		passwordText.fieldBorderColor = FlxColor.WHITE;
		passwordText.fieldBorderThickness = 3;
		passwordText.maxLength = 20;
		passwordText.screenCenter(X);
		passwordText.y += 120;
		passwordText.scrollFactor.set(0, 0);
		passwordText.hasFocus = true;
		add(passwordText);

		trace('checking password');
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
            checkpassword(passwordText.text);
        if (controls.BACK)
            FlxG.switchState(new MainMenuState());
	}

    function checkpassword(?passwordText:String)
		{
			if (passwordText == 'tankman')
			{
				extra = 2;
				FlxG.sound.music.stop();
				FlxG.switchState(new SecretState());
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
				Main.isHidden = true;
			}
			else if (passwordText == 'debug')
			{
				extra = 3;
				FlxG.sound.music.stop();
				FlxG.switchState(new SecretState());
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
				Main.isHidden = true;
			}
			else if (passwordText != 'tankman' || passwordText != 'debug')
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'));
				if (FlxG.save.data.flashing)
					FlxFlicker.flicker(mistakebg, 1.1, 0.15, false);
			}
		}
}