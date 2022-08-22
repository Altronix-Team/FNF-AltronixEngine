import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;
import states.StoryMenuState;
import gameplayStuff.Conductor;

class EngineData
{
	public static function initSave()
	{
		if (FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 7;

		if (FlxG.save.data.caching == null)
			FlxG.save.data.caching = true;

		if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;
		
		if (FlxG.save.data.toggleLeaderboard == null)
			FlxG.save.data.toggleLeaderboard = true;
		
		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 340 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.colour == null)
			FlxG.save.data.colour = true;

		if (FlxG.save.data.stepMania == null)
			FlxG.save.data.stepMania = false;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;

		if (FlxG.save.data.InstantRespawn == null)
			FlxG.save.data.InstantRespawn = false;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;
		
		if (FlxG.save.data.savedAchievements == null)
			FlxG.save.data.savedAchievements = [];

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;

		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.inputShow == null)
			FlxG.save.data.inputShow = false;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;

		FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = false;

		if (FlxG.save.data.editorBG == null)
			FlxG.save.data.editorBG = false;

		if (FlxG.save.data.zoom == null)
			FlxG.save.data.zoom = 1;

		if (FlxG.save.data.judgementCounter == null)
			FlxG.save.data.judgementCounter = true;

		if (FlxG.save.data.laneUnderlay == null)
			FlxG.save.data.laneUnderlay = true;

		if (FlxG.save.data.healthBar == null)
			FlxG.save.data.healthBar = true;

		if (FlxG.save.data.fullscreenOnStart == null)
			FlxG.save.data.fullscreenOnStart = false;

		if (FlxG.save.data.laneTransparency == null)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.shitMs == null)
			FlxG.save.data.shitMs = 160.0;

		if (FlxG.save.data.badMs == null)
			FlxG.save.data.badMs = 135.0;

		if (FlxG.save.data.goodMs == null)
			FlxG.save.data.goodMs = 90.0;

		if (FlxG.save.data.sickMs == null)
			FlxG.save.data.sickMs = 45.0;

		if (FlxG.save.data.notesplashes == null)
			FlxG.save.data.notesplashes = true;

		if (FlxG.save.data.enablePsychInterface == null)
			FlxG.save.data.enablePsychInterface = false;

		if (FlxG.save.data.enableLoadingScreens == null)
			FlxG.save.data.enableLoadingScreens = true;

		if (FlxG.save.data.logWriter == null)
			FlxG.save.data.logWriter = true;

		if (FlxG.save.data.weekCompleted == null)
		{
			StoryMenuState.weekCompleted.set('', true);
			StoryMenuState.weekCompleted.set('tutorial', true);
			StoryMenuState.weekCompleted.set('week1', true);
			StoryMenuState.weekCompleted.set('week2', true);
			StoryMenuState.weekCompleted.set('week3', true);
			StoryMenuState.weekCompleted.set('week4', true);
			StoryMenuState.weekCompleted.set('week5', true);
			StoryMenuState.weekCompleted.set('week6', true);
			StoryMenuState.weekCompleted.set('week7', true);
			FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
		}

		if (FlxG.save.data.modConfig == null)
			FlxG.save.data.modConfig = '';

		Ratings.timingWindows = [
			FlxG.save.data.shitMs,
			FlxG.save.data.badMs,
			FlxG.save.data.goodMs,
			FlxG.save.data.sickMs
		];

		if (FlxG.save.data.noteskin == null)
			FlxG.save.data.noteskin = 'Arrows';

		if (!Std.isOfType(FlxG.save.data.noteskin, String))
			FlxG.save.data.noteskin = 'Arrows';

		if (FlxG.save.data.menuMusic == null)
			FlxG.save.data.menuMusic = 0;

		if (FlxG.save.data.memoryCount == null)
			FlxG.save.data.memoryCount = true;

		if (FlxG.save.data.overrideNoteskins == null)
			FlxG.save.data.overrideNoteskins = false;

		if (FlxG.save.data.localeStr == null)
			FlxG.save.data.localeStr = "en-US";

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.memoryCount = FlxG.save.data.memoryCount;
		Main.watermarks = FlxG.save.data.watermark;

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}
