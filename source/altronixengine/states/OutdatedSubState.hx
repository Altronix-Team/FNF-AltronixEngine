package altronixengine.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var currChanges:String = "dk";

	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('week54prototype', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		bg.antialiasing = Main.save.data.antialiasing;
		add(bg);

		var engineLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.loadImage('enginelogo'));
		engineLogo.scale.y = 0.3;
		engineLogo.scale.x = 0.3;
		engineLogo.x -= engineLogo.frameHeight;
		engineLogo.y -= 180;
		engineLogo.alpha = 0.8;
		engineLogo.antialiasing = Main.save.data.antialiasing;
		add(engineLogo);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Your Altronix Engine is outdated!\nYou are on "
			+ EngineConstants.engineVer
			+ "\nwhile the most recent version is "
			+ needVer
			+ "."
			+ "\n\nWhat's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this",
			32);

		if (MainMenuState.nightly != "")
			txt.text = "You are on\n"
				+ EngineConstants.engineVer
				+ "\nWhich is a PRE-RELEASE BUILD!"
				+ "\n\nReport all bugs to the author of the pre-release.\nSpace/Escape ignores this.";

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		FlxTween.angle(engineLogo, engineLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (engineLogo.angle == -10)
				FlxTween.angle(engineLogo, engineLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(engineLogo, engineLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if (engineLogo.alpha == 0.8)
				FlxTween.tween(engineLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else
				FlxTween.tween(engineLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && MainMenuState.nightly == "")
		{
			fancyOpenURL("https://raw.githubusercontent.com/AltronMaxX/FNF-AltronixEngine/main/version.downloadMe?token=GHSAT0AAAAAABHIQ6SZHCZMPE7ZJ2IOMUQUYUNAMMQ");
		}
		else if (controls.ACCEPT)
		{
			leftState = true;
			MusicBeatState.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			leftState = true;
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
