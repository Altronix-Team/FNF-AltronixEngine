package altronixengine.states.editors;

import flash.net.FileFilter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import altronixengine.gameplayStuff.Character;
import altronixengine.gameplayStuff.HealthIcon;
import haxe.Json;
import hx.strings.String8;
import lime.system.Clipboard;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import altronixengine.states.FreeplayState;
import altronixengine.states.MusicBeatState;
import altronixengine.states.StoryMenuState;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class FreeplaySongsEditorState extends MusicBeatState
{
	var weekFile:FreeplaySonglist = null;
	var curWeek:SongsWithWeekId = null;
	var curWeekInt:Int = 0;

	public function new(weekFile:FreeplaySonglist = null)
	{
		super();
		this.weekFile = FreeplayState.createEmptyFile();

		if (weekFile != null)
			this.weekFile = weekFile;
	}

	var bg:FlxSprite;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var curSelected = 0;

	var curSelectedWeek = 0;

	override function create()
	{
		FlxG.mouse.visible = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = Main.save.data.antialiasing;

		bg.color = FlxColor.WHITE;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		curWeek = weekFile.freeplaySonglist[curWeekInt];

		loadSongs();

		addEditorBox();
		changeSelection();
		getCharacterColor(curWeek.weekChar[0]);
		super.create();
	}

	var icon:HealthIcon = null;
	var songText:Alphabet = null;

	function loadSongs()
	{
		grpSongs.clear();

		for (i in iconArray)
			i.kill();

		iconArray = [];

		for (i in 0...curWeek.weekSongs.length)
		{
			songText = new Alphabet(0, (70 * i) + 30, curWeek.weekSongs[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.visible = true;
			grpSongs.add(songText);

			if (curWeek.weekChar.length > 1)
			{
				icon = new HealthIcon(curWeek.weekChar[i], CharactersStuff.getCharacterIcon(curWeek.weekChar[i]));
				icon.sprTracker = songText;
				iconArray.push(icon);
				icon.visible = true;
				add(icon);
			}
			else
			{
				icon = new HealthIcon(curWeek.weekChar[i], CharactersStuff.getCharacterIcon(curWeek.weekChar[0]));
				icon.sprTracker = songText;
				iconArray.push(icon);
				icon.visible = true;
				add(icon);
			}
		}
	}

	var UI_box:FlxUITabMenu;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

	function addEditorBox()
	{
		var tabs = [{name: 'Freeplay', label: 'Freeplay'},];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(350, 200);
		UI_box.x = FlxG.width - UI_box.width - 100;
		UI_box.y = FlxG.height - UI_box.height - 60;
		UI_box.scrollFactor.set();

		UI_box.selected_tab_id = 'Week';
		addFreeplayUI();
		add(UI_box);

		var blackBlack:FlxSprite = new FlxSprite(0, 670).makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		blackBlack.alpha = 0.6;
		add(blackBlack);

		var loadWeekButton:FlxButton = new FlxButton(0, 685, "Load Songlist", function()
		{
			loadWeek();
		});
		loadWeekButton.screenCenter(X);
		loadWeekButton.x -= 120;
		add(loadWeekButton);

		var saveWeekButton:FlxButton = new FlxButton(0, 685, "Save Songlist", function()
		{
			saveWeek(weekFile);
		});
		saveWeekButton.screenCenter(X);
		saveWeekButton.x += 120;
		add(saveWeekButton);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == iconInputText)
			{
				var splittedText:Array<String> = iconInputText.text.trim().split(',');
				for (i in 0...splittedText.length)
				{
					splittedText[i] = splittedText[i].trim();
				}

				while (splittedText.length < curWeek.weekChar.length)
				{
					curWeek.weekChar.pop();
				}

				for (i in 0...splittedText.length)
				{
					if (i >= curWeek.weekChar.length)
					{
						curWeek.weekChar.push(splittedText[i]);
					}
					else
					{
						curWeek.weekChar[i] = splittedText[i];
					}
				}
				iconArray[curSelected].changeIcon(iconArray[curSelected].character, splittedText[curSelected]);
			}
			else if (sender == weekSongsInputText)
			{
				var splittedText:Array<String> = weekSongsInputText.text.trim().split(',');
				for (i in 0...splittedText.length)
				{
					splittedText[i] = splittedText[i].trim();
				}

				while (splittedText.length < curWeek.weekSongs.length)
				{
					curWeek.weekSongs.pop();
				}

				for (i in 0...splittedText.length)
				{
					if (i >= curWeek.weekSongs.length)
					{ // Add new song
						curWeek.weekSongs.push(splittedText[i]);
					}
					else
					{ // Edit song
						curWeek.weekSongs[i] = splittedText[i];
					}
				}
			}
			else if (sender == weekDiffsInputText)
			{
				var splittedText:Array<String> = weekDiffsInputText.text.trim().split(',');
				for (i in 0...splittedText.length)
				{
					splittedText[i] = splittedText[i].trim();
				}

				while (splittedText.length < curWeek.weekDiffs.length)
				{
					curWeek.weekDiffs.pop();
				}

				for (i in 0...splittedText.length)
				{
					if (i >= curWeek.weekDiffs.length)
					{
						curWeek.weekDiffs.push(splittedText[i]);
					}
					else
					{
						curWeek.weekDiffs[i] = splittedText[i];
					}
				}
			}
			else if (sender == weekIdInputText)
			{
				curWeek.weekID = Std.parseInt(weekIdInputText.text);
			}
		}
	}

	var weekSongsInputText:FlxUIInputText;
	var weekDiffsInputText:FlxUIInputText;
	var weekIdInputText:FlxUIInputText;
	var iconInputText:FlxUIInputText;

	function addFreeplayUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Freeplay";

		var saveWeekBtt:FlxButton = new FlxButton(10, 10, "Save Week", function()
		{
			saveCurWeek();
		});

		var addWeekBtt:FlxButton = new FlxButton(110, 10, "Add Week", function()
		{
			addNewWeek();
		});

		var removeWeekBtt:FlxButton = new FlxButton(210, 10, "Remove Week", function()
		{
			if (curSelectedWeek == weekFile.freeplaySonglist.length - 1 && curSelectedWeek == 0)
			{
				var newCurWeek = {
					weekChar: ['dad'],
					weekID: 0,
					weekSongs: ['test'],
					weekDiffs: ['Easy', 'Normal', 'Hard', 'Hard P']
				}
				weekFile.freeplaySonglist[curWeekInt] = newCurWeek;
				reloadAllShit();
			}
			else
				removeWeek();
		});

		weekSongsInputText = new FlxUIInputText(10, 50, 200, '', 8);
		blockPressWhileTypingOn.push(weekSongsInputText);

		weekDiffsInputText = new FlxUIInputText(10, weekSongsInputText.y + 40, 200, '', 8);
		blockPressWhileTypingOn.push(weekDiffsInputText);

		iconInputText = new FlxUIInputText(10, weekDiffsInputText.y + 40, 200, '', 8);
		blockPressWhileTypingOn.push(iconInputText);

		weekIdInputText = new FlxUIInputText(240, weekSongsInputText.y, 50, '', 8);
		blockPressWhileTypingOn.push(weekIdInputText);

		tab_group.add(new FlxText(iconInputText.x, iconInputText.y - 18, 0, 'Week Character:'));
		tab_group.add(iconInputText);

		tab_group.add(new FlxText(weekIdInputText.x, weekIdInputText.y - 18, 0, 'Week Id:'));
		tab_group.add(weekIdInputText);

		tab_group.add(new FlxText(weekSongsInputText.x, weekSongsInputText.y - 18, 0, 'Week Songs:'));
		tab_group.add(weekSongsInputText);

		tab_group.add(new FlxText(weekDiffsInputText.x, weekDiffsInputText.y - 18, 0, 'Week Difficulties:'));
		tab_group.add(weekDiffsInputText);

		tab_group.add(saveWeekBtt);
		tab_group.add(addWeekBtt);
		tab_group.add(removeWeekBtt);

		weekSongsInputText.text = '';
		for (i in 0...curWeek.weekSongs.length)
		{
			if (i < curWeek.weekSongs.length - 1)
				weekSongsInputText.text += curWeek.weekSongs[i] + ', ';
			else
				weekSongsInputText.text += curWeek.weekSongs[i];
		}

		weekDiffsInputText.text = '';
		if (curWeek.weekDiffs != null)
		{
			for (i in 0...curWeek.weekDiffs.length)
			{
				if (i < curWeek.weekDiffs.length - 1)
					weekDiffsInputText.text += curWeek.weekDiffs[i] + ', ';
				else
					weekDiffsInputText.text += curWeek.weekDiffs[i];
			}
		}
		else
		{
			weekDiffsInputText.text = 'Easy, Normal, Hard, Hard P';
		}

		var charString:String = curWeek.weekChar[0];
		for (i in 1...curWeek.weekChar.length)
		{
			charString += ', ' + curWeek.weekChar[i];
		}

		iconInputText.text = charString;
		weekIdInputText.text = Std.string(curWeek.weekID);

		UI_box.addGroup(tab_group);
	}

	function reloadAllShit()
	{
		weekSongsInputText.text = '';
		for (i in 0...curWeek.weekSongs.length)
		{
			if (i < curWeek.weekSongs.length - 1)
				weekSongsInputText.text += curWeek.weekSongs[i] + ', ';
			else
				weekSongsInputText.text += curWeek.weekSongs[i];
		}

		weekDiffsInputText.text = '';
		if (curWeek.weekDiffs != null)
		{
			for (i in 0...curWeek.weekDiffs.length)
			{
				if (i < curWeek.weekDiffs.length - 1)
					weekDiffsInputText.text += curWeek.weekDiffs[i] + ', ';
				else
					weekDiffsInputText.text += curWeek.weekDiffs[i];
			}
		}
		else
		{
			weekDiffsInputText.text = 'Easy, Normal, Hard, Hard P';
		}

		var charString:String = curWeek.weekChar[0];
		for (i in 1...curWeek.weekChar.length)
		{
			charString += ', ' + curWeek.weekChar[i];
		}

		iconInputText.text = charString;
		weekIdInputText.text = Std.string(curWeek.weekID);

		loadSongs();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		if (curSelected >= grpSongs.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}
		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		if (curWeek.weekDiffs == null)
			curWeek.weekDiffs = ['Easy', 'Normal', 'Hard', 'Hard P'];

		if (curWeek.weekChar.length > 1)
			getCharacterColor(curWeek.weekChar[curSelected]);
		else
			getCharacterColor(curWeek.weekChar[0]);
	}

	function changeWeek(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelectedWeek += change;
		if (curSelectedWeek < 0)
			curSelectedWeek = weekFile.freeplaySonglist.length - 1;
		if (curSelectedWeek >= weekFile.freeplaySonglist.length)
			curSelectedWeek = 0;

		curWeekInt = curSelectedWeek;

		curWeek = weekFile.freeplaySonglist[curWeekInt];

		curSelected = 0;

		reloadAllShit();
		changeSelection();
		getCharacterColor(curWeek.weekChar[0]);
	}

	function getCharacterColor(char:String)
	{
		Debug.logInfo('Getting character color (${char})');

		if (char != null)
		{
			var jsonData;
			if (OpenFlAssets.exists(Paths.json('characters/${char}')))
				jsonData = Paths.loadJSON('characters/${char}');
			else
			{
				Debug.logError('Failed to parse JSON data for character ${char}');
				return;
			}

			var data:CharacterData = cast jsonData;
			var bgColorArray:Array<Int> = [];

			if (data.barColorJson != null && data.barColorJson.length > 2)
				bgColorArray = data.barColorJson;
			bg.color = FlxColor.fromRGB(bgColorArray[0], bgColorArray[1], bgColorArray[2]);
		}
		else
		{
			Debug.logError('You don`t have this character. Fuck you');
			bg.color = FlxColor.fromRGB(0, 0, 0);
		}
	}

	function getCharacterIcon(char:String):String
	{
		Debug.logInfo('Getting character color (${char})');

		var iconName:String = 'face';

		if (char != null)
		{
			var jsonData;
			if (OpenFlAssets.exists(Paths.json('characters/${char}')))
				jsonData = Paths.loadJSON('characters/${char}');
			else
			{
				Debug.logError('Failed to parse JSON data for character ${char}');
				return iconName;
			}

			var data:CharacterData = cast jsonData;

			if (data.characterIcon != null)
			{
				iconName = data.characterIcon;
				return iconName;
			}
			else
			{
				iconName = 'face';
				return iconName;
			}
		}
		else
		{
			Debug.logError('You don`t have this character. Fuck you');
			iconName = 'face';
			return iconName;
		}
	}

	function saveCurWeek()
	{
		weekFile.freeplaySonglist[curWeekInt] = curWeek;
		reloadAllShit();
	}

	function addNewWeek()
	{
		var newCurWeek = {
			weekChar: ['dad'],
			weekID: 0,
			weekSongs: ['test'],
			weekDiffs: ['Easy', 'Normal', 'Hard', 'Hard P']
		}
		weekFile.freeplaySonglist[curWeekInt + 1] = newCurWeek;
		reloadAllShit();
		changeWeek(1);
	}

	function removeWeek()
	{
		weekFile.freeplaySonglist.remove(weekFile.freeplaySonglist[curWeekInt]);
		curWeek = weekFile.freeplaySonglist[curWeekInt - 1];
		reloadAllShit();
	}

	private static var _file:FileReference;

	public static function loadWeek()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadedWeek:FreeplaySonglist = null;
	public static var loadError:Bool = false;

	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if (_file.__path != null)
			fullPath = _file.__path;

		if (fullPath != null)
		{
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null)
			{
				loadedWeek = cast Json.parse(rawJson);
				if (loadedWeek.freeplaySonglist != null && loadedWeek.freeplaySonglist.length > 0) // Make sure it's really a week
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					return;
				}
			}
		}
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private static function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	public static function saveWeek(weekFile:FreeplaySonglist)
	{
		var data:String = Json.stringify(weekFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "freeplaySonglist.json");
		}
	}

	private static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	override function update(elapsed:Float)
	{
		if (loadedWeek != null)
		{
			weekFile = loadedWeek;
			loadedWeek = null;
			curWeek = weekFile.freeplaySonglist[0];
			reloadAllShit();
			changeSelection();
			getCharacterColor(curWeek.weekChar[0]);
		}
		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;

				if (FlxG.keys.justPressed.ENTER)
					inputText.hasFocus = false;
				break;
			}
		}

		if (iconInputText.hasFocus)
		{
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
			if (FlxG.keys.justPressed.ENTER)
			{
				iconInputText.hasFocus = false;
			}
		}
		else
		{
			FlxG.sound.muteKeys = [FlxKey.fromString(Main.save.data.muteBind)];
			FlxG.sound.volumeDownKeys = [FlxKey.fromString(Main.save.data.volDownBind)];
			FlxG.sound.volumeUpKeys = [FlxKey.fromString(Main.save.data.volUpBind)];
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music(Main.save.data.menuMusic));
			}

			if (!blockInput)
			{
				if (controls.LEFT_P)
					changeWeek(-1);
				if (controls.RIGHT_P)
					changeWeek(1);

				if (controls.UP_P)
					changeSelection(-1);
				if (controls.DOWN_P)
					changeSelection(1);
			}
		}
		super.update(elapsed);
	}
}
