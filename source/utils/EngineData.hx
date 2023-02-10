package utils;

import gameplayStuff.Ratings;
import gameplayStuff.PlayStateChangeables;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;
import states.StoryMenuState;
import gameplayStuff.Conductor;

class EngineData
{
	public static function initSave()
	{
		if (Main.save.data.weekUnlocked == null)
			Main.save.data.weekUnlocked = 7;

		if (Main.save.data.caching == null)
			Main.save.data.caching = true;

		if (Main.save.data.newInput == null)
			Main.save.data.newInput = true;

		if (Main.save.data.downscroll == null)
			Main.save.data.downscroll = false;

		if (Main.save.data.antialiasing == null)
			Main.save.data.antialiasing = true;

		if (Main.save.data.missSounds == null)
			Main.save.data.missSounds = true;
		
		if (Main.save.data.toggleLeaderboard == null)
			Main.save.data.toggleLeaderboard = true;
		
		if (Main.save.data.dfjk == null)
			Main.save.data.dfjk = false;

		if (Main.save.data.accuracyDisplay == null)
			Main.save.data.accuracyDisplay = true;

		if (Main.save.data.offset == null)
			Main.save.data.offset = 0;

		if (Main.save.data.songPosition == null)
			Main.save.data.songPosition = false;

		if (Main.save.data.fps == null)
			Main.save.data.fps = false;

		if (Main.save.data.changedHit == null)
		{
			Main.save.data.changedHitX = -1;
			Main.save.data.changedHitY = -1;
			Main.save.data.changedHit = false;
		}

		if (Main.save.data.fpsRain == null)
			Main.save.data.fpsRain = false;

		if (Main.save.data.fpsCap == null)
			Main.save.data.fpsCap = 120;

		if (Main.save.data.fpsCap > 340 || Main.save.data.fpsCap < 60)
			Main.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (Main.save.data.scrollSpeed == null)
			Main.save.data.scrollSpeed = 1;

		if (Main.save.data.frames == null)
			Main.save.data.frames = 10;

		if (Main.save.data.accuracyMod == null)
			Main.save.data.accuracyMod = 1;

		if (Main.save.data.watermark == null)
			Main.save.data.watermark = true;

		if (Main.save.data.ghost == null)
			Main.save.data.ghost = true;

		if (Main.save.data.distractions == null)
			Main.save.data.distractions = true;

		if (Main.save.data.colour == null)
			Main.save.data.colour = true;

		if (Main.save.data.stepMania == null)
			Main.save.data.stepMania = false;

		if (Main.save.data.flashing == null)
			Main.save.data.flashing = true;

		if (Main.save.data.resetButton == null)
			Main.save.data.resetButton = false;

		if (Main.save.data.InstantRespawn == null)
			Main.save.data.InstantRespawn = false;

		if (Main.save.data.botplay == null)
			Main.save.data.botplay = false;
		
		if (Main.save.data.savedAchievements == null)
			Main.save.data.savedAchievements = [];

		if (Main.save.data.cpuStrums == null)
			Main.save.data.cpuStrums = false;

		if (Main.save.data.strumline == null)
			Main.save.data.strumline = false;

		if (Main.save.data.customStrumLine == null)
			Main.save.data.customStrumLine = 0;

		if (Main.save.data.camzoom == null)
			Main.save.data.camzoom = true;

		if (Main.save.data.scoreScreen == null)
			Main.save.data.scoreScreen = true;

		if (Main.save.data.inputShow == null)
			Main.save.data.inputShow = false;

		if (Main.save.data.optimize == null)
			Main.save.data.optimize = false;

		Main.save.data.cacheImages = false;

		if (Main.save.data.middleScroll == null)
			Main.save.data.middleScroll = false;

		if (Main.save.data.editorBG == null)
			Main.save.data.editorBG = false;

		if (Main.save.data.zoom == null)
			Main.save.data.zoom = 1;

		if (Main.save.data.judgementCounter == null)
			Main.save.data.judgementCounter = true;

		if (Main.save.data.laneUnderlay == null)
			Main.save.data.laneUnderlay = true;

		if (Main.save.data.healthBar == null)
			Main.save.data.healthBar = true;

		if (Main.save.data.laneTransparency == null)
			Main.save.data.laneTransparency = 0;

		if (Main.save.data.shitMs == null)
			Main.save.data.shitMs = 160.0;

		if (Main.save.data.badMs == null)
			Main.save.data.badMs = 135.0;

		if (Main.save.data.goodMs == null)
			Main.save.data.goodMs = 90.0;

		if (Main.save.data.sickMs == null)
			Main.save.data.sickMs = 45.0;

		if (Main.save.data.notesplashes == null)
			Main.save.data.notesplashes = true;

		if (Main.save.data.enableLoadingScreens == null)
			Main.save.data.enableLoadingScreens = true;

		if (Main.save.data.logWriter == null)
			Main.save.data.logWriter = true;

		if (Main.save.data.weekCompleted == null)
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
			Main.save.data.weekCompleted = StoryMenuState.weekCompleted;
		}

