package states;

import gameplayStuff.Song;
#if FEATURE_FILESYSTEM

import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import gameplayStuff.Highscore;


//Just comment everything
/*class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var gameLogo:FlxSprite;
	var bar:FlxBar;

	public static var bitmapData:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	static var flxImageCache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var songJsons:Map<String, Array<SongData>> = new Map<String, Array<SongData>>();

	var images = [];
	var music = [];
	var charts = [];

	override function create()
	{
		Main.save.bind('funkin', 'ninjamuffin99');

		@:privateAccess
		{
			Debug.logTrace("We loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}

		FlxG.autoPause = false;

		PlayerSettings.init();

		EngineData.initSave();

		KeyBinds.keyCheck();
		// It doesn't reupdate the list before u restart rn lmao

		NoteskinHelpers.updateNoteskins();

		if (Main.save.data.volDownBind == null)
			Main.save.data.volDownBind = "MINUS";
		if (Main.save.data.volUpBind == null)
			Main.save.data.volUpBind = "PLUS";

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		FlxGraphic.defaultPersist = Main.save.data.cacheImages;

		MusicBeatState.initSave = true;

		Highscore.load();

		bitmapData = new Map<String, FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;

		gameLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.loadImage('enginelogo'));
		gameLogo.x -= gameLogo.width / 2;
		gameLogo.y -= gameLogo.height / 2 + 100;
		text.y -= gameLogo.height / 2 - 125;
		text.x -= 170;
		gameLogo.setGraphicSize(Std.int(gameLogo.width * 0.6));
		if (Main.save.data.antialiasing != null)
			gameLogo.antialiasing = Main.save.data.antialiasing;
		else
			gameLogo.antialiasing = true;

		gameLogo.alpha = 0;

		FlxGraphic.defaultPersist = Main.save.data.cacheImages;

		#if FEATURE_FILESYSTEM
		if (Main.save.data.cacheImages)
		{
			Debug.logTrace("caching images...");

			images.concat(listImageFilesToCache(['characters']));
			images.concat(listImageFilesToCache(['noteskins']));
		}

		Debug.logTrace("caching music...");

		music = Paths.listSongsToCache();
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.createGradientFilledBar([FlxColor.fromRGB(226, 0, 255, 255), FlxColor.fromRGB(0, 254, 255, 255), FlxColor.fromRGB(0, 255, 166, 255),  FlxColor.fromRGB(224, 255, 0, 255)]);
		bar.visible = true;
		bar.scrollFactor.set();

		add(gameLogo);
		add(text);

		add(bar);

		trace('starting caching..');

		#if FEATURE_MULTITHREADING
			doInBackground(cache);
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
		// Update the loading text. This should be done in the main UI thread.
		var alpha = CoolUtil.truncateFloat(done / toBeDone * 100, 2) / 100;
		gameLogo.alpha = alpha;
		text.text = "Loading... (" + done + "/" + toBeDone + ")";
		bar.value = done;
	}

	function listImageFilesToCache(prefixes:Array<String>)
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var graphicsAssets = OpenFlAssets.list(IMAGE);
	
		var graphicsNames = [];
	
		for (graphic in graphicsAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = graphic.split('/');
			path.reverse();
		}
	
		return graphicsNames;
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		Debug.logTrace("Cache thread initialized. Caching " + toBeDone + " items...");

		for (i in images)
		{
			Debug.logTrace('Caching graphic $i');
			var replaced = i.replaceAll(".png", "");

			var imagePath = Paths.image(replaced, 'shared');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);

			cacheImage(replaced, graph);
			Debug.logTrace('Cached graphic $i');
			Debug.logTrace('In path $imagePath');
			done++;
		}

		for (i in music)
		{
			Debug.logTrace('Caching song "$i"...');
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
				Debug.logTrace('  Cached inst for song "$i"');
			}

			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
				Debug.logTrace('  Cached voices for song "$i"');
			}

			done++;
		}

		Debug.logTrace("Finished caching...");

		loaded = true;
		#end

		// If the file system is supported, move to the title state after caching is done.
		// If the file system isn't supported, move to the title state immediately.
		FlxG.switchState(new TitleState());
	}
	override function onWindowFocusOut() {
		return;
	}

	override function onWindowFocusIn() {
		return;
	}

	public static function cacheImage(key:String, graphic:FlxGraphic)
	{
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
	
		flxImageCache.set(key, graphic);
	}

	public static function doInBackground(cb:Void->Void)
	{
		#if FEATURE_MULTITHREADING
		sys.thread.Thread.create(() ->
		{
			// Run in the background.
			cb();
		});
		#end
	}
}*/
#end