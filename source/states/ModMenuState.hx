package states;

import states.XMLLayoutState;
import flixel.addons.ui.FlxUIButton;
import modding.ModCore;
import ModList;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import states.Caching;
import states.TitleState;
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
import gameplayStuff.Character;
import gameplayStuff.SongMetadata;

class ModMenuState extends XMLLayoutState
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
		return Paths.getPath('xmlStates/mod_menu', 'core');
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		super.create();
		trace('Initialized ModMenuState.');

		this.addClickEventHandler('btn_loadall', onClickLoadAll.bind());
		this.addClickEventHandler('btn_reloadall', onClickReloadAll.bind());
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

	var loadedMods:Array<ModMetadata> = [];
	var unloadedMods:Array<ModMetadata> = [];

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

	var inContributors:Bool = false;
	var blackScreen:FlxSprite;
	var contributorsText:FlxTypedGroup<FlxText>;
	public function showContributors(modData:ModMetadata)
	{
		inContributors = true;
		blackScreen = new FlxSprite(-200, -100).makeGraphic(Std.int(FlxG.width * 0.5), Std.int(FlxG.height * 0.5), FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.scrollFactor.set(0, 0);
		add(blackScreen);

		if (modData.contributors != null)
		{
			for (i in modData.contributors)
			{
				var nameText:FlxText = new FlxText(0, 10 * modData.contributors.indexOf(i), 0, i.name, 24);
				nameText.setFormat('Pixel Arial 11 Bold', 48, FlxColor.WHITE, CENTER);
				nameText.screenCenter();
				nameText.scrollFactor.set(0, 0);
				contributorsText.add(nameText);

				var roleText:FlxText = new FlxText(0, 15 * modData.contributors.indexOf(i), 0, i.role, 12);
				roleText.setFormat('Pixel Arial 11 Bold', 48, FlxColor.WHITE, CENTER);
				roleText.screenCenter();
				roleText.scrollFactor.set(0, 0);
				contributorsText.add(roleText);
			}
		}
		else
		{
			var warnText:FlxText = new FlxText(0, 10, 0, 'There`s no contributors in mod data', 24);
			warnText.setFormat('Pixel Arial 11 Bold', 48, FlxColor.WHITE, CENTER);
			warnText.screenCenter();
			warnText.scrollFactor.set(0, 0);
			contributorsText.add(warnText);
		}

		add(contributorsText);
	}

	public function closeContributors()
	{
		remove(blackScreen);
		contributorsText.clear();
		remove(contributorsText);
	}

	var curSelected:Int = -1;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE && !inContributors)
		{
			loadMainGame();
		}
		else if (FlxG.keys.justPressed.ESCAPE && inContributors)
		{
			inContributors = false;
			closeContributors();
		}

		super.update(elapsed);
	}

	function writeModPreferences()
	{
		Debug.logInfo('Saving mod configuration and continuing to game...');
		var loadedModIds:Array<String> = loadedModsUI.listCurrentMods().map(function(mod:ModMetadata) return mod.id);
		var modConfigStr = loadedModIds.join('~');
		//if (modConfigStr != '' && modConfigStr != null){
			Main.save.data.modConfig = modConfigStr;
			Main.save.flush();//}
		/*else{
			var empty:Array<String> = [];
			Main.save.data.modConfig = empty;
			Main.save.flush();}*/
	}

	function loadMainGame()
	{
		FlxG.mouse.visible = false;
		SongMetadata.preloaded = false;
		// Gotta load any configured mods.

		ModCore.loadConfiguredMods();

		FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);

		FlxG.switchState(new TitleState());
	}

	function onClickReloadAll()
	{
		ModCore.reloadLoadedMods();

		FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic), 0);

		FlxG.switchState(new TitleState());
	}

	function onClickLoadAll()
	{
		if (!inContributors)
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
	}

	function onClickUnloadAll()
	{
		if (!inContributors)
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
	}

	function onClickRevert()
	{
		if (!inContributors)
		{
			// Clear both mod lists so we're starting from scratch.
			unloadedModsUI.clearModList();
			loadedModsUI.clearModList();

			// Add the content to the mod lists again.
			initModLists();
		}
	}

	function onClickSaveAndExit()
	{
		if (!inContributors)
		{
			Character.characterList = [];
			Character.girlfriendList = [];

			writeModPreferences();


			// Just move to the main game.
			loadMainGame();
		}
	}

	function onClickExitWithoutSaving()
	{
		if (!inContributors)
		{
			// Just move to the main game.
			loadMainGame();
		}
	}
}