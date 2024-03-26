package funkin.stages;

import altronixengine.gameplayStuff.PlayStateChangeables;
import altronixengine.shaders.WiggleEffect;

class SchoolEvilStage extends BaseStage
{
	var wiggleShit:WiggleEffect;

	override function create()
	{
		var posX = 400;
		var posY = 200;

		var bg:FlxSprite = new FlxSprite(posX + 10, posY + 165).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/evilSchoolBG', 'gameplay'));
		bg.scale.set(6, 6);
		add(bg);

		var fg:FlxSprite = new FlxSprite(posX + 10, posY + 165).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/evilSchoolFG', 'gameplay'));
		fg.scale.set(6, 6);
		add(fg);

		var effectType:Array<String> = ['DREAMY', 'WAVY', 'HEAT_WAVE_HORIZONTAL', 'HEAT_WAVE_VERTICAL', 'FLAG'];

		wiggleShit = new WiggleEffect(effectType[FlxG.random.int(0, effectType.length - 1)], 0.8, 60, 0.01);

		if (Main.save.data.distractions)
		{
			if (!PlayStateChangeables.Optimize)
			{
				bg.shader = wiggleShit.shader;
				fg.shader = wiggleShit.shader;
			}
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		wiggleShit.update(elapsed);
	}
}
