package funkin.stages;

import altronixengine.states.GameplayCustomizeState;

class SchoolStage extends BaseStage
{
	var bgGirls:funkin.gameplayStuff.BackgroundGirls;

	override function create()
	{
		super.create();

		var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebSky', 'gameplay'));
		bgSky.scrollFactor.set(0.1, 0.1);
		add(bgSky);

		var repositionShit = -200;

		var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebSchool', 'gameplay'));
		bgSchool.scrollFactor.set(0.6, 0.90);
		add(bgSchool);

		var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebStreet', 'gameplay'));
		bgStreet.scrollFactor.set(0.95, 0.95);
		add(bgStreet);

		var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170,
			130).loadGraphic(Paths.loadImage('weeks/assets/week6/images/weeb/weebTreesBack', 'gameplay'));
		fgTrees.scrollFactor.set(0.9, 0.9);
		add(fgTrees);

		var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		var treetex = Paths.getPackerAtlas('weeks/assets/week6/images/weeb/weebTrees', 'gameplay');
		bgTrees.frames = treetex;
		bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		bgTrees.animation.play('treeLoop');
		bgTrees.scrollFactor.set(0.85, 0.85);
		add(bgTrees);

		var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		treeLeaves.frames = Paths.getSparrowAtlas('weeks/assets/week6/images/weeb/petals', 'gameplay');
		treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		treeLeaves.animation.play('leaves');
		treeLeaves.scrollFactor.set(0.85, 0.85);
		add(treeLeaves);

		bgGirls = new funkin.gameplayStuff.BackgroundGirls(-100, 190);
		bgGirls.scrollFactor.set(0.9, 0.9);

		if (Data.SONG != null)
		{
			if (Data.SONG.scaredbgdancers)
			{
				if (Main.save.data.distractions)
					bgGirls.getScared();
			}
		}
		else if (GameplayCustomizeState.freeplaySong == 'roses')
		{
			if (Main.save.data.distractions)
				bgGirls.getScared();
		}

		bgGirls.setGraphicSize(Std.int(bgGirls.width * CoolUtil.daPixelZoom));
		bgGirls.updateHitbox();
		if (Main.save.data.distractions)
		{
			add(bgGirls);
		}
		if (Data.SONG != null)
		{
			if (Data.SONG.showbgdancers)
			{
				bgGirls.visible = true;
			}
			else
				bgGirls.visible = false;
		}

		var widShit = Std.int(bgSky.width * 6);

		bgSky.setGraphicSize(widShit);
		bgSchool.setGraphicSize(widShit);
		bgStreet.setGraphicSize(widShit);
		bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		treeLeaves.setGraphicSize(widShit);

		fgTrees.updateHitbox();
		bgSky.updateHitbox();
		bgSchool.updateHitbox();
		bgStreet.updateHitbox();
		bgTrees.updateHitbox();
		treeLeaves.updateHitbox();

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
	}

	override function beatHit()
	{
		if (Main.save.data.distractions)
			bgGirls.dance();
	}
}
