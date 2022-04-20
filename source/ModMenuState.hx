package;

import Util;
import XMLLayoutState;
import flixel.addons.ui.FlxUIButton;
import ModCore;
import ModList;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import Caching;
import TitleState;
import flixel.addons.ui.FlxUIList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import polymod.Polymod.ModMetadata;

class ModMenuState extends XMLLayoutState // extends MusicBeatState
{
	var loadAllButton:FlxUIButton;
	var unloadAllButton:FlxUIButton;
	var revertButton:FlxUIButton;
	var saveAndExitButton:FlxUIButton;
	var exitWithoutSavingButton:FlxUIButton;

	static final MENU_WIDTH = 500;

	var unloadedModsUI:ModList;
	var loadedModsUI:ModList;

	override function getXMLId()
	{
		return 'assets/ui/mod_menu';
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		super.create();
		trace('Initialized ModMenuState.');

		this.addClickEventHandler('btn_loadall', onClickLoadAll.bind());
		this.addClickEventHandler('btn_unloadall', onClickUnloadAll.bind());
		this.addClickEventHandler('btn_revert', onClickRevert.bind());
		this.addClickEventHandler('btn_saveandexit', onClickSaveAndExit.bind());
		this.addClickEventHandler('btn_exitwithoutsaving', onClickExitWithoutSaving.bind());

		initModLists();
	}

	override function buildComponent(tag:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		var element:Xml = cast data;
		switch (tag)
		{
			case 'modlist':
				var x = Std.parseInt(element.get('x'));
				var y = Std.parseInt(element.get('y'));
				var w = Std.parseInt(element.get('w'));
				var h = Std.parseInt(element.get('h'));
				var loaded = element.get('loaded') == 'true';

				var result = new ModList(x, y, w, h, loaded);

				if (loaded)
					loadedModsUI = result;
				else
					unloadedModsUI = result;

				return result;
			default:
				return super.buildComponent(tag, target, data, params);
		}
	}

	function initModLists()
	{
		// Unify mod lists.
		unloadedModsUI.cbAddToOtherList = loadedModsUI.addMod.bind();
		loadedModsUI.cbAddToOtherList = unloadedModsUI.addMod.bind();

		var modDatas = ModCore.getAllMods().filter(function(m)
		{
			return m != null;
		});

		var loadedModIds = ModCore.getConfiguredMods();

		var loadedMods:Array<ModMetadata> = [];
		var unloadedMods:Array<ModMetadata> = [];

		if (loadedModIds != null)
		{
			// If loadedModIds != null, return.
			loadedMods = modDatas.filter(function(m)
			{
				return loadedModIds.contains(m.id);
			});
			unloadedMods = modDatas.filter(function(m)
			{
				return !loadedModIds.contains(m.id);
			});
		}
		else
		{
			// No existing configuration.
			// We default to ALL mods loaded.
			unloadedMods = [];
			loadedMods = modDatas;
		}

		for (i in loadedMods)
		{
			loadedModsUI.addMod(i);
		}
		for (i in unloadedMods)
		{
			unloadedModsUI.addMod(i);
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			loadMainGame();
		}

		super.update(elapsed);
	}

	function writeModPreferences()
	{
		Debug.logInfo('Saving mod configuration and continuing to game...');
		var loadedModIds:Array<String> = loadedModsUI.listCurrentMods().map(function(mod:ModMetadata) return mod.id);
		var modConfigStr = loadedModIds.join('~');
		Debug.logTrace(modConfigStr);
		FlxG.save.data.modConfig = modConfigStr;
		FlxG.save.flush();
	}

	function loadMainGame()
	{
		FlxG.mouse.visible = false;
		// Gotta load any configured mods.
		ModCore.loadConfiguredMods();
		#if FEATURE_FILESYSTEM
		if (FlxG.save.data.caching)
			FlxG.switchState(new Caching());
		else
			FlxG.switchState(new TitleState());
		#else
		FlxG.switchState(new TitleState());
		#end
	}

	function onClickLoadAll()
	{
		var unloadedMods:Array<ModMetadata> = unloadedModsUI.listCurrentMods();

		// Add all unloaded mods to the loaded list.
		for (i in unloadedMods)
		{
			loadedModsUI.addMod(i);
		}

		// Remove all mods from the unloaded list.
		unloadedModsUI.clearModList();
	}

	function onClickUnloadAll()
	{
		var loadedMods:Array<ModMetadata> = loadedModsUI.listCurrentMods();

		// Add all loaded mods to the unloaded list.
		for (i in loadedMods)
		{
			unloadedModsUI.addMod(i);
		}

		// Remove all mods from the loaded list.
		loadedModsUI.clearModList();
	}

	function onClickRevert()
	{
		// Clear both mod lists so we're starting from scratch.
		unloadedModsUI.clearModList();
		loadedModsUI.clearModList();

		// Add the content to the mod lists again.
		initModLists();
	}

	function onClickSaveAndExit()
	{
		// Save mod preferences.
		writeModPreferences();

		// Just move to the main game.
		loadMainGame();
	}

	function onClickExitWithoutSaving()
	{
		// Just move to the main game.
		loadMainGame();
	}
}