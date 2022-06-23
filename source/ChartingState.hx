package;

import Song.SongMeta;
import openfl.system.System;
import lime.app.Application;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import sys.FileSystem;
import flash.media.Sound;
#end
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.StrNameLabel;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SongData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import haxe.io.Bytes;
import flash.geom.Rectangle;
import openfl.utils.Assets as OpenFlAssets;
import Character;
#if desktop
import DiscordClient;
#end

using StringTools;
using hx.strings.Strings;

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class ChartingState extends MusicBeatState
{
	public static var noteTypeList:Array<String> = //Using for custom noteType.
	[
		'Default Note',
		'Hurt Note',
		'Bullet Note',
		'GF Sing',
		'No Animation'
	];

	public static var eventTypeList:Array<String> = //Using for custom events.
	[
		"BPM Change",
		"Scroll Speed Change",
		"Start Countdown",
		"Change Character",
		"Change Stage",
		"Song Overlay",
		'Character play animation',
		"Camera zoom",
		"Toggle interface",
		'Screen Shake',
		'Camera Follow Pos',
		"Toggle Alt Idle"/*,
		"Change note skin"*/
	];

	private var noteTypeIntMap:Map<Int, String> = new Map<Int, String>();
	private var noteTypeMap:Map<String, Null<Int>> = new Map<String, Null<Int>>();

	public static var instance:ChartingState;

	var _file:FileReference;

	public var playClaps:Bool = false;

	public var snap:Int = 16;

	public var deezNuts:Map<Int, Int> = new Map<Int, Int>(); // snap conversion map

	var UI_box:FlxUITabMenu;
	//var UI_options:FlxUITabMenu;

	public static var lengthInSteps:Float = 0;
	public static var lengthInBeats:Float = 0;

	public var speed = 1.0;

	public var beatsShown:Float = 1; // for the zoom factor
	public var zoomFactor:Float = 0.4;

	public static var noteType:Dynamic = 0;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var writingNotesText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var subDivisions:Float = 1;
	var defaultSnap:Bool = true;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNoteType:FlxTypedGroup<FlxText>;

	var gridBG:FlxSprite;

	public var sectionRenderes:FlxTypedGroup<SectionRender>;

	public static var _song:SongData;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;
	var vocals:FlxSound;

	var player2:Character = new Character(0, 0, "dad");
	var player1:Boyfriend = new Boyfriend(0, 0, "bf");

	public static var leftIcon:HealthIcon;

	var height = 0;

	public static var rightIcon:HealthIcon;

	private var lastNote:Note;

	public var lines:FlxTypedGroup<FlxSprite>;

	var claps:Array<Note> = [];

	public var snapText:FlxText;

	var camFollow:FlxObject;

	public static var latestChartVersion = "3";

	var eventDescription:FlxText;
	var eventDescriptionText:String;

	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var waveformSprite:FlxSprite;

	public function new(reloadOnInit:Bool = false)
	{
		super();
		// If we're loading the charter from an arbitrary state, we need to reload the song on init,
		// but if we're not, then reloading the song is a performance drop.
		this.reloadOnInit = reloadOnInit;
	}

	var reloadOnInit = false;

	override function create()
	{
		curSection = lastSection;

		Debug.logTrace(1 > Math.POSITIVE_INFINITY);

		Debug.logTrace(PlayState.noteskinSprite);

		PlayState.noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		PlayState.chartingMode = true;

		FlxG.mouse.visible = true;

		PlayState.inDaPlay = false;

		instance = this;

		deezNuts.set(4, 1);
		deezNuts.set(8, 2);
		deezNuts.set(12, 3);
		deezNuts.set(16, 4);
		deezNuts.set(24, 6);
		deezNuts.set(32, 8);
		deezNuts.set(64, 16);

		if (FlxG.save.data.showHelp == null)
			FlxG.save.data.showHelp = true;

		sectionRenderes = new FlxTypedGroup<SectionRender>();
		lines = new FlxTypedGroup<FlxSprite>();
		texts = new FlxTypedGroup<FlxText>();

		TimingStruct.clearTimings();

		if (PlayState.SONG != null)
		{
			if (PlayState.isSM)
			{
				#if FEATURE_STEPMANIA
				_song = Song.conversionChecks(Song.loadFromJsonRAW(File.getContent(PlayState.pathToSm + "/converted.json")));
				#end
			}
			else
			{
				var diff:String = "";

				switch (PlayState.storyDifficulty)
				{
					case 0:
						diff = "-easy";
					case 2:
						diff = "-hard";
					case 3:
						diff = "-hardplus";
					case 1:
						diff = '';
					default:
						diff = "-" + CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toLowerCase();
				}
				_song = Song.conversionChecks(Song.loadFromJson(PlayState.SONG.songId, diff));
			}
		}
		else
		{
			_song = {
				chartVersion: latestChartVersion,
				songId: 'test',
				songName: 'Test',
				notes: [],
				eventObjects: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				noteStyle: 'normal',
				hideGF: false,
				stage: 'stage',
				speed: 1,
				validScore: false
			};
		}

		addGrid(1);

		if (_song.chartVersion == null)
			_song.chartVersion = "2";

		// var blackBorder:FlxSprite = new FlxSprite(60,10).makeGraphic(120,100,FlxColor.BLACK);
		// blackBorder.scrollFactor.set();

		// blackBorder.alpha = 0.3;

		snapText = new FlxText(60, 10, 0, "", 14);
		snapText.scrollFactor.set();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNoteType = new FlxTypedGroup<FlxText>();

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		loadSong(_song.songId, reloadOnInit);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon(getCharacterIcon(_song.player1));
		rightIcon = new HealthIcon(getCharacterIcon(_song.player2));

		var index = 0;

		if (_song.eventObjects == null)
			_song.eventObjects = [new Song.Event("Init BPM", 0, _song.bpm, "BPM Change")];

		if (_song.eventObjects.length == 0)
			_song.eventObjects = [new Song.Event("Init BPM", 0, _song.bpm, "BPM Change")];

		Debug.logTrace("goin");

		var currentIndex = 0;
		for (i in _song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			if (type == "BPM Change")
			{
				var beat:Float = pos;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, value, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
		}

		var lastSeg = TimingStruct.AllTimings[TimingStruct.AllTimings.length - 1];

		for (i in 0...TimingStruct.AllTimings.length)
		{
			var seg = TimingStruct.AllTimings[i];
			if (i == TimingStruct.AllTimings.length - 1)
				lastSeg = seg;
		}

		Debug.logTrace("STRUCTS: " + TimingStruct.AllTimings.length);

		recalculateAllSectionTimes();

		Debug.logTrace("Song length in MS: " + FlxG.sound.music.length);

		for (i in 0...9000000) // REALLY HIGH BEATS just cuz like ig this is the upper limit, I mean ur chart is probably going to run like ass anyways
		{
			var seg = TimingStruct.getTimingAtBeat(i);

			var start:Float = (i - seg.startBeat) / (seg.bpm / 60);

			var time = (seg.startTime + start) * 1000;

			if (time > FlxG.sound.music.length)
				break;

			lengthInBeats = i;
		}

		for (i in 0..._song.notes.length)
		{
			lengthInSteps += _song.notes[i].lengthInSteps;
		}
		

		Debug.logTrace('LENGTH IN STEPS '
			+ lengthInSteps
			+ ' | LENGTH IN BEATS '
			+ lengthInBeats
			+ ' | SECTIONS: '
			+ Math.floor(((lengthInSteps + 16)) / 16));

		var sections = Math.floor(((lengthInSteps + 16)) / 16);

		var targetY = getYfromStrum(FlxG.sound.music.length);

		Debug.logTrace("TARGET " + targetY);

		for (awfgaw in 0..._song.notes.length) // grids/steps
		{
			var renderer = new SectionRender(0, 640 * awfgaw, GRID_SIZE, _song.notes[awfgaw].lengthInSteps);
			if (_song.notes[awfgaw] == null)
				_song.notes.push(newSection(16, true, false, false));

			renderer.section = _song.notes[awfgaw];

			sectionRenderes.add(renderer);

			var down = getYfromStrum(renderer.section.startTime) * zoomFactor;

			var sectionicon = null;

			if (_song.notes[awfgaw].gfSection)
				sectionicon = new HealthIcon(getCharacterIcon(_song.gfVersion)).clone();
			else
				sectionicon = _song.notes[awfgaw].mustHitSection ? new HealthIcon(getCharacterIcon(_song.player1)).clone() : new HealthIcon(getCharacterIcon(_song.player2)).clone();

			sectionicon.x = -95;
			sectionicon.y = down - 75;
			sectionicon.setGraphicSize(0, 45);

			renderer.icon = sectionicon;
			renderer.lastUpdated = _song.notes[awfgaw].mustHitSection;

			add(sectionicon);
			height = Math.floor(renderer.y);
		}

		Debug.logTrace(height);

		gridBlackLine = new FlxSprite(gridBG.width / 2).makeGraphic(2, height, FlxColor.BLACK);

		waveformSprite = new FlxSprite(40, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);

		// leftIcon.scrollFactor.set();
		// rightIcon.scrollFactor.set();

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		leftIcon.scrollFactor.set();
		rightIcon.scrollFactor.set();

		bpmTxt = new FlxText(985, 25, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 0).makeGraphic(Std.int(GRID_SIZE * 8), 4);
		strumLine.color = 0xFF00FFFF;

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'},
			{name: "Charting", label: 'Charting'},
			{name: "Events", label: 'Song Events'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 40;
		UI_box.y = 20;

		add(UI_box);

		#if LUA_ALLOWED
		var luaList:Array<String> = Paths.listLuaInPath('assets/custom_events/');
		Debug.logTrace(luaList);
		for (i in 0...luaList.length)
		{
			if(!eventTypeList.contains(luaList[i])) {
				eventTypeList.push(luaList[i]);
			}
		}
		#end

		#if LUA_ALLOWED
		var luaList:Array<String> = Paths.listLuaInPath('assets/custom_notetypes/');
		for (i in 0...luaList.length)
		{
			if(!noteTypeList.contains(luaList[i])) {
				noteTypeList.push(luaList[i]);
			}
		}
		#end
		

		addSongUI();
		addSectionUI();
		addNoteUI();

		//addOptionsUI();
		addEventsUI();

		//updateWaveform();

		regenerateLines();

		updateGrid();

		Debug.logTrace("bruh");

		add(sectionRenderes);
		add(dummyArrow);
		add(strumLine);
		add(lines);
		add(texts);
		add(gridBlackLine);
		add(waveformSprite);
		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedNoteType);
		selectedBoxes = new FlxTypedGroup();

		add(selectedBoxes);

		Debug.logTrace("bruh");

		// add(blackBorder);
		add(snapText);

		Debug.logTrace("bruh");

		Debug.logTrace("create");

		super.create();
	}

	public var texts:FlxTypedGroup<FlxText>;

	function regenerateLines()
	{
		while (lines.members.length > 0)
		{
			lines.members[0].destroy();
			lines.members.remove(lines.members[0]);
		}

		while (texts.members.length > 0)
		{
			texts.members[0].destroy();
			texts.members.remove(texts.members[0]);
		}
		Debug.logTrace("removed lines and texts");

		if (_song.eventObjects != null)
			for (i in _song.eventObjects)
			{
				var seg = TimingStruct.getTimingAtBeat(i.position);

				var posi:Float = 0;

				if (seg != null)
				{
					var start:Float = (i.position - seg.startBeat) / (seg.bpm / 60);

					posi = seg.startTime + start;
				}

				var pos = getYfromStrum(posi * 1000) * zoomFactor;

				if (pos < 0)
					pos = 0;

				var type = i.type;

				var text = new FlxText(-190, pos, 0, i.name + "\n" + type + "\n" + i.value, 12);
				var line = new FlxSprite(0, pos).makeGraphic(Std.int(GRID_SIZE * 8), 4, FlxColor.BLUE);

				line.alpha = 0.2;

				lines.add(line);
				texts.add(text);

				add(line);
				add(text);
			}

		for (i in sectionRenderes)
		{
			var pos = getYfromStrum(i.section.startTime) * zoomFactor;
			i.icon.y = pos - 75;

			var line = new FlxSprite(0, pos).makeGraphic(Std.int(GRID_SIZE * 8), 4, FlxColor.BLACK);
			line.alpha = 0.4;
			lines.add(line);
		}
	}

	function addGrid(?divisions:Float = 1)
	{
		// This here is because non-integer numbers aren't supported as grid sizes, making the grid slowly 'drift' as it goes on
		var h = GRID_SIZE / divisions;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		remove(gridBG);
		gridBG = FlxGridOverlay.create(GRID_SIZE, Std.int(h), GRID_SIZE * 8, GRID_SIZE * 16);
		Debug.logTrace(gridBG.height);

		Debug.logTrace("height of " + (Math.floor(lengthInSteps)));

		var totalHeight = 0;

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(0 + gridBG.width / 2).makeGraphic(2, Std.int(Math.floor(lengthInSteps)), FlxColor.BLACK);
		add(gridBlackLine);
	}

	var stepperDiv:FlxUINumericStepper;
	var check_snap:FlxUICheckBox;
	var listOfEvents:FlxUIDropDownMenuCustom;
	var currentSelectedEventName:String = "";
	var savedType:String = "BPM Change";
	var savedValue:Dynamic = "100";
	var currentEventPosition:Float = 0;

	function containsName(name:String, events:Array<Song.Event>):Song.Event
	{
		for (i in events)
		{
			var thisName = Reflect.field(i, "name");

			if (thisName == name)
				return i;
		}
		return null;
	}

	public var chartEvents:Array<Song.Event> = [];

	public var Typeables:Array<FlxUIInputText> = [];
	
	var tab_group_events:FlxUI;

	var eventType:FlxUIDropDownMenuCustom;

	function addEventsUI()
	{
		tab_group_events = new FlxUI(null, UI_box);
		tab_group_events.name = 'Events';
		if (_song.eventObjects == null)
		{
			_song.eventObjects = [new Song.Event("Init BPM", 0, _song.bpm, "BPM Change")];
		}

		var firstEvent = "";

		if (Lambda.count(_song.eventObjects) != 0)
		{
			firstEvent = _song.eventObjects[0].name;
		}
		eventType = new FlxUIDropDownMenuCustom(10, 60, FlxUIDropDownMenuCustom.makeStrIdLabelArray(eventTypeList, true));
		var listLabel = new FlxText(10, 5, 'List of Events');
		var nameLabel = new FlxText(150, 5, 'Event Name');
		var eventName = new FlxUIInputText(150, 20, 80, "");
		var typeLabel = new FlxText(10, 45, 'Type of Event');
		var valueLabel = new FlxText(150, 45, 'Event Value');
		var eventValue = new FlxUIInputText(150, 60, 80, "");
		eventDescription = new FlxText(10, 150, 'Event Description Text');
		var lastEventType:String;
		var lastEventValue:Dynamic;
		var eventSave = new FlxButton(10, 350, "Save Event", function()
		{
			var pog:Song.Event = new Song.Event(currentSelectedEventName, currentEventPosition, savedValue,
				savedType);

			Debug.logTrace("trying to save " + currentSelectedEventName);

			var obj = containsName(pog.name, _song.eventObjects);

			if (pog.name == "")
				return;


			Debug.logTrace("yeah we can save it");

			if (obj != null)
				_song.eventObjects.remove(obj);
			_song.eventObjects.push(pog);

			Debug.logTrace(_song.eventObjects.length);

			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in _song.eventObjects)
			{
				var name = Reflect.field(i, "name");
				var type = Reflect.field(i, "type");
				var pos = Reflect.field(i, "position");
				var value = Reflect.field(i, "value");

				Debug.logTrace(i.type);
				if (type == "BPM Change")
				{
					var beat:Float = pos;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					TimingStruct.addTiming(beat, value, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}

			if (pog.type == "BPM Change")
			{
				recalculateAllSectionTimes();
				poggers();
			}

			regenerateLines();

			var listofnames = [];

			for (key => value in _song.eventObjects)
			{
				listofnames.push(value.name);
			}

			listOfEvents.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(listofnames, true));

			listOfEvents.selectedLabel = pog.name;

			lastEventType = savedType;
			lastEventValue = savedValue;

			Debug.logTrace('end');
		});		
		var posLabel = new FlxText(150, 85, 'Event Position');
		var eventPos = new FlxUIInputText(150, 100, 80, "");
		var eventAdd = new FlxButton(95, 350, "Add Event", function()
		{
			var pog:Song.Event;
			if (lastEventType != null && lastEventValue != null)
				pog = new Song.Event("New Event " + HelperFunctions.truncateFloat(curDecimalBeat, 1), curDecimalBeat, lastEventValue, lastEventType);
			else
				pog = new Song.Event("New Event " + HelperFunctions.truncateFloat(curDecimalBeat, 1), curDecimalBeat, _song.bpm, "BPM Change");


			Debug.logTrace("adding " + pog.name);

			var obj = containsName(pog.name, _song.eventObjects);

			if (obj != null)
				return;

			Debug.logTrace("yeah we can add it");

			_song.eventObjects.push(pog);

			eventName.text = pog.name;
			eventType.selectedLabel = pog.type;
			eventValue.text = pog.value + "";
			eventPos.text = pog.position + "";
			currentSelectedEventName = pog.name;
			currentEventPosition = pog.position;

			savedType = pog.type;
			savedValue = pog.value + "";

			var listofnames = [];

			for (key => value in _song.eventObjects)
			{
				listofnames.push(value.name);
			}

			listOfEvents.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(listofnames, true));

			listOfEvents.selectedLabel = pog.name;

			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in _song.eventObjects)
			{
				var name = Reflect.field(i, "name");
				var type = Reflect.field(i, "type");
				var pos = Reflect.field(i, "position");
				var value = Reflect.field(i, "value");

				Debug.logTrace(i.type);
				if (type == "BPM Change")
				{
					var beat:Float = pos;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					TimingStruct.addTiming(beat, value, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}
			Debug.logTrace("BPM CHANGES:");

			for (i in TimingStruct.AllTimings)
				Debug.logTrace(i.bpm + " - START: " + i.startBeat + " - END: " + i.endBeat + " - START-TIME: " + i.startTime);

			recalculateAllSectionTimes();

			regenerateLines();
		});
		var eventRemove = new FlxButton(180, 350, "Remove Event", function()
		{
			Debug.logTrace("lets see if we can remove " + listOfEvents.selectedLabel);

			var obj = containsName(listOfEvents.selectedLabel, _song.eventObjects);

			Debug.logTrace(obj);

			if (obj == null)
				return;

			Debug.logTrace("yeah we can remove it it");

			_song.eventObjects.remove(obj);

			var firstEvent = _song.eventObjects[0];

			if (firstEvent == null)
			{
				_song.eventObjects.push(new Song.Event("Init BPM", 0, _song.bpm, "BPM Change"));
				firstEvent = _song.eventObjects[0];
			}

			eventName.text = firstEvent.name;
			eventType.selectedLabel = firstEvent.type;
			eventValue.text = firstEvent.value + "";
			eventPos.text = firstEvent.position + "";
			currentSelectedEventName = firstEvent.name;
			currentEventPosition = firstEvent.position;

			savedType = firstEvent.type;
			savedValue = firstEvent.value + '';

			var listofnames = [];

			for (key => value in _song.eventObjects)
			{
				listofnames.push(value.name);
			}

			listOfEvents.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(listofnames, true));

			listOfEvents.selectedLabel = firstEvent.name;

			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in _song.eventObjects)
			{
				var name = Reflect.field(i, "name");
				var type = Reflect.field(i, "type");
				var pos = Reflect.field(i, "position");
				var value = Reflect.field(i, "value");

				Debug.logTrace(i.type);
				if (type == "BPM Change")
				{
					var beat:Float = pos;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					TimingStruct.addTiming(beat, value, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}

			recalculateAllSectionTimes();

			regenerateLines();
		});
		var updatePos = new FlxButton(150, 120, "Update Pos", function()
		{
			var obj = containsName(currentSelectedEventName, _song.eventObjects);
			if (obj == null)
				return;
			currentEventPosition = curDecimalBeat;
			obj.position = currentEventPosition;
			eventPos.text = currentEventPosition + "";
		});

		var listofnames = [];

		var firstEventObject = null;

		for (event in _song.eventObjects)
		{
			var name = Reflect.field(event, "name");
			var type = Reflect.field(event, "type");
			var pos = Reflect.field(event, "position");
			var value = Reflect.field(event, "value");

			Debug.logTrace(value);

			var eventt = new Song.Event(name, pos, value, type);

			chartEvents.push(eventt);
			listofnames.push(name);
		}

		_song.eventObjects = chartEvents;

		if (listofnames.length == 0)
			listofnames.push("");

		if (_song.eventObjects.length != 0)
			firstEventObject = _song.eventObjects[0];
		Debug.logTrace("bruh");

		if (firstEvent != "")
		{
			Debug.logTrace(firstEventObject);
			eventName.text = firstEventObject.name;
			Debug.logTrace("bruh");
			eventType.selectedLabel = firstEventObject.type;
			Debug.logTrace("bruh");
			eventValue.text = firstEventObject.value + "";
			Debug.logTrace("bruh");
			currentSelectedEventName = firstEventObject.name;
			Debug.logTrace("bruh");
			currentEventPosition = firstEventObject.position;
			Debug.logTrace("bruh");
			eventPos.text = currentEventPosition + "";
			Debug.logTrace("bruh");
		}

		listOfEvents = new FlxUIDropDownMenuCustom(10, 20, FlxUIDropDownMenuCustom.makeStrIdLabelArray(listofnames, true), function(name:String)
		{
			var event = containsName(listOfEvents.selectedLabel, _song.eventObjects);

			if (event == null)
				return;

			Debug.logTrace('selecting ' + name + ' found: ' + event);

			eventName.text = event.name;
			eventValue.text = event.value + "";
			eventPos.text = event.position + "";
			eventType.selectedLabel = event.type;
			currentSelectedEventName = event.name;
			currentEventPosition = event.position;
		});

		eventValue.callback = function(string:String, string2:String)
		{
			Debug.logTrace(string + " - value");
			savedValue = string;
		};

		eventType.callback = function(type:String)
		{
			savedType = eventType.selectedLabel;
		};

		eventName.callback = function(string:String, string2:String)
		{
			var obj = containsName(currentSelectedEventName, _song.eventObjects);
			if (obj == null)
			{
				currentSelectedEventName = string;
				return;
			}
			obj = containsName(string, _song.eventObjects);
			if (obj != null)
				return;
			obj = containsName(currentSelectedEventName, _song.eventObjects);
			obj.name = string;
			currentSelectedEventName = string;
		};
		Debug.logTrace("bruh");

		Typeables.push(eventPos);
		Typeables.push(eventValue);
		Typeables.push(eventName);

		//var tab_events = new FlxUI(null, UI_options);
		tab_group_events.name = "Events";
		tab_group_events.add(posLabel);
		tab_group_events.add(valueLabel);
		tab_group_events.add(nameLabel);
		tab_group_events.add(listLabel);
		tab_group_events.add(typeLabel);
		tab_group_events.add(eventName);
		tab_group_events.add(eventValue);
		tab_group_events.add(eventSave);
		tab_group_events.add(eventAdd);
		tab_group_events.add(eventRemove);
		tab_group_events.add(eventPos);
		tab_group_events.add(updatePos);
		tab_group_events.add(eventType);
		tab_group_events.add(eventDescription);
		tab_group_events.add(listOfEvents);
		//UI_options.addGroup(tab_events);
		UI_box.addGroup(tab_group_events);
	}

	#if desktop
	var waveformEnabled:FlxUICheckBox;
	#end
	function addSongUI():Void
	{		
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.songId, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			Debug.logTrace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var saveEventButton:FlxButton = new FlxButton(110, 38, "Save Events", function()
		{
			saveEvents();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.songId, true);
			//updateWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.songId.toLowerCase());
		});

		#if desktop
		waveformEnabled = new FlxUICheckBox(10, 90, null, null, "Visible Waveform", 100);
		if (FlxG.save.data.chart_waveform == null) FlxG.save.data.chart_waveform = false;
		waveformEnabled.checked = FlxG.save.data.chart_waveform;
		waveformEnabled.callback = function()
		{
			FlxG.save.data.chart_waveform = waveformEnabled.checked;
			updateWaveform();
		};
		#end

		var restart = new FlxButton(reloadSongJson.x , reloadSongJson.y + 30, "Reset Chart", function()
		{
			for (ii in 0..._song.notes.length)
			{
				for (i in 0..._song.notes[ii].sectionNotes.length)
				{
					_song.notes[ii].sectionNotes = [];
				}
			}
			resetSection(true);
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 55, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74, 55, 'BPM');

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74, 70, 'Scroll Speed');

		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 25, 0.1, 1, 0.1, 10, 1);
		#if FEATURE_STEPMANIA
		if (!PlayState.isSM)
			stepperVocalVol.value = vocals.volume;
		else
			stepperVocalVol.value = 1;
		#else
		stepperVocalVol.value = vocals.volume;
		#end
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 25, 'Vocal Volume');

		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 40, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';

		var stepperSongVolLabel = new FlxText(74, 40, 'Instrumental Volume');

		var shiftNoteDialLabel = new FlxText(10, 135, 'Shift All Notes by # Sections');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 150, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 165, 'Shift All Notes by # Steps');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 180, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 105, 'Shift All Notes by # ms');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 120, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 205, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value), Std.int(stepperShiftNoteDialstep.value), Std.int(stepperShiftNoteDialms.value));
		});

		var characters:Array<String> = Character.characterList;
		var tempMap:Map<String, Bool> = new Map<String, Bool>();
		for (i in 0...characters.length)
		{
			tempMap.set(characters[i], true);
		}
		var gfVersions:Array<String> = Character.characterList;
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/stageList'));
		var noteStyles:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/noteStyleList'));

		var player1DropDown = new FlxUIDropDownMenuCustom(150, 108, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var player1Label = new FlxText(150, 93, 64, 'Player 1');

		var player2DropDown = new FlxUIDropDownMenuCustom(150, 148, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		var player2Label = new FlxText(150, 133, 64, 'Player 2');

		var gfVersionDropDown = new FlxUIDropDownMenuCustom(150, 188, FlxUIDropDownMenuCustom.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
		{
			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfVersionDropDown);

		var gfVersionLabel = new FlxText(150, 173, 64, 'Girlfriend');

		var stageDropDown = new FlxUIDropDownMenuCustom(150, 228, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var stageLabel = new FlxText(150, 213, 64, 'Stage');

		var noteStyleDropDown = new FlxUIDropDownMenu(10, 300, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String)
		{
			_song.noteStyle = noteStyles[Std.parseInt(noteStyle)];
		});
		noteStyleDropDown.selectedLabel = _song.noteStyle;

		var noteStyleLabel = new FlxText(10, 280, 64, 'Note Skin');

		var hideGF = new FlxUICheckBox(10, 235, null, null, "Hide GF", 100);
		hideGF.checked = _song.hideGF;
		hideGF.callback = function()
		{
			_song.hideGF = hideGF.checked;
		};
		var hitsounds = new FlxUICheckBox(waveformEnabled.x, waveformEnabled.y + 30, null, null, "Play hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var check_mute_inst = new FlxUICheckBox(waveformEnabled.x, hitsounds.y + 30, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		check_snap = new FlxUICheckBox(restart.x, check_mute_inst.y + 30, null, null, "Snap to grid", 100);
		check_snap.checked = defaultSnap;
		// _song.needsVoices = check_voices.checked;
		check_snap.callback = function()
		{
			defaultSnap = check_snap.checked;
			Debug.logTrace('CHECKED!');
		};

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		// tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEventButton);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(stageLabel);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(gfVersionLabel);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(player2Label);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player1Label);
		tab_group_song.add(hideGF);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(shiftNoteDialLabel);
		tab_group_song.add(stepperShiftNoteDial);
		tab_group_song.add(shiftNoteDialLabel2);
		tab_group_song.add(stepperShiftNoteDialstep);
		tab_group_song.add(shiftNoteDialLabel3);
		tab_group_song.add(stepperShiftNoteDialms);
		tab_group_song.add(shiftNoteButton);

		var tab_group_chartshit = new FlxUI(null, UI_box);
		tab_group_chartshit.name = "Charting";
		tab_group_chartshit.add(noteStyleDropDown);
		tab_group_chartshit.add(noteStyleLabel);
		tab_group_chartshit.add(check_mute_inst);
		tab_group_chartshit.add(hitsounds);
		tab_group_chartshit.add(stepperVocalVol);
		tab_group_chartshit.add(stepperVocalVolLabel);
		tab_group_chartshit.add(stepperSongVol);
		tab_group_chartshit.add(stepperSongVolLabel);
		#if desktop
		//tab_group_chartshit.add(waveformEnabled);
		#end

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_chartshit);

		camFollow = new FlxObject(280, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_CPUAltAnim:FlxUICheckBox;
	var check_GFAltAnim:FlxUICheckBox;
	var check_GFSection:FlxUICheckBox;
	var check_playerAltAnim:FlxUICheckBox;
	var stepperSectionLength:FlxUINumericStepper;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174, 132, 'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			var secit = _song.notes[curSection];

			if (secit != null)
			{
				var secit = _song.notes[curSection];

				if (secit != null)
				{
					swapSection(secit);
				}
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Camera Points to Player?", 100, null, function()
		{
			var sect = lastUpdatedSection;

			Debug.logTrace(sect);

			if (sect == null)
				return;

			sect.mustHitSection = check_mustHitSection.checked;
			updateHeads();

			for (i in sectionRenderes)
			{
				if (i.section.startTime == sect.startTime)
				{
					var cachedY = i.icon.y;
					remove(i.icon);
					var sectionicon = check_mustHitSection.checked ? new HealthIcon(getCharacterIcon(_song.player1)).clone() : new HealthIcon(getCharacterIcon(_song.player2)).clone();
					sectionicon.x = -95;
					sectionicon.y = cachedY;
					sectionicon.setGraphicSize(0, 45);

					i.icon = sectionicon;
					i.lastUpdated = sect.mustHitSection;

					add(sectionicon);
				}
			}
		});
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_CPUAltAnim = new FlxUICheckBox(10, 340, null, null, "CPU Alternate Animation", 100);
		check_CPUAltAnim.name = 'check_CPUAltAnim';

		check_GFAltAnim = new FlxUICheckBox(10, 300, null, null, "GF Alternate Animation", 100);
		check_GFAltAnim.name = 'check_GFAltAnim';

		stepperSectionLength = new FlxUINumericStepper(180, 30, 1, 1, 1.0, 5000.0, 1);
		stepperSectionLength.value = _song.notes[curSection].lengthInSteps;
		stepperSectionLength.name = 'sectionLength';

		check_GFSection = new FlxUICheckBox(180, 300, null, null, "GF Section", 100, null, function()
			{
				var sect = lastUpdatedSection;
	
				Debug.logTrace(sect);
	
				if (sect == null)
					return;
	
				sect.gfSection = check_GFSection.checked;
				updateHeads();
	
				for (i in sectionRenderes)
				{
					if (i.section.startTime == sect.startTime)
					{
						var cachedY = i.icon.y;
						remove(i.icon);
						var sectionicon;
						if (check_GFSection.checked)
							sectionicon = new HealthIcon(getCharacterIcon(_song.gfVersion)).clone();
						else if (check_mustHitSection.checked)
							sectionicon = new HealthIcon(getCharacterIcon(_song.player1)).clone();
						else
							sectionicon = new HealthIcon(getCharacterIcon(_song.player2)).clone();
						sectionicon.x = -95;
						sectionicon.y = cachedY;
						sectionicon.setGraphicSize(0, 45);
	
						i.icon = sectionicon;
						i.lastUpdated = sect.mustHitSection;
	
						add(sectionicon);
					}
				}
			});
		check_GFSection.name = 'check_GFSection';

		check_playerAltAnim = new FlxUICheckBox(180, 340, null, null, "Player Alternate Animation", 100);
		check_playerAltAnim.name = 'check_playerAltAnim';

		var refresh = new FlxButton(10, 60, 'Refresh Section', function()
		{
			var section = getSectionByTime(Conductor.songPosition);

			if (section == null)
				return;

			check_mustHitSection.checked = section.mustHitSection;
			check_CPUAltAnim.checked = section.CPUAltAnim;
			check_GFSection.checked = section.gfSection;
			check_GFAltAnim.checked = section.gfAltAnim;
			check_playerAltAnim.checked = section.playerAltAnim;
			stepperSectionLength.value = section.lengthInSteps;
		});

		var startSection:FlxButton = new FlxButton(10, 85, "Play Here", function()
		{
			autosaveSong();
			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if (!PlayState.isSM)
				vocals.stop();
			PlayState.startTime = _song.notes[curSection].startTime;
			while (curRenderedNotes.members.length > 0)
			{
				curRenderedNotes.remove(curRenderedNotes.members[0], true);
			}

			while (curRenderedSustains.members.length > 0)
			{
				curRenderedSustains.remove(curRenderedSustains.members[0], true);
			}

			while (sectionRenderes.members.length > 0)
			{
				sectionRenderes.remove(sectionRenderes.members[0], true);
			}
			var toRemove = [];

			for (i in _song.notes)
			{
				if (i.startTime > FlxG.sound.music.length)
					toRemove.push(i);
			}

			for (i in toRemove)
				_song.notes.remove(i);

			toRemove = []; // clear memory
			LoadingState.loadAndSwitchState(new PlayState());
		});

		tab_group_section.add(refresh);
		tab_group_section.add(startSection);
		// tab_group_section.add(stepperCopy);
		// tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_CPUAltAnim);
		tab_group_section.add(new FlxText(stepperSectionLength.x, stepperSectionLength.y - 18, 0, 'Length in steps: \n do literally nothing'));
		tab_group_section.add(stepperSectionLength);
		tab_group_section.add(check_GFAltAnim);
		tab_group_section.add(check_GFSection);
		tab_group_section.add(check_playerAltAnim);
		// tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;
	

	function goToSection(section:Int)
	{
		var beat = section * 4;
		var data = TimingStruct.getTimingAtBeat(beat);

		if (data == null)
			return;

		FlxG.sound.music.time = (data.startTime + ((beat - data.startBeat) / (data.bpm / 60))) * 1000;
		if (!PlayState.isSM)
			vocals.time = FlxG.sound.music.time;
		curSection = section;
		Debug.logTrace("Going too " + FlxG.sound.music.time + " | " + section + " | Which is at " + beat);

		if (FlxG.sound.music.time < 0)
			FlxG.sound.music.time = 0;
		else if (FlxG.sound.music.time > FlxG.sound.music.length)
			FlxG.sound.music.time = FlxG.sound.music.length;

		claps.splice(0, claps.length);
	}

	public var check_naltAnim:FlxUICheckBox;
	var noteTypeDropDown:FlxUIDropDownMenuCustom;

	function addNoteUI():Void
	{
		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		writingNotesText = new FlxUIText(20, 100, 0, "");
		writingNotesText.setFormat("Arial", 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16 * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var key:Int = 0;
		var displayNameList:Array<String> = [];
		while (key < noteTypeList.length) {
			displayNameList.push(noteTypeList[key]);
			noteTypeIntMap.set(key, noteTypeList[key]);
			noteTypeMap.set(noteTypeList[key], key);
			key++;
		}

		for (i in 1...displayNameList.length) {
			displayNameList[i] = i + '. ' + displayNameList[i];
		}

		noteTypeDropDown = new FlxUIDropDownMenuCustom(10, 75, FlxUIDropDownMenuCustom.makeStrIdLabelArray(displayNameList, true), function(character:String)
			{
				noteType = Std.parseInt(character);
				if(curSelectedNote != null) 
				{
					for (i in selectedBoxes)
						{
							i.connectedNoteData[5] = noteTypeIntMap.get(noteType);
		
							for (ii in _song.notes)
							{
								for (n in ii.sectionNotes)
									if (n[0] == i.connectedNoteData[0] && n[1] == i.connectedNoteData[1])
										n[5] = i.connectedNoteData[5];
							}
						}
					//curSelectedNote[5] = noteType;
					updateGrid();
					updateNoteUI();
				}
			});
		blockPressWhileScrolling.push(noteTypeDropDown);

		check_naltAnim = new FlxUICheckBox(10, 150, null, null, "Toggle Alternative Animation", 100);
		check_naltAnim.callback = function()
		{
			if (curSelectedNote != null)
			{
				for (i in selectedBoxes)
				{
					i.connectedNoteData[3] = check_naltAnim.checked;

					for (ii in _song.notes)
					{
						for (n in ii.sectionNotes)
							if (n[0] == i.connectedNoteData[0] && n[1] == i.connectedNoteData[1])
								n[3] = i.connectedNoteData[3];
					}
				}
			}
		}

		var stepperSusLengthLabel = new FlxText(74, 10, 'Note Sustain Length');


		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(check_naltAnim);
		tab_group_note.add(noteTypeDropDown);

		UI_box.addGroup(tab_group_note);
	}

	function pasteNotesFromArray(array:Array<Array<Dynamic>>, fromStrum:Bool = true)
	{
		for (i in array)
		{
			var strum:Float = i[0];
			if (fromStrum)
				strum += Conductor.songPosition;
			var section = 0;
			for (ii in _song.notes)
			{
				if (ii.startTime <= strum && ii.endTime > strum)
				{
					Debug.logTrace("new strum " + strum + " - at section " + section);
					// alright we're in this section lets paste the note here.
					var newData = [strum, i[1], i[2], i[3], i[4]];
					ii.sectionNotes.push(newData);

					var thing = ii.sectionNotes[ii.sectionNotes.length - 1];

					var note:Note = new Note(strum, Math.floor(i[1] % 4), null, false, true, i[3], i[4]);
					note.rawNoteData = i[1];
					note.sustainLength = i[2];
					note.setGraphicSize(Math.floor(GRID_SIZE), Math.floor(GRID_SIZE));
					note.updateHitbox();
					note.x = Math.floor(i[1] * GRID_SIZE);

					note.charterSelected = true;

					note.y = Math.floor(getYfromStrum(strum) * zoomFactor);

					var box = new ChartingBox(note.x, note.y, note);
					box.connectedNoteData = thing;
					selectedBoxes.add(box);

					curRenderedNotes.add(note);

					pastedNotes.push(note);

					if (note.sustainLength > 0)
					{
						var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
							note.y + GRID_SIZE).makeGraphic(8, Math.floor((getYfromStrum(note.strumTime + note.sustainLength) * zoomFactor) - note.y));

						note.noteCharterObject = sustainVis;

						curRenderedSustains.add(sustainVis);
					}
					Debug.logTrace("section new length: " + ii.sectionNotes.length);
					continue;
				}
				section++;
			}
		}
	}

	function offsetSelectedNotes(offset:Float)
	{
		var toDelete:Array<Note> = [];
		var toAdd:Array<ChartingBox> = [];

		// For each selected note...
		for (i in 0...selectedBoxes.members.length)
		{
			var originalNote = selectedBoxes.members[i].connectedNote;
			// Delete after the fact to avoid tomfuckery.
			toDelete.push(originalNote);

			var strum = originalNote.strumTime + offset;
			// Remove the old note.
			// Find the position in the song to put the new note.
			for (ii in _song.notes)
			{
				if (ii.startTime <= strum && ii.endTime > strum)
				{
					// alright we're in this section lets paste the note here.
					var newData:Array<Dynamic> = [
						strum,
						originalNote.rawNoteData,
						originalNote.sustainLength,
						originalNote.isAlt,
						originalNote.beat
					];
					ii.sectionNotes.push(newData);

					var thing = ii.sectionNotes[ii.sectionNotes.length - 1];

					var note:Note = new Note(strum, originalNote.noteData, originalNote.prevNote, originalNote.isSustainNote, true, originalNote.isAlt,
						originalNote.beat);
					note.rawNoteData = originalNote.rawNoteData;
					note.sustainLength = originalNote.sustainLength;
					note.setGraphicSize(Math.floor(GRID_SIZE), Math.floor(GRID_SIZE));
					note.updateHitbox();
					note.x = Math.floor(originalNote.rawNoteData * GRID_SIZE);

					note.charterSelected = true;

					note.y = Math.floor(getYfromStrum(strum) * zoomFactor);

					var box = new ChartingBox(note.x, note.y, note);
					box.connectedNoteData = thing;
					// Add to selection after the fact to avoid tomfuckery.
					toAdd.push(box);

					curRenderedNotes.add(note);

					pastedNotes.push(note);

					if (note.sustainLength > 0)
					{
						var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
							note.y + GRID_SIZE).makeGraphic(8, Math.floor((getYfromStrum(note.strumTime + note.sustainLength) * zoomFactor) - note.y));

						note.noteCharterObject = sustainVis;

						curRenderedSustains.add(sustainVis);
					}
					Debug.logTrace("section new length: " + ii.sectionNotes.length);
					continue;
				}
			}
		}
		for (note in toDelete)
		{
			deleteNote(note);
		}
		for (box in toAdd)
		{
			selectedBoxes.add(box);
		}
	}

	function loadSong(daSong:String, reloadFromFile:Bool = false):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		if (reloadFromFile)
		{
			#if FEATURE_STEPMANIA
			if (PlayState.isSM)
			{
				Debug.logTrace("Loading " + PlayState.pathToSm + "/" + PlayState.sm.header.MUSIC);
				var bytes = File.getBytes(PlayState.pathToSm + "/" + PlayState.sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(daSong), 0.6);
			#else
			FlxG.sound.playMusic(Paths.inst(daSong), 0.6);
			#end

			if (PlayState.isSM)
			{
				#if FEATURE_STEPMANIA
				_song = Song.conversionChecks(Song.loadFromJsonRAW(File.getContent(PlayState.pathToSm + "/converted.json")));
				#end
			}
			else
			{
				var diff:String = ["-easy", "", "-hard","-hardplus"][PlayState.storyDifficulty];
				_song = Song.conversionChecks(Song.loadFromJson(PlayState.SONG.songId, diff));
			}
		}
		else
		{
			_song = PlayState.SONG;
		}

		#if FEATURE_STEPMANIA
		if (PlayState.isSM)
		{
			trace("Loading " + PlayState.pathToSm + "/" + PlayState.sm.header.MUSIC);
			var bytes = File.getBytes(PlayState.pathToSm + "/" + PlayState.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
		}
		else
			FlxG.sound.playMusic(Paths.inst(daSong), 1, false);
		#else
		FlxG.sound.playMusic(Paths.inst(daSong), 1, false);
		#end
		
		#if FEATURE_STEPMANIA
		if (PlayState.isSM)
			vocals = null;
		else
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		#else
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		#end
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();

		FlxG.sound.music.time = 0;

		if (!PlayState.isSM)
			vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			if (!PlayState.isSM)
			{
				vocals.pause();
				vocals.time = 0;
			}
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case "CPU Alternate Animation":
					getSectionByTime(Conductor.songPosition).CPUAltAnim = check.checked;
				case "Player Alternate Animation":
					getSectionByTime(Conductor.songPosition).playerAltAnim = check.checked;
				case "GF Alternate Animation":
					getSectionByTime(Conductor.songPosition).gfAltAnim = check.checked;
				case "GF Section":
					getSectionByTime(Conductor.songPosition).gfSection = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);

			switch (wname)
			{
				case 'section_length':
					if (nums.value <= 4)
						nums.value = 4;
					getSectionByTime(Conductor.songPosition).lengthInSteps = Std.int(nums.value);
					updateGrid();

				case 'song_speed':
					if (nums.value <= 0)
						nums.value = 0;
					_song.speed = nums.value;

				case 'song_bpm':
					if (nums.value <= 0)
						nums.value = 1;
					_song.bpm = nums.value;

					if (_song.eventObjects[0].type != "BPM Change")
						Application.current.window.alert("i'm crying, first event isn't a bpm change. fuck you");
					else
					{
						_song.eventObjects[0].value = nums.value;
						regenerateLines();
					}

					TimingStruct.clearTimings();

					var currentIndex = 0;
					for (i in _song.eventObjects)
					{
						var name = Reflect.field(i, "name");
						var type = Reflect.field(i, "type");
						var pos = Reflect.field(i, "position");
						var value = Reflect.field(i, "value");

						Debug.logTrace(i.type);
						if (type == "BPM Change")
						{
							var beat:Float = pos;

							var endBeat:Float = Math.POSITIVE_INFINITY;

							TimingStruct.addTiming(beat, value, endBeat, 0); // offset in this case = start time since we don't have a offset

							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								var step = ((60 / data.bpm) * 1000) / 4;
								TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}

							currentIndex++;
						}
					}
					Debug.logTrace("BPM CHANGES:");

					for (i in TimingStruct.AllTimings)
						Debug.logTrace(i.bpm + " - START: " + i.startBeat + " - END: " + i.endBeat + " - START-TIME: " + i.startTime);

					recalculateAllSectionTimes();

					regenerateLines();

					poggers();

				case 'note_susLength':
					if (curSelectedNote == null)
						return;

					if (nums.value <= 0)
						nums.value = 0;
					curSelectedNote[2] = nums.value;
					updateGrid();

				case 'section_bpm':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					getSectionByTime(Conductor.songPosition).bpm = Std.int(nums.value);
					updateGrid();

				case 'song_vocalvol':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					if (!PlayState.isSM)
						vocals.volume = nums.value;

				case 'song_instvol':
					if (nums.value <= 0.1)
						nums.value = 0.1;
					FlxG.sound.music.volume = nums.value;

				case 'divisions':
					subDivisions = nums.value;
					updateGrid();

				case 'sectionLength':
					if (nums.value <= 0)
						nums.value = 1;
					getSectionByTime(Conductor.songPosition).lengthInSteps = Std.int(nums.value);
					updateGrid();
			}
		}

	}

	var updatedSection:Bool = false;

	function poggers()
	{
		var notes = [];

		Debug.logTrace("Basing everything on BPM which will in fact fuck up the sections");

		for (section in _song.notes)
		{
			var removed = [];

			for (note in section.sectionNotes)
			{
				// commit suicide
				var old = [note[0], note[1], note[2], note[3], note[4]];
				old[0] = TimingStruct.getTimeFromBeat(old[4]);
				old[2] = TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(old[0]));
				if (old[0] < section.startTime && old[0] < section.endTime)
				{
					notes.push(old);
					removed.push(note);
				}
				if (old[0] > section.endTime && old[0] > section.startTime)
				{
					notes.push(old);
					removed.push(note);
				}
			}

			for (i in removed)
			{
				section.sectionNotes.remove(i);
			}
		}

		for (section in _song.notes)
		{
			var saveRemove = [];

			for (i in notes)
			{
				if (i[0] >= section.startTime && i[0] <= section.endTime)
				{
					saveRemove.push(i);
					section.sectionNotes.push(i);
				}
			}

			for (i in saveRemove)
				notes.remove(i);
		}

		for (i in curRenderedNotes)
		{
			i.strumTime = TimingStruct.getTimeFromBeat(i.beat);
			i.y = Math.floor(getYfromStrum(i.strumTime) * zoomFactor);
			i.sustainLength = TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(i.sustainLength));
			if (i.noteCharterObject != null)
			{
				i.noteCharterObject.y = i.y + 40;
				i.noteCharterObject.makeGraphic(8, Math.floor((getYfromStrum(i.strumTime + i.sustainLength) * zoomFactor) - i.y), FlxColor.WHITE);
			}
		}

		Debug.logTrace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + _song.notes.length);
	}

	function stepStartTime(step):Float
	{
		return Conductor.bpm / (step / 4) / 60;
	}

	function sectionStartTime(?customIndex:Int = -1):Float
	{
		if (customIndex == -1)
			customIndex = curSection;
		var daBPM:Float = Conductor.bpm;
		var daPos:Float = 0;
		for (i in 0...customIndex)
		{
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = false;

	function swapSection(secit:SwagSection)
	{
		var newSwaps:Array<Array<Dynamic>> = [];
		Debug.logTrace(_song.notes[curSection]);

		haxe.ds.ArraySort.sort(secit.sectionNotes, function(a, b)
		{
			if (a[0] < b[0])
				return -1;
			else if (a[0] > b[0])
				return 1;
			else
				return 0;
		});

		for (i in 0...secit.sectionNotes.length)
		{
			var note = secit.sectionNotes[i];
			var n = [note[0], Std.int(note[1]), note[2], note[3], note[4]];
			n[1] = (note[1] + 4) % 8;
			newSwaps.push(n);
		}

		secit.sectionNotes = newSwaps;

		for (i in shownNotes)
		{
			for (ii in secit.sectionNotes)
				if (i.strumTime == ii[0] && i.noteData == ii[1] % 4)
				{
					i.x = Math.floor(ii[1] * GRID_SIZE);

					i.y = Math.floor(getYfromStrum(ii[0]) * zoomFactor);
					if (i.sustainLength > 0 && i.noteCharterObject != null)
						i.noteCharterObject.x = i.x + (GRID_SIZE / 2);
				}
		}
		updateNoteUI();
		updateGrid();
	}

	public var diff:Float = 0;

	public var changeIndex = 0;

	public var currentBPM:Float = 0;
	public var lastBPM:Float = 0;

	public var updateFrame = 0;
	public var lastUpdatedSection:SwagSection = null;

	public function resizeEverything()
	{
		regenerateLines();

		for (i in curRenderedNotes.members)
		{
			if (i == null)
				continue;
			i.y = getYfromStrum(i.strumTime) * zoomFactor;
			if (i.noteCharterObject != null)
			{
				curRenderedSustains.remove(i.noteCharterObject);
				var sustainVis:FlxSprite = new FlxSprite(i.x + (GRID_SIZE / 2),
					i.y + GRID_SIZE).makeGraphic(8, Math.floor((getYfromStrum(i.strumTime + i.sustainLength) * zoomFactor) - i.y), FlxColor.WHITE);

				i.noteCharterObject = sustainVis;
				curRenderedSustains.add(i.noteCharterObject);
			}
		}
	}

	public var shownNotes:Array<Note> = [];

	public var snapSelection = 3;

	public var selectedBoxes:FlxTypedGroup<ChartingBox>;

	public var waitingForRelease:Bool = false;
	public var selectBox:FlxSprite;

	public var copiedNotes:Array<Array<Dynamic>> = [];
	public var pastedNotes:Array<Note> = [];
	public var deletedNotes:Array<Array<Dynamic>> = [];

	public var selectInitialX:Float = 0;
	public var selectInitialY:Float = 0;

	public var lastAction:String = "";

	override function update(elapsed:Float)
	{
		try
		{
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.time > FlxG.sound.music.length - 85)
				{
					FlxG.sound.music.pause();
					FlxG.sound.music.time = FlxG.sound.music.length - 85;
					if (!PlayState.isSM)
					{
						vocals.pause();
						vocals.time = vocals.length - 85;
					}
				}

			#if debug
			FlxG.watch.addQuick("Renderers", sectionRenderes.length);
			FlxG.watch.addQuick("Notes", curRenderedNotes.length);
			FlxG.watch.addQuick("Rendered Notes ", shownNotes.length);
			#end

			for (i in sectionRenderes)
			{
				var diff = i.y - strumLine.y;
				if (diff < 2000 && diff >= -2000)
				{
					i.active = true;
					i.visible = true;
				}
				else
				{
					i.active = false;
					i.visible = false;
				}
			}

			shownNotes = [];

			if (FlxG.sound.music != null)
			{
				if (FlxG.sound.music.playing)
				{
					@:privateAccess
					{
						#if desktop
						// The __backend.handle attribute is only available on native.
						lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
						try
						{
							// We need to make CERTAIN vocals exist and are non-empty
							// before we try to play them. Otherwise the game crashes.
							if (vocals != null && vocals.length > 0)
							{
								lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
							}
						}
						catch (e)
						{
							// Debug.logTrace("failed to pitch vocals (probably cuz they don't exist)");
						}
						#end
					}
				}
			}

			for (note in curRenderedNotes)
			{
				var diff = note.strumTime - Conductor.songPosition;
				if (diff < 8000 && diff >= -8000)
				{
					shownNotes.push(note);
					if (note.sustainLength > 0)
					{
						note.noteCharterObject.active = true;
						note.noteCharterObject.visible = true;
					}
					note.active = true;
					note.visible = true;
				}
				else
				{
					note.active = false;
					note.visible = false;
					if (note.sustainLength > 0)
					{
						if (note.noteCharterObject != null)
							if (note.noteCharterObject.y != note.y + GRID_SIZE)
							{
								note.noteCharterObject.active = false;
								note.noteCharterObject.visible = false;
							}
					}
				}
			}

			for (ii in selectedBoxes.members)
			{
				ii.x = ii.connectedNote.x;
				ii.y = ii.connectedNote.y;
			}

			var doInput = true;

			var blockInput = false;

			for (i in Typeables)
			{
				if (i.hasFocus)
					doInput = false;
			}

			if(!blockInput) {
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
			}

			if (PlayerSettings.player1.controls.BACK)
				{
					autosaveSong();
					FlxG.sound.playMusic(Paths.music(MenuMusicStuff.getMusicByID(FlxG.save.data.menuMusic)), 0);
					PlayState.chartingMode = false;
					if (PlayState.isExtras)
						MusicBeatState.switchState(new SecretState());
					else if (PlayState.isFreeplay)
						MusicBeatState.switchState(new FreeplayState());
					else if (PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new MainMenuState());
				}

			if (doInput && !blockInput)
			{
				if (FlxG.mouse.wheel != 0)
				{
					FlxG.sound.music.pause();

					if (!PlayState.isSM)
						vocals.pause();
					claps.splice(0, claps.length);

					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.8);
					if(vocals != null) {
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
					}

					Conductor.songPosition = FlxG.sound.music.time;

					if (FlxG.keys.pressed.CONTROL && !waitingForRelease)
					{
						var amount = FlxG.mouse.wheel;

						if (amount > 0)
							amount = 0;

						var increase:Float = 0;

						if (amount < 0)
							increase = -0.02;
						else
							increase = 0.02;

						zoomFactor += increase;

						if (zoomFactor > 2)
							zoomFactor = 2;

						if (zoomFactor < 0.1)
							zoomFactor = 0.1;

						resizeEverything();
					}
					else
					{
						var amount = FlxG.mouse.wheel;

						if (amount > 0 && strumLine.y < 0)
							amount = 0;

						if (doSnapShit)
						{
							var increase:Float = 0;
							var beats:Float = 0;

							if (amount < 0)
							{
								increase = 1 / deezNuts.get(snap);
								beats = (Math.floor((curDecimalBeat * deezNuts.get(snap)) + 0.001) / deezNuts.get(snap)) + increase;
							}
							else
							{
								increase = -1 / deezNuts.get(snap);
								beats = ((Math.ceil(curDecimalBeat * deezNuts.get(snap)) - 0.001) / deezNuts.get(snap)) + increase;
							}

							Debug.logTrace("SNAP - " + snap + " INCREASE - " + increase + " - GO TO BEAT " + beats);

							var data = TimingStruct.getTimingAtBeat(beats);

							if (beats <= 0)
								FlxG.sound.music.time = 0;

							var bpm = data != null ? data.bpm : _song.bpm;

							if (data != null)
							{
								FlxG.sound.music.time = (data.startTime + ((beats - data.startBeat) / (bpm / 60))) * 1000;
							}
						}
						else
							FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);

						if (!PlayState.isSM)
							vocals.time = FlxG.sound.music.time;
					}
				}

				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						speed += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						speed -= 0.1;

					if (speed > 3)
						speed = 3;
					if (speed <= 0.01)
						speed = 0.1;
				}
				else
				{
					if (FlxG.keys.justPressed.RIGHT && !FlxG.keys.pressed.CONTROL)
						goToSection(curSection + 1);
					else if (FlxG.keys.justPressed.LEFT && !FlxG.keys.pressed.CONTROL)
						goToSection(curSection - 1);
				}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.A)
				{
					for (i in curRenderedNotes)
						{
							selectNote(i, false);							
						}			
				}

				if (FlxG.mouse.pressed && FlxG.keys.pressed.CONTROL)
				{
					if (!waitingForRelease)
					{
						Debug.logTrace("creating select box");
						waitingForRelease = true;
						selectBox = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
						selectBox.makeGraphic(0, 0, FlxColor.fromRGB(173, 216, 230));
						selectBox.alpha = 0.4;

						selectInitialX = selectBox.x;
						selectInitialY = selectBox.y;

						add(selectBox);
					}
					else
					{
						if (waitingForRelease)
						{
							Debug.logTrace(selectBox.width + " | " + selectBox.height);
							selectBox.x = Math.min(FlxG.mouse.x, selectInitialX);
							selectBox.y = Math.min(FlxG.mouse.y, selectInitialY);

							selectBox.makeGraphic(Math.floor(Math.abs(FlxG.mouse.x - selectInitialX)), Math.floor(Math.abs(FlxG.mouse.y - selectInitialY)),
								FlxColor.fromRGB(173, 216, 230));
						}
					}
				}
				if (FlxG.mouse.justReleased && waitingForRelease)
				{
					Debug.logTrace("released!");
					waitingForRelease = false;

					while (selectedBoxes.members.length != 0 && selectBox.width > 10 && selectBox.height > 10)
					{
						selectedBoxes.members[0].connectedNote.charterSelected = false;
						selectedBoxes.members[0].destroy();
						selectedBoxes.members.remove(selectedBoxes.members[0]);
					}

					for (i in curRenderedNotes)
					{
						if (i.overlaps(selectBox) && !i.charterSelected)
						{
							Debug.logTrace("seleting " + i.strumTime);
							selectNote(i, false);
						}
					}
					selectBox.destroy();
					remove(selectBox);
				}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.D)
				{
					lastAction = "delete";
					var notesToBeDeleted = [];
					deletedNotes = [];
					for (i in 0...selectedBoxes.members.length)
					{
						deletedNotes.push([
							selectedBoxes.members[i].connectedNote.strumTime,
							selectedBoxes.members[i].connectedNote.rawNoteData,
							selectedBoxes.members[i].connectedNote.sustainLength
						]);
						notesToBeDeleted.push(selectedBoxes.members[i].connectedNote);
					}

					for (i in notesToBeDeleted)
					{
						deleteNote(i);
					}
				}

				if (FlxG.keys.justPressed.DELETE)
				{
					lastAction = "delete";
					var notesToBeDeleted = [];
					deletedNotes = [];
					for (i in 0...selectedBoxes.members.length)
					{
						deletedNotes.push([
							selectedBoxes.members[i].connectedNote.strumTime,
							selectedBoxes.members[i].connectedNote.rawNoteData,
							selectedBoxes.members[i].connectedNote.sustainLength
						]);
						notesToBeDeleted.push(selectedBoxes.members[i].connectedNote);
					}

					for (i in notesToBeDeleted)
					{
						deleteNote(i);
					}
				}

				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
				{
					var offsetSteps = FlxG.keys.pressed.CONTROL ? 16 : 1;
					var offsetSeconds = Conductor.stepCrochet * offsetSteps;

					var offset:Float = 0;
					if (FlxG.keys.justPressed.UP)
						offset -= offsetSeconds;
					if (FlxG.keys.justPressed.DOWN)
						offset += offsetSeconds;

					offsetSelectedNotes(offset);
				}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.C)
				{
					if (selectedBoxes.members.length != 0)
					{
						copiedNotes = [];
						for (i in selectedBoxes.members)
							copiedNotes.push([
								i.connectedNote.strumTime,
								i.connectedNote.rawNoteData,
								i.connectedNote.sustainLength,
								i.connectedNote.isAlt,
								i.connectedNote.beat
							]);

						var firstNote = copiedNotes[0][0];

						for (i in copiedNotes) // normalize the notes
						{
							i[0] = i[0] - firstNote;
							Debug.logTrace("Normalized time: " + i[0] + " | " + i[1]);
						}

						Debug.logTrace(copiedNotes.length);
					}
				}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V)
				{
					if (copiedNotes.length != 0)
					{
						while (selectedBoxes.members.length != 0)
						{
							selectedBoxes.members[0].connectedNote.charterSelected = false;
							selectedBoxes.members[0].destroy();
							selectedBoxes.members.remove(selectedBoxes.members[0]);
						}

						Debug.logTrace("Pasting " + copiedNotes.length);

						pasteNotesFromArray(copiedNotes);

						lastAction = "paste";
					}
				}

				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Z)
				{
					switch (lastAction)
					{
						case "paste":
							Debug.logTrace("undo paste");
							if (pastedNotes.length != 0)
							{
								for (i in pastedNotes)
								{
									if (curRenderedNotes.members.contains(i))
										deleteNote(i);
								}

								pastedNotes = [];
							}
						case "delete":
							Debug.logTrace("undoing delete");
							if (deletedNotes.length != 0)
							{
								Debug.logTrace("undoing delete");
								pasteNotesFromArray(deletedNotes, false);
								deletedNotes = [];
							}
					}
				}
			}

			if (updateFrame == 4)
			{
				TimingStruct.clearTimings();

				var currentIndex = 0;
				for (i in _song.eventObjects)
				{
					if (i.type == "BPM Change")
					{
						var beat:Float = i.position;

						var endBeat:Float = Math.POSITIVE_INFINITY;

						TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
							var step = ((60 / data.bpm) * 1000) / 4;
							TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
					}
				}

				recalculateAllSectionTimes();

				regenerateLines();
				updateFrame++;
			}
			else if (updateFrame != 5)
				updateFrame++;

			snapText.text = "";

			if (FlxG.keys.justPressed.RIGHT && FlxG.keys.pressed.CONTROL)
			{
				snapSelection++;
				var index = 6;
				if (snapSelection > 6)
					snapSelection = 6;
				if (snapSelection < 0)
					snapSelection = 0;
				for (v in deezNuts.keys())
				{
					Debug.logTrace(v);
					if (index == snapSelection)
					{
						Debug.logTrace("found " + v + " at " + index);
						snap = v;
					}
					index--;
				}
				Debug.logTrace("new snap " + snap + " | " + snapSelection);
			}
			if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.CONTROL)
			{
				snapSelection--;
				if (snapSelection > 6)
					snapSelection = 6;
				if (snapSelection < 0)
					snapSelection = 0;
				var index = 6;
				for (v in deezNuts.keys())
				{
					Debug.logTrace(v);
					if (index == snapSelection)
					{
						Debug.logTrace("found " + v + " at " + index);
						snap = v;
					}
					index--;
				}
				Debug.logTrace("new snap " + snap + " | " + snapSelection);
			}

			if (FlxG.keys.justPressed.SHIFT)
				doSnapShit = !doSnapShit;

			doSnapShit = defaultSnap;
			if (FlxG.keys.pressed.SHIFT)
			{
				doSnapShit = !defaultSnap;
			}

			check_snap.checked = doSnapShit;

			Conductor.songPosition = FlxG.sound.music.time;
			_song.songId = typingShit.text;

			var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

			var start = Conductor.songPosition;

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;
				currentBPM = timingSegBpm;

				if (currentBPM != Conductor.bpm)
				{
					Debug.logTrace("BPM CHANGE to " + currentBPM);
					Conductor.changeBPM(currentBPM, false);
				}

				var pog:Float = (curDecimalBeat - timingSeg.startBeat) / (Conductor.bpm / 60);

				start = (timingSeg.startTime + pog) * 1000;
			}

			var weird = getSectionByTime(start, true);

			FlxG.watch.addQuick("Section", weird);

			if (weird != null)
			{
				if (lastUpdatedSection != getSectionByTime(start, true))
				{
					lastUpdatedSection = weird;
					check_mustHitSection.checked = weird.mustHitSection;
					check_CPUAltAnim.checked = weird.CPUAltAnim;
					check_playerAltAnim.checked = weird.playerAltAnim;
					check_GFSection.checked = weird.gfSection;
					check_GFAltAnim.checked = weird.gfAltAnim;
					stepperSectionLength.value = weird.lengthInSteps;
				}
			}

			strumLine.y = getYfromStrum(start) * zoomFactor;
			camFollow.y = strumLine.y;

			bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
				+ " / "
				+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
				+ "\nCur Section: "
				+ curSection
				+ "\nCurBeat: "
				+ HelperFunctions.truncateFloat(curDecimalBeat, 3)
				+ "\nCurStep: "
				+ curStep
				+ "\nZoom: "
				+ HelperFunctions.truncateFloat(zoomFactor, 2)
				+ "\nSpeed: "
				+ HelperFunctions.truncateFloat(speed, 1)
				+ "\nCurTime: "
				+ FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false)
				+ '\nCurZoom: '
				+ zoomFactor
				+ ' (Default: 0.4)'
				+ "\n\nSnap: "
				+ snap
				+ "\n"
				+ (doSnapShit ? "Snap enabled" : "Snap disabled")
				+
				(FlxG.save.data.showHelp ? "\n\nHelp:\nCtrl-MWheel : Zoom in/out\nShift-Left/Right :\nChange playback speed\nCtrl-Drag Click : Select notes\nCtrl-A : Select all notes\nCtrl-C : Copy notes\nCtrl-V : Paste notes\nCtrl-Z : Undo\nDelete : Delete selection\nCTRL-Left/Right :\n  Change Snap\nHold Shift : Disable Snap\nClick or 1/2/3/4/5/6/7/8 :\n  Place notes\nUp/Down :\n  Move selected notes 1 step\nShift-Up/Down :\n  Move selected notes 1 beat\nSpace: Play Music\nEnter : Preview\nPress F1 to hide/show this!" : "");

			var left = FlxG.keys.justPressed.ONE;
			var down = FlxG.keys.justPressed.TWO;
			var up = FlxG.keys.justPressed.THREE;
			var right = FlxG.keys.justPressed.FOUR;
			var leftO = FlxG.keys.justPressed.FIVE;
			var downO = FlxG.keys.justPressed.SIX;
			var upO = FlxG.keys.justPressed.SEVEN;
			var rightO = FlxG.keys.justPressed.EIGHT;

			if (FlxG.keys.justPressed.F1)
				FlxG.save.data.showHelp = !FlxG.save.data.showHelp;

			var pressArray = [left, down, up, right, leftO, downO, upO, rightO];
			var delete = false;
			if (doInput)
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (strumLine.overlaps(note) && pressArray[Math.floor(Math.abs(note.rawNoteData))])
					{
						deleteNote(note);
						delete = true;
						Debug.logTrace('deelte note');
					}
				});
				for (p in 0...pressArray.length)
				{
					var i = pressArray[p];
					if (i && !delete)
					{
						addNote(new Note(Conductor.songPosition, p));
					}
				}
			}

			if (playClaps)
			{
				for (note in shownNotes)
				{
					if (note.strumTime <= Conductor.songPosition && !claps.contains(note) && FlxG.sound.music.playing)
					{
						claps.push(note);
						FlxG.sound.play(Paths.sound('SNAP'));
					}
				}
			}

			FlxG.watch.addQuick('daBeat', curDecimalBeat);

			if (FlxG.mouse.justPressed && !waitingForRelease)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								selectNote(note, false);
							}
							else
							{
								deleteNote(note);
							}
						}
					});
				}
				else
				{
					if (FlxG.mouse.x > 0 && FlxG.mouse.x < 0 + gridBG.width && FlxG.mouse.y > 0 && FlxG.mouse.y < 0 + height)
					{
						FlxG.log.add('added note');
						addNote();
					}
				}
			}

			if (FlxG.mouse.x > 0 && FlxG.mouse.x < gridBG.width && FlxG.mouse.y > 0 && FlxG.mouse.y < height)
			{
				dummyArrow.visible = true;

				dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;

				if (doSnapShit)
				{
					var time = getStrumTime(FlxG.mouse.y / zoomFactor);

					var beat = TimingStruct.getBeatFromTime(time);
					var snapped = Math.round(beat * deezNuts.get(snap)) / deezNuts.get(snap);

					dummyArrow.y = getYfromStrum(TimingStruct.getTimeFromBeat(snapped)) * zoomFactor;
				}
				else
				{
					dummyArrow.y = FlxG.mouse.y;
				}
			}
			else
			{
				dummyArrow.visible = false;
			}

			if (doInput)
			{
				if (FlxG.keys.justPressed.ENTER)
				{
					autosaveSong();
					lastSection = curSection;

					PlayState.SONG = _song;
					FlxG.sound.music.stop();
					if (!PlayState.isSM)
						vocals.stop();

					while (curRenderedNotes.members.length > 0)
					{
						curRenderedNotes.remove(curRenderedNotes.members[0], true);
					}

					while (curRenderedSustains.members.length > 0)
					{
						curRenderedSustains.remove(curRenderedSustains.members[0], true);
					}

					while (sectionRenderes.members.length > 0)
					{
						sectionRenderes.remove(sectionRenderes.members[0], true);
					}

					var toRemove = [];

					for (i in _song.notes)
					{
						if (i.startTime > FlxG.sound.music.length)
							toRemove.push(i);
					}

					for (i in toRemove)
						_song.notes.remove(i);

					toRemove = []; // clear memory

					LoadingState.loadAndSwitchState(new PlayState());
				}

				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(((60 / (timingSeg != null ? timingSeg.bpm : _song.bpm)) * 1000) / 4);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-(((60 / (timingSeg != null ? timingSeg.bpm : _song.bpm)) * 1000) / 4));
				}

				if (FlxG.keys.justPressed.C && !FlxG.keys.pressed.CONTROL)
				{
					var sect = _song.notes[curSection];

					Debug.logTrace(sect);

					sect.mustHitSection = !sect.mustHitSection;
					updateHeads();
					check_mustHitSection.checked = sect.mustHitSection;
					check_GFSection.checked = sect.gfSection;
					var i = sectionRenderes.members[curSection];
					var cachedY = i.icon.y;
					remove(i.icon);
					var sectionicon = null;
					if (sect.gfSection)
						sectionicon = new HealthIcon(getCharacterIcon(_song.gfVersion)).clone();
					else
						sectionicon = sect.mustHitSection ? new HealthIcon(getCharacterIcon(_song.player1)).clone() : new HealthIcon(getCharacterIcon(_song.player2)).clone();
					sectionicon.x = -95;
					sectionicon.y = cachedY;
					sectionicon.setGraphicSize(0, 45);

					i.icon = sectionicon;
					i.lastUpdated = sect.mustHitSection;

					add(sectionicon);
					Debug.logTrace("must hit " + sect.mustHitSection);
				}
				if (FlxG.keys.justPressed.V && !FlxG.keys.pressed.CONTROL)
				{
					Debug.logTrace("swap");
					var secit = _song.notes[curSection];

					if (secit != null)
					{
						swapSection(secit);
					}
				}

				if (FlxG.keys.justPressed.TAB)
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						UI_box.selected_tab -= 1;
						if (UI_box.selected_tab < 0)
							UI_box.selected_tab = 2;
					}
					else
					{
						UI_box.selected_tab += 1;
						if (UI_box.selected_tab >= 3)
							UI_box.selected_tab = 0;
					}
				}

				if (!typingShit.hasFocus)
				{
					var shiftThing:Int = 1;
					if (FlxG.keys.pressed.SHIFT)
						shiftThing = 4;
					if (FlxG.keys.justPressed.SPACE)
					{
						if (FlxG.sound.music.playing)
							{
								FlxG.sound.music.pause();
								if(vocals != null) vocals.pause();
							}
							else
							{
								if(vocals != null) {
									vocals.play();
									vocals.pause();
									vocals.time = FlxG.sound.music.time;
									vocals.play();
								}
								FlxG.sound.music.play(false, FlxG.sound.music.time);
							}
					}

					if (FlxG.sound.music.time < 0 || curDecimalBeat < 0)
						FlxG.sound.music.time = 0;

					if (!FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
						{
							FlxG.sound.music.pause();
							if (!PlayState.isSM)
								vocals.pause();
							claps.splice(0, claps.length);

							var daTime:Float = 700 * FlxG.elapsed;

							if (FlxG.keys.pressed.W)
							{
								FlxG.sound.music.time -= daTime;
							}
							else
								FlxG.sound.music.time += daTime;

							if (!PlayState.isSM)
								vocals.time = FlxG.sound.music.time;
						}
					}
					else
					{
						if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
						{
							FlxG.sound.music.pause();
							if (!PlayState.isSM)
								vocals.pause();

							var daTime:Float = Conductor.stepCrochet * 2;

							if (FlxG.keys.justPressed.W)
							{
								FlxG.sound.music.time -= daTime;
							}
							else
								FlxG.sound.music.time += daTime;

							if (!PlayState.isSM)
								vocals.time = FlxG.sound.music.time;
						}
					}
				}
			}
			_song.bpm = tempBpm;
			if (eventType.dropPanel.visible)
			{
				eventDescription.visible = false;
			}
			else
			{
				eventDescription.visible =	true;
				switch (eventType.selectedLabel)
				{
					case "BPM Change":
						eventDescriptionText = 'Type in Event Value new Song BPM \n (BPM will change in this and in all the following sections)';
						eventDescription.text = eventDescriptionText;

					case "Scroll Speed Change":
						eventDescriptionText = 'Type in Event Value new Song Scroll Speed \n (Scroll Speed will change in all song after\n the event is triggered)';
						eventDescription.text = eventDescriptionText;

					case "Start Countdown":
						eventDescriptionText = 'Just add this event. \n Event Value is unused';
						eventDescription.text = eventDescriptionText;

					case 'Change Character':
						eventDescriptionText = 'Type in Event Value type of character (gf, bf, dad)\n and name of the character \n (Like: (bf, bf-christmas))';
						eventDescription.text = eventDescriptionText;

					case "Change Dad Character":
						eventDescriptionText = 'Type in Event Value name of new dad character \n (Warning! All character with growth like bf will fly :) )';
						eventDescription.text = eventDescriptionText;

					case "Change BF Character":
						eventDescriptionText = 'Type in Event Value name of new bf character';
						eventDescription.text = eventDescriptionText;

					case "Change GF Character":
						eventDescriptionText = 'Type in Event Value name of new gf character';
						eventDescription.text = eventDescriptionText;

					case "Change Stage":
						eventDescriptionText = 'Type in Event Value name of new stage';
						eventDescription.text = eventDescriptionText;

					case "Song Overlay":
						eventDescriptionText = 'Type in Event Value color in the format \n "red, green, blue, transparency" \n (Some similar as Blammed Colors event in Psych Engine,\n but with rgb colors)';
						eventDescription.text = eventDescriptionText;

					case 'Character play animation':
						eventDescriptionText = 'Type in Event Value character (bf, dad, gf)\n and name of animation \n (Like: (bf, attack-end)';
						eventDescription.text = eventDescriptionText;

					case "Dad play animation":
						eventDescriptionText = 'Type in Event Value name of animation that dad should play';
						eventDescription.text = eventDescriptionText;

					case "BF play animation":
						eventDescriptionText = 'Type in Event Value name of animation that bf should play';
						eventDescription.text = eventDescriptionText;

					case "GF play animation":
						eventDescriptionText = 'Type in Event Value name of animation that gf should play';
						eventDescription.text = eventDescriptionText;

					case "Camera zoom":
						eventDescriptionText = 'Type in Event Value camera zoom multiplier';
						eventDescription.text = eventDescriptionText;
						
					case "Toggle interface":
						eventDescriptionText = 'Type in Event Value seconds when interface will be invisible';
						eventDescription.text = eventDescriptionText;

					case "Toggle Alt Idle":
						eventDescriptionText = 'Type in Event Value character, that should toggle alternative idle animation \n You can type "bf", "dad", "gf"';
						eventDescription.text = eventDescriptionText;

					case "Change note skin":
						eventDescriptionText = 'Type in Event Value new note skin\n In default engine aviable only "pixel" or "normal"';
						eventDescription.text = eventDescriptionText;

					case 'Screen Shake':
						eventDescriptionText = 'Type in Event Value intensity and duration, like 0.15, 0.15';
						eventDescription.text = eventDescriptionText;
					
					case 'Camera Follow Pos':
						eventDescriptionText = 'Type in Event Value position of camera by x and, like 0.15, 0.15';
						eventDescription.text = eventDescriptionText;

					default:
						if (Paths.doesTextAssetExist('assets/custom_events/' + eventType.selectedLabel))
						{
							eventDescriptionText = OpenFlAssets.getText('assets/custom_events/' + eventType.selectedLabel + '.txt');
							eventDescription.text = eventDescriptionText;
						}
						else
						{
							eventDescriptionText = 'Bro, wtf, how did we get here?\n This event dont have description. Its strange.';
							eventDescription.text = eventDescriptionText;
						}	
				}
			}
		}
		catch (e)
		{
			Debug.logError("Error on this shit???\n" + e + e.stack);
		}
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);

				if (curSelectedNoteObject.noteCharterObject != null)
					curRenderedSustains.remove(curSelectedNoteObject.noteCharterObject);

				remove(curSelectedNoteObject.noteCharterObject);

				var sustainVis:FlxSprite = new FlxSprite(curSelectedNoteObject.x + (GRID_SIZE / 2),
					curSelectedNoteObject.y + GRID_SIZE).makeGraphic(8,
					Math.floor((getYfromStrum(curSelectedNoteObject.strumTime + curSelectedNote[2]) * zoomFactor) - curSelectedNoteObject.y));
				curSelectedNoteObject.sustainLength = curSelectedNote[2];
				Debug.logTrace("new sustain " + curSelectedNoteObject.sustainLength);
				curSelectedNoteObject.noteCharterObject = sustainVis;

				curRenderedSustains.add(sustainVis);
			}
		}

		updateNoteUI();
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		FlxG.sound.music.pause();
		if (!PlayState.isSM)
			vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = 0;

		if (!PlayState.isSM)
			vocals.time = FlxG.sound.music.time;

		updateGrid();
		if (!songBeginning)
			updateSectionUI();

		//updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		Debug.logTrace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			Debug.logTrace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				if (!PlayState.isSM)
					vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if (!PlayState.isSM)
					vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			Debug.logTrace('bro wtf I AM NULL');
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);
		var sect = lastUpdatedSection;

		if (sect == null)
			return;

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			sect.sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = getSectionByTime(Conductor.songPosition);

		if (sec == null)
		{
			check_mustHitSection.checked = true;
			check_CPUAltAnim.checked = false;
			check_playerAltAnim.checked = false;
			check_GFSection.checked = false;
			check_GFAltAnim.checked = false;
			stepperSectionLength.value = 16;
		}
		else
		{
			check_mustHitSection.checked = sec.mustHitSection;
			check_CPUAltAnim.checked = sec.CPUAltAnim;
			check_playerAltAnim.checked = sec.playerAltAnim;
			check_GFSection.checked = sec.gfSection;
			check_GFAltAnim.checked = sec.gfAltAnim;
			stepperSectionLength.value = sec.lengthInSteps;
		}
	}

	function updateHeads():Void
	{
		var mustHit = check_mustHitSection.checked;
		#if FEATURE_FILESYSTEM
		var head = (mustHit ? _song.player1 : _song.player2);
		var i = sectionRenderes.members[curSection];

		function iconUpdate(failsafe:Bool = false):Void
		{
			var sect = _song.notes[curSection];
			var cachedY = i.icon.y;
			remove(i.icon);
			var sectionicon = new HealthIcon(failsafe ? (mustHit ? 'bf' : 'face') : head).clone();
			sectionicon.x = -95;
			sectionicon.y = cachedY;
			sectionicon.setGraphicSize(0, 45);

			i.icon = sectionicon;
			i.lastUpdated = sect.mustHitSection;

			add(sectionicon);
		}

		// fail-safe
		if (!OpenFlAssets.exists(Paths.image('icons/' + head.split("-")[0])) && !OpenFlAssets.exists(Paths.image('icons/' + head)))
		{
			if (i.icon.animation.curAnim == null)
				iconUpdate(true);
		}
		//
		else if (i.icon.animation.curAnim.name != head
			&& i.icon.animation.curAnim.name != head.split("-")[0]
			|| head == 'bf-pixel'
			&& i.icon.animation.curAnim.name != 'bf-pixel')
		{
			if (i.icon.animation.getByName(head) != null)
				i.icon.animation.play(head);
			else
				iconUpdate();
		}
		#else
		leftIcon.animation.play(mustHit ? _song.player1 : _song.player2);
		rightIcon.animation.play(mustHit ? _song.player2 : _song.player1);
		#end
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			stepperSusLength.value = curSelectedNote[2];
			if (curSelectedNote[3] != null)
			{	
				check_naltAnim.checked = curSelectedNote[3];
			}
			else
			{
				curSelectedNote[3] = false;
				check_naltAnim.checked = false;	
			}
			if(curSelectedNote[5] != null) {
				noteType = noteTypeMap.get(curSelectedNote[5]);
				if(noteType <= 0) 
				{
					noteTypeDropDown.selectedId = '';
				} 
				else 
				{
					noteTypeDropDown.selectedLabel = noteType + '. ' + curSelectedNote[5];
				}
			}
		}
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedNoteType.members.length > 0)
		{
			curRenderedNoteType.remove(curRenderedNoteType.members[0], true);
		}

		var currentSection = 0;

		for (section in _song.notes)
		{
			for (i in section.sectionNotes)
			{
				var seg = TimingStruct.getTimingAtTimestamp(i[0]);
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daType = null;

				if (i[5] != null)
				{
					if(!Std.isOfType(i[5], String)) //Convert old note type to new note type format
					{
						i[5] = noteTypeIntMap.get(i[5]);
						daType = i[5];
					}
					else
					{
						daType = i[5];
					}
				}
				else
					daType = 'Default Note';

				var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, true, i[3], i[4], daType);
				note.isAlt = i[3];
				note.beat = TimingStruct.getBeatFromTime(daStrumTime);
				note.rawNoteData = daNoteInfo;
				note.sustainLength = daSus;
				note.setGraphicSize(Math.floor(GRID_SIZE), Math.floor(GRID_SIZE));
				note.updateHitbox();
				note.x = Math.floor(daNoteInfo * GRID_SIZE);

				note.y = Math.floor(getYfromStrum(daStrumTime) * zoomFactor);

				if (curSelectedNote != null)
					if (curSelectedNote[0] == note.strumTime)
						lastNote = note;

				curRenderedNotes.add(note);

				var stepCrochet = (((60 / seg.bpm) * 1000) / 4);

				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor((getYfromStrum(note.strumTime + note.sustainLength) * zoomFactor) - note.y));

					note.noteCharterObject = sustainVis;

					curRenderedSustains.add(sustainVis);
				}
				if(i[5] != null && note.noteType != null && note.noteType.length > 0) {
					updateNoteText(note, i);
				}
			}
			currentSection++;
		}
	}

	function updateNoteText(note:Note, info:Array<Dynamic>)
	{
		var typeInt:Null<Int> = noteTypeMap.get(info[5]);
		var theType:String = '' + typeInt;
		if(typeInt == null) theType = '?';

		if (typeInt == 0)
			theType = '';
	
		var daText:AttachedFlxText = new AttachedFlxText(0, 0, 100, theType, 24);
		daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		daText.xAdd = -32;
		daText.yAdd = 6;
		daText.borderSize = 1;
		curRenderedNoteType.add(daText);
		daText.sprTracker = note;
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];
	function updateWaveform() {
		#if desktop
		if(waveformPrinted) {
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * 8), Std.int(height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		if(!FlxG.save.data.chart_waveform) {
			//trace('Epic fail on the waveform lol');
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = Std.int(lengthInSteps);

		var st:Float = 0;
		var et:Float = st + (Conductor.stepCrochet * steps * 2);

		if (FlxG.save.data.chart_waveform) {
			var sound:FlxSound = vocals;
			if (sound._sound != null && sound._sound.__buffer != null) {
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(
					sound._sound.__buffer,
					bytes,
					st,
					et,
					1,
					wavData,
					Std.int(height)
				);
			}
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (
			wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length
		);

		var rightLength:Int = (
			wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length
		);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length) {
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
		#end
	}

	/*
	[
		[[min...], [max...]], left
		[[min...], [max...]]  right
	]
	*/
	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>, ?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null) return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null) steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true;//samples > 17200;
		var v1:Bool = false;

		if (array == null) array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1)) {
			if (index >= 0) {
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2) byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0) {
					if (sample > lmax) lmax = sample;
				} else if (sample < 0) {
					if (sample < lmin) lmin = sample;
				}

				if (channels >= 2) {
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2) byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0) {
						if (sample > rmax) rmax = sample;
					} else if (sample < 0) {
						if (sample < rmin) rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow) {
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length) array[0][0].push(lRMin);
					else array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length) array[0][1].push(lRMax);
					else array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2) {
					if (gotIndex > array[1][0].length) array[1][0].push(rRMin);
						else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length) array[1][1].push(rRMax);
						else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else {
					if (gotIndex > array[1][0].length) array[1][0].push(lRMin);
						else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length) array[1][1].push(lRMax);
						else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if(gotIndex > steps) break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var daPos:Float = 0;
		var start:Float = 0;

		var bpm = _song.bpm;
		for (i in 0...curSection)
		{
			for (ii in TimingStruct.AllTimings)
			{
				var data = TimingStruct.getTimingAtTimestamp(start);
				if ((data != null ? data.bpm : _song.bpm) != bpm && bpm != ii.bpm)
					bpm = ii.bpm;
			}
			start += (4 * (60 / bpm)) * 1000;
		}

		var sec:SwagSection = {
			startTime: daPos,
			endTime: Math.POSITIVE_INFINITY,
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			CPUAltAnim: false,
			playerAltAnim: false,
			gfSection: false,
			gfAltAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note, ?deleteAllBoxes:Bool = true):Void
	{
		var swagNum:Int = 0;

		if (deleteAllBoxes)
			while (selectedBoxes.members.length != 0)
			{
				selectedBoxes.members[0].connectedNote.charterSelected = false;
				selectedBoxes.members[0].destroy();
				selectedBoxes.members.remove(selectedBoxes.members[0]);
			}

		for (sec in _song.notes)
		{
			swagNum = 0;
			for (i in sec.sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == note.rawNoteData)
				{
					curSelectedNote = sec.sectionNotes[swagNum];
					if (curSelectedNoteObject != null)
						curSelectedNoteObject.charterSelected = false;

					curSelectedNoteObject = note;
					if (!note.charterSelected)
					{
						var box = new ChartingBox(note.x, note.y, note);
						box.connectedNoteData = i;
						selectedBoxes.add(box);
						note.charterSelected = true;
						curSelectedNoteObject.charterSelected = true;
					}
				}
				swagNum += 1;
			}
		}

		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		lastNote = note;

		var section = getSectionByTime(note.strumTime);

		var found = false;

		for (i in section.sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				section.sectionNotes.remove(i);
				found = true;
			}
		}

		if (!found) // backup check
		{
			for (i in _song.notes)
			{
				for (n in i.sectionNotes)
					if (n[0] == note.strumTime && n[1] == note.rawNoteData)
						i.sectionNotes.remove(n);
			}
		}

		curRenderedNotes.remove(note);

		if (note.sustainLength > 0)
			curRenderedSustains.remove(note.noteCharterObject);

		for (i in 0...selectedBoxes.members.length)
		{
			var box = selectedBoxes.members[i];
			if (box.connectedNote == note)
			{
				selectedBoxes.members.remove(box);
				box.destroy();
				return;
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		getSectionByTime(Conductor.songPosition).sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16, mustHitSection:Bool = false, CPUAltAnim:Bool = true, playerAltAnim:Bool = true, gfSection:Bool = false, gfAltAnim:Bool = false):SwagSection
	{
		var daPos:Float = 0;

		var currentSeg = TimingStruct.AllTimings[TimingStruct.AllTimings.length - 1];

		var currentBeat = 4;

		for (i in _song.notes)
			currentBeat += 4;

		if (currentSeg == null)
			return null;

		var start:Float = (currentBeat - currentSeg.startBeat) / (currentSeg.bpm / 60);

		daPos = (currentSeg.startTime + start) * 1000;

		var sec:SwagSection = {
			startTime: daPos,
			endTime: Math.POSITIVE_INFINITY,
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: mustHitSection,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			CPUAltAnim: CPUAltAnim,
			playerAltAnim: playerAltAnim,
			gfSection: gfSection,
			gfAltAnim: gfAltAnim
		};

		return sec;
	}

	function recalculateAllSectionTimes()
	{
		var savedNotes:Array<Dynamic> = [];

		for (i in 0..._song.notes.length) // loops through sections
		{
			var section = _song.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / (currentSeg.bpm / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				_song.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	function shiftNotes(measure:Int = 0, step:Int = 0, ms:Int = 0):Void
	{
		var newSong = [];

		var millisecadd = (((measure * 4) + step / 4) * (60000 / currentBPM)) + ms;
		var totaladdsection = Std.int((millisecadd / (60000 / currentBPM) / 4));
		if (millisecadd > 0)
		{
			for (i in 0...totaladdsection)
			{
				newSong.unshift(newSection());
			}
		}
		for (daSection1 in 0..._song.notes.length)
		{
			newSong.push(newSection(16, _song.notes[daSection1].mustHitSection, _song.notes[daSection1].CPUAltAnim, _song.notes[daSection1].playerAltAnim, _song.notes[daSection1].gfSection, _song.notes[daSection1].gfAltAnim));
		}

		for (daSection in 0...(_song.notes.length))
		{
			var aimtosetsection = daSection + Std.int((totaladdsection));
			if (aimtosetsection < 0)
				aimtosetsection = 0;
			newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
			updateHeads();
			newSong[aimtosetsection].CPUAltAnim = _song.notes[daSection].CPUAltAnim;
			newSong[aimtosetsection].playerAltAnim = _song.notes[daSection].playerAltAnim;
			newSong[aimtosetsection].gfAltAnim = _song.notes[daSection].gfAltAnim;
			newSong[aimtosetsection].gfSection = _song.notes[daSection].gfSection;
			// Debug.logTrace("section "+daSection);
			for (daNote in 0...(_song.notes[daSection].sectionNotes.length))
			{
				var newtiming = _song.notes[daSection].sectionNotes[daNote][0] + millisecadd;
				if (newtiming < 0)
				{
					newtiming = 0;
				}
				var futureSection = Math.floor(newtiming / 4 / (60000 / currentBPM));
				_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
				newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);

				// newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
			}
		}
		// Debug.logTrace("DONE BITCH");
		_song.notes = newSong;
		recalculateAllSectionTimes();
		updateGrid();
		updateSectionUI();
		updateNoteUI();
	}

	public function getSectionByTime(ms:Float, ?changeCurSectionIndex:Bool = false):SwagSection
	{
		var index = 0;

		for (i in _song.notes)
		{
			if (ms >= i.startTime && ms < i.endTime)
			{
				if (changeCurSectionIndex)
					curSection = index;
				return i;
			}
			index++;
		}

		return null;
	}

	public function getNoteByTime(ms:Float)
	{
		for (i in _song.notes)
		{
			for (n in i.sectionNotes)
				if (n[0] == ms)
					return i;
		}
		return null;
	}

	public var curSelectedNoteObject:Note = null;

	private function addNote(?n:Note):Void
	{
		var strum = getStrumTime(dummyArrow.y) / zoomFactor;

		var section = getSectionByTime(strum);

		if (section == null)
			return;

		Debug.logTrace(strum + " from " + dummyArrow.y);

		var noteStrum = strum;
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var daType = noteType;

		Debug.logTrace("adding note with " + strum + " from dummyArrow with data " + noteData + " with type " + noteTypeIntMap.get(daType));

		if (n != null)
			section.sectionNotes.push([
				n.strumTime,
				n.noteData,
				n.sustainLength,
				false,
				TimingStruct.getBeatFromTime(n.strumTime),
				noteTypeIntMap.get(n.noteType)]);
		else
			section.sectionNotes.push([noteStrum, noteData, noteSus, false, TimingStruct.getBeatFromTime(noteStrum), noteTypeIntMap.get(daType)]);

		var thingy = section.sectionNotes[section.sectionNotes.length - 1];

		curSelectedNote = thingy;

		var seg = TimingStruct.getTimingAtTimestamp(noteStrum);

		if (n == null)
		{
			var note:Note = new Note(noteStrum, noteData % 4, null, false, true, null, TimingStruct.getBeatFromTime(noteStrum), noteTypeIntMap.get(daType));
			note.rawNoteData = noteData;
			note.sustainLength = noteSus;
			note.noteType = noteTypeIntMap.get(daType);
			note.setGraphicSize(Math.floor(GRID_SIZE), Math.floor(GRID_SIZE));
			note.updateHitbox();
			note.x = Math.floor(noteData * GRID_SIZE);

			if (curSelectedNoteObject != null)
				curSelectedNoteObject.charterSelected = false;
			curSelectedNoteObject = note;
			

			while (selectedBoxes.members.length != 0)
			{
				selectedBoxes.members[0].connectedNote.charterSelected = false;
				selectedBoxes.members[0].destroy();
				selectedBoxes.members.remove(selectedBoxes.members[0]);
			}

			curSelectedNoteObject.charterSelected = true;

			note.y = Math.floor(getYfromStrum(noteStrum) * zoomFactor);

			var box = new ChartingBox(note.x, note.y, note);
			box.connectedNoteData = thingy;
			selectedBoxes.add(box);

			curRenderedNotes.add(note);
		}
		else
		{
			var note:Note = new Note(n.strumTime, n.noteData % 4, null, false, true, n.isAlt, TimingStruct.getBeatFromTime(n.strumTime), noteTypeIntMap.get(n.noteType));
			note.beat = TimingStruct.getBeatFromTime(n.strumTime);
			note.rawNoteData = n.noteData;
			note.sustainLength = noteSus;
			note.noteType = noteTypeIntMap.get(n.noteType);
			note.setGraphicSize(Math.floor(GRID_SIZE), Math.floor(GRID_SIZE));
			note.updateHitbox();
			note.x = Math.floor(n.noteData * GRID_SIZE);

			if (curSelectedNoteObject != null)
				curSelectedNoteObject.charterSelected = false;
			curSelectedNoteObject = note;
			

			while (selectedBoxes.members.length != 0)
			{
				selectedBoxes.members[0].connectedNote.charterSelected = false;
				selectedBoxes.members[0].destroy();
				selectedBoxes.members.remove(selectedBoxes.members[0]);
			}

			var box = new ChartingBox(note.x, note.y, note);
			box.connectedNoteData = thingy;
			selectedBoxes.add(box);

			curSelectedNoteObject.charterSelected = true;

			note.y = Math.floor(getYfromStrum(n.strumTime) * zoomFactor);

			curRenderedNotes.add(note);
		}

		updateGrid();

		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.roundDecimal(FlxMath.remapToRange(yPos, 0, lengthInSteps, 0, lengthInSteps), 1);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.roundDecimal(FlxMath.remapToRange(strumTime, 0, lengthInSteps, 0, lengthInSteps), 1);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		Debug.logTrace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(songId:String):Void
	{
		var difficultyArray:Array<String> = ["-easy", "", "-hard", "-hardplus"];

		PlayState.SONG = Song.loadFromJson(songId, difficultyArray[PlayState.storyDifficulty]);

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (sectionRenderes.members.length > 0)
		{
			sectionRenderes.remove(sectionRenderes.members[0], true);
		}

		while (sectionRenderes.members.length > 0)
		{
			sectionRenderes.remove(sectionRenderes.members[0], true);
		}
		var toRemove = [];

		for (i in _song.notes)
		{
			if (i.startTime > FlxG.sound.music.length)
				toRemove.push(i);
		}

		for (i in toRemove)
			_song.notes.remove(i);

		toRemove = []; // clear memory
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseAutosaveshit(FlxG.save.data.autosave);

		MusicBeatState.resetState();
	}

	function getCharacterIcon(char:String):String
	{	
		if (char != null)
		{
			var jsonData;
			if (OpenFlAssets.exists(Paths.json('characters/${char}')))
				jsonData = Paths.loadJSON('characters/${char}');
			else
			{
				Debug.logError('Failed to parse JSON data for character ${char}');
				return 'face';
			}
	
			var data:CharacterData = cast jsonData;
	
			var characterIcon:String = data.characterIcon;

			return characterIcon;
		}
		else
		{
			return 'face';
		}
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song,
			"songMeta": {
				"name": _song.songId,
				"offset": 0,
			}
		});
		FlxG.save.flush();
	}

	private function saveEvents()
	{
		var difficultyArray:Array<String> = ["-easy", "", "-hard", "-hardplus"];

		var json = {
			"eventObjects": _song.eventObjects
		};

		var data:String = Json.stringify(json, null, " ");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	private function saveLevel()
	{
		var diff:String = '';
		switch (PlayState.storyDifficulty)
		{
			case 0:
				diff = "-easy";
			case 2:
				diff = "-hard";
			case 3:
				diff = "-hardplus";
			case 1:
				diff = '';
			default:
				diff = "-" + CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toLowerCase();
		}

		var toRemove = [];

		for (i in _song.notes)
		{
			if (i.startTime > FlxG.sound.music.length)
				toRemove.push(i);
		}

		for (i in toRemove)
			_song.notes.remove(i);

		toRemove = []; // clear memory

		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, null, " ");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.songId.toLowerCase() + diff + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	var pausedCrashFix = false; //fixes crashes if you paused song and opened another window

	override function onWindowFocusIn():Void
	{
		if (!pausedCrashFix)
		{
			FlxG.sound.music.resume();
			vocals.resume();
		}
	}
	override function onWindowFocusOut():Void
	{
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}
		else
		{
			pausedCrashFix = true;
		}
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}
