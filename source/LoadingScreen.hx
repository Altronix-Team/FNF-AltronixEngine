package;

import gameplayStuff.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import flixel.text.FlxText;

class LoadingScreen extends states.MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var loadingart:FlxSprite;
	var logoBl:FlxSprite;
	public var instantAlpha:Bool = false;
	var bar:FlxBar;
	var toBeDone = 0;
	var text:FlxText;

	public function new(toBeDone:Int = 1) {
		super();
		this.toBeDone = toBeDone;
		FlxG.camera.zoom = 0;
		loadingart = new FlxSprite(0, 0).loadGraphic(Paths.loadImage('limo/limoSunset', 'week4'));
		loadingart.screenCenter();
		loadingart.scrollFactor.set();
		loadingart.antialiasing = FlxG.save.data.antialiasing;

		add(loadingart);

		if (Main.watermarks)
			{
				logoBl = new FlxSprite(-10, 0);
				logoBl.frames = Paths.getSparrowAtlas('altronixenginelogobumpin');
			}
			else
			{
				logoBl = new FlxSprite(-150, 0);
				logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			}
			logoBl.antialiasing = FlxG.save.data.antialiasing;
			logoBl.scrollFactor.set();
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.updateHitbox();

		add(logoBl);

		bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.createGradientFilledBar([FlxColor.fromRGB(226, 0, 255, 255), FlxColor.fromRGB(0, 254, 255, 255), FlxColor.fromRGB(0, 255, 166, 255),  FlxColor.fromRGB(224, 255, 0, 255)]);
		bar.visible = true;
		bar.scrollFactor.set();

		add(bar);

		text = new FlxText(FlxG.width / 2, FlxG.height - 50, 0, "Loading");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.font = 'Pixel Arial 11 Bold';
		text.scrollFactor.set();

		add(text);

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		bar.value += 0.01;

		if (bar.value == 1)
			finishCallback();
	}
}