		if (Main.save.data.modConfig == null)
			Main.save.data.modConfig = '';

		Ratings.timingWindows = [
			Main.save.data.shitMs,
			Main.save.data.badMs,
			Main.save.data.goodMs,
			Main.save.data.sickMs
		];

		if (Main.save.data.noteskin == null)
			Main.save.data.noteskin = 'Arrows';

		if (!Std.isOfType(Main.save.data.noteskin, String))
			Main.save.data.noteskin = 'Arrows';

		if (Main.save.data.menuMusic == null)
			Main.save.data.menuMusic = 'freakyMenu';

		if (Main.save.data.memoryCount == null)
			Main.save.data.memoryCount = true;

		if (Main.save.data.overrideNoteskins == null)
			Main.save.data.overrideNoteskins = false;

		if (Main.save.data.localeStr == null)
			Main.save.data.localeStr = "en-US";

		Main.memoryCount = Main.save.data.memoryCount;
		Main.watermarks = Main.save.data.watermark;

		PlayStateChangeables.useMiddlescroll = Main.save.data.middleScroll;
		PlayStateChangeables.useDownscroll = Main.save.data.downscroll;
		PlayStateChangeables.safeFrames = Main.save.data.frames;
		PlayStateChangeables.scrollSpeed = Main.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = Main.save.data.botplay;
		PlayStateChangeables.Optimize = Main.save.data.optimize;
		PlayStateChangeables.zoom = Main.save.data.zoom;

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Main.save.data.fpsCap);
	}

	public static function initAfterGame() {
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		Controls.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		keyCheck();
	}

	public static function resetBinds():Void
	{
		Main.save.data.upBindP2 = "W";
		Main.save.data.downBindP2 = "S";
		Main.save.data.leftBindP2 = "A";
		Main.save.data.rightBindP2 = "D";
		Main.save.data.upBind = "UP";
		Main.save.data.downBind = "DOWN";
		Main.save.data.leftBind = "LEFT";
		Main.save.data.rightBind = "RIGHT";
		Main.save.data.muteBind = "ZERO";
		Main.save.data.volUpBind = "PLUS";
		Main.save.data.volDownBind = "MINUS";
		Main.save.data.fullscreenBind = "F";
		Main.save.data.gpupBind = "DPAD_UP";
		Main.save.data.gpdownBind = "DPAD_DOWN";
		Main.save.data.gpleftBind = "DPAD_LEFT";
		Main.save.data.gprightBind = "DPAD_RIGHT";
		Main.save.data.pauseBind = "ENTER";
		Main.save.data.gppauseBind = "START";
		Main.save.data.resetBind = "R";
		Main.save.data.gpresetBind = "SELECT";

		FlxG.sound.muteKeys = ["ZERO", "NUMPADZERO"];
		FlxG.sound.volumeDownKeys = ["MINUS", "NUMPADMINUS"];
		FlxG.sound.volumeUpKeys = ["PLUS", "NUMPADPLUS"];
		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
		if (Main.save.data.upBindP2 == null)
		{
			Main.save.data.upBindP2 = "W";
			trace("No UP");
			Main.save.flush();
		}
		if (Main.save.data.downBindP2 == null)
		{
			Main.save.data.downBindP2 = "S";
			trace("No DOWN");
			Main.save.flush();
		}
		if (Main.save.data.leftBindP2 == null)
		{
			Main.save.data.leftBindP2 = "A";
			trace("No LEFT");
			Main.save.flush();
		}
		if (Main.save.data.rightBindP2 == null)
		{
			Main.save.data.rightBindP2 = "D";
			trace("No RIGHT");
			Main.save.flush();
		}

		if (Main.save.data.upBind == null)
		{
			Main.save.data.upBind = "UP";
			trace("No UP");
			Main.save.flush();
		}
		if (Main.save.data.downBind == null)
		{
			Main.save.data.downBind = "DOWN";
			trace("No DOWN");
			Main.save.flush();
		}
		if (Main.save.data.leftBind == null)
		{
			Main.save.data.leftBind = "LEFT";
			trace("No LEFT");
			Main.save.flush();
		}
		if (Main.save.data.rightBind == null)
		{
			Main.save.data.rightBind = "RIGHT";
			trace("No RIGHT");
			Main.save.flush();
		}

		if (Main.save.data.gpupBind == null)
		{
			Main.save.data.gpupBind = "DPAD_UP";
			trace("No GUP");
			Main.save.flush();
		}
		if (Main.save.data.gpdownBind == null)
		{
			Main.save.data.gpdownBind = "DPAD_DOWN";
			trace("No GDOWN");
			Main.save.flush();
		}
		if (Main.save.data.gpleftBind == null)
		{
			Main.save.data.gpleftBind = "DPAD_LEFT";
			trace("No GLEFT");
			Main.save.flush();
		}
		if (Main.save.data.gprightBind == null)
		{
			Main.save.data.gprightBind = "DPAD_RIGHT";
			trace("No GRIGHT");
			Main.save.flush();
		}
		if (Main.save.data.pauseBind == null)
		{
			Main.save.data.pauseBind = "ENTER";
			trace("No ENTER");
			Main.save.flush();
		}
		if (Main.save.data.gppauseBind == null)
		{
			Main.save.data.gppauseBind = "START";
			trace("No ENTER");
			Main.save.flush();
		}
		if (Main.save.data.resetBind == null)
		{
			Main.save.data.resetBind = "R";
			trace("No RESET");
			Main.save.flush();
		}
		if (Main.save.data.gpresetBind == null)
		{
			Main.save.data.gpresetBind = "SELECT";
			trace("No RESET");
			Main.save.flush();
		}
		// VOLUME CONTROLS !!!!
		if (Main.save.data.muteBind == null)
		{
			Main.save.data.muteBind = "ZERO";
			trace("No MUTE");
			Main.save.flush();
		}
		if (Main.save.data.volUpBind == null)
		{
			Main.save.data.volUpBind = "PLUS";
			trace("No VOLUP");
			Main.save.flush();
		}
		if (Main.save.data.volDownBind == null)
		{
			Main.save.data.volDownBind = "MINUS";
			trace("No VOLDOWN");
			Main.save.flush();
		}
		if (Main.save.data.fullscreenBind == null)
		{
			Main.save.data.fullscreenBind = "F";
			trace("No FULLSCREEN");
			Main.save.flush();
		}
		if (Main.save.data.attackBind == null)
		{
			Main.save.data.attackBind = "SHIFT";
			trace("No ATTACK");
			Main.save.flush();
		}

		trace('${Main.save.data.leftBind}-${Main.save.data.downBind}-${Main.save.data.upBind}-${Main.save.data.rightBind}');
	}
}
