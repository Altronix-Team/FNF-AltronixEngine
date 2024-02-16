package altronixengine.gameplayStuff;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIBar;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import altronixengine.states.playState.GameData as Data;
import altronixengine.states.playState.PlayState;

@:access(altronixengine.states.playState.PlayState)
class GameUI extends FlxTypedGroup<FlxBasic>
{
	var state:PlayState;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxUIBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var songScoreDef:Int = 0;
	public var scoreTxt:RatingText;
	public var judgementCounter:FlxText;

	// Two players mode stuff
	public var scoreP1:FlxText;
	public var scoreP2:FlxText;
	public var intScoreP1:Int = 0;
	public var intScoreP2:Int = 0;

	public var engineWatermark:FlxText;

	public var funnyStartObjects:Array<FlxBasic> = [];

	public var chartingState:FlxText;
	public var botPlayState:FlxText;

	public function new(state:PlayState, camHUD:FlxCamera)
	{
		super();

		this.state = state;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		FlxSpriteUtil.drawRect(healthBarBG, 0, 0, healthBarBG.width, healthBarBG.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});
		if (state.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (Data.isStoryMode)
		{
			healthBarBG.alpha = 0;
			funnyStartObjects.push(healthBarBG);
		}

		healthBar = new FlxUIBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.percent = 50;
		healthBar.scrollFactor.set();
		if (Data.isStoryMode)
		{
			healthBar.alpha = 0;
			funnyStartObjects.push(healthBar);
		}
		reloadHealthBarColors();

		engineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			Data.SONG.songName
			+ (FlxMath.roundDecimal(Data.songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(Data.songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(Data.storyDifficulty),
			16);
		engineWatermark.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWatermark.scrollFactor.set();
		add(engineWatermark);
		if (Data.isStoryMode)
		{
			engineWatermark.alpha = 0;
			funnyStartObjects.push(engineWatermark);
		}

		if (state.useDownscroll)
			engineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new RatingText(FlxG.width / 2 - 235, FlxG.height * 0.9 + 50 /*, 0, "", 20*/);
		scoreTxt.screenCenter(X);

		if (Data.isStoryMode)
		{
			scoreTxt.alpha = 0;
			funnyStartObjects.push(scoreTxt);
		}

		if (!Main.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		scoreP1 = new FlxText(755, healthBarBG.y + 50, 0, 'Player 1 score: ' + Std.string(intScoreP1), 20);
		scoreP1.scrollFactor.set();
		scoreP1.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		scoreP2 = new FlxText(400, healthBarBG.y + 50, 0, 'Player 2 score: ' + Std.string(intScoreP2), 20);
		scoreP2.scrollFactor.set();
		scoreP2.setFormat(Paths.font(LanguageStuff.fontName), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font(LanguageStuff.fontName), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${Data.sicks}\nGoods: ${Data.goods}\nBads: ${Data.bads}\nShits: ${Data.shits}\nMisses: ${Data.misses}';
		if (Main.save.data.judgementCounter)
		{
			add(judgementCounter);

			if (Data.isStoryMode)
			{
				judgementCounter.alpha = 0;
				funnyStartObjects.push(judgementCounter);
			}
		}

		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (state.useDownscroll ? 100 : -100), 0,
			LanguageStuff.getPlayState("$BOTPLAY"), 20);
		botPlayState.setFormat(Paths.font(LanguageStuff.fontName), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !Data.chartingMode)
			add(botPlayState);

		if (Data.isStoryMode)
		{
			botPlayState.alpha = 0;
			funnyStartObjects.push(botPlayState);
		}

		state.addedBotplay = PlayStateChangeables.botPlay;

		chartingState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (state.useDownscroll ? 100 : -100), 0,
			LanguageStuff.getPlayState("$CHARTING"), 20);
		chartingState.setFormat(Paths.font(LanguageStuff.fontName), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		chartingState.scrollFactor.set();
		chartingState.borderSize = 4;
		chartingState.borderQuality = 2;
		chartingState.cameras = [camHUD];
		if (Data.chartingMode)
			add(chartingState);

		if (Data.isStoryMode)
		{
			chartingState.alpha = 0;
			funnyStartObjects.push(chartingState);
		}

		iconP1 = new HealthIcon(Data.SONG.player1, CharactersStuff.getCharacterIcon(Data.SONG.player1), true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		if (Data.isStoryMode)
		{
			iconP1.alpha = 0;
			funnyStartObjects.push(iconP1);
		}

		iconP2 = new HealthIcon(Data.SONG.player2, CharactersStuff.getCharacterIcon(Data.SONG.player2), false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (Data.isStoryMode)
		{
			iconP2.alpha = 0;
			funnyStartObjects.push(iconP2);
		}

		if (Main.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
		}
		if (!PlayStateChangeables.twoPlayersMode)
			add(scoreTxt);
		else
		{
			add(scoreP1);
			add(scoreP2);
		}

		if (!PlayStateChangeables.botPlay)
			add(state.ratingsGroup);

		state.strumLineNotes.cameras = [camHUD];
		state.notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		scoreP1.cameras = [camHUD];
		scoreP2.cameras = [camHUD];
		state.laneunderlay.cameras = [camHUD];
		state.laneunderlayOpponent.cameras = [camHUD];

		if (Data.isStoryMode)
			if (PlayState.instance.doof != null)
				PlayState.instance.doof.cameras = [camHUD];
		engineWatermark.cameras = [camHUD];
	}

	override public function update(elapsed:Float)
	{
		healthBar.percent = state.health * 50;

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 20)
		{
			/*if (iconP1.nearToDieAnim != null)
					iconP1.animation.play(iconP1.nearToDieAnim);
				else */
			iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			/*if (iconP1.defaultAnim != null)
					iconP1.animation.play(iconP1.defaultAnim);
				else */
			iconP1.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent > 80)
		{
			/*if (iconP2.nearToDieAnim != null)
					iconP2.animation.play(iconP2.nearToDieAnim);
				else */
			iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			/*if (iconP2.defaultAnim != null)
					iconP2.animation.play(iconP2.defaultAnim);
				else */
			iconP2.animation.curAnim.curFrame = 0;
		}
		super.update(elapsed);
	}

	public function reloadHealthBarColors()
	{
		if (Main.save.data.colour)
		{
			healthBar.createFilledBar(FlxColor.fromRGB(state.dad.healthColorArray[0], state.dad.healthColorArray[1], state.dad.healthColorArray[2]),
				FlxColor.fromRGB(state.boyfriend.healthColorArray[0], state.boyfriend.healthColorArray[1], state.boyfriend.healthColorArray[2]));
		}
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);

		healthBar.updateBar();
	}
}
