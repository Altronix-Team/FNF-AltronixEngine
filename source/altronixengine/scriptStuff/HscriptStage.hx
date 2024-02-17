package altronixengine.scriptStuff;

import altronixengine.gameplayStuff.DialogueBoxPsych;
import altronixengine.gameplayStuff.PlayStateChangeables;
import altronixengine.gameplayStuff.CutsceneHandler;
import altronixengine.gameplayStuff.BGSprite;
import funkin.gameplayStuff.BackgroundGirls;
import funkin.gameplayStuff.BackgroundDancer;
import funkin.gameplayStuff.TankmenBG;
import altronixengine.gameplayStuff.BaseStage;
import altronixengine.utils.Paths;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import altronixengine.gameplayStuff.Boyfriend;
import altronixengine.gameplayStuff.Character;
import altronixengine.scriptStuff.HScriptHandler;
import altronixengine.states.playState.PlayState;
import altronixengine.states.playState.GameData as Data;

class HscriptStage extends BaseStage implements IHScriptModchart
{
	public var scriptHandler:HScriptHandler;

	public var objectsMap:Map<String, FlxBasic> = new Map<String, FlxBasic>();
	public var objectsArray:Array<FlxBasic> = [];

	public function new(curStage:String, state:PlayState, path:String)
	{
		scriptHandler = new HScriptHandler(path);

		scriptHandlerPreset();

		super(curStage, state);

		Debug.logInfo('Successfully loaded new hscript file: ' + path.removeBefore('/'));
	}

	override function create(){
		scriptHandler.call('onCreate', []);
	}

	override public function add(object:FlxBasic):FlxBasic
	{
		if (object != null)
		{
			return super.add(object);
		}
		else
		{
			Debug.logError('Failed to add object to stage');
			return null;
		}
	}

	public function addObject(object:FlxBasic, objectName:String)
	{
		if (object != null)
		{
			if (objectName != null)
				objectsMap.set(objectName, object);
			objectsArray.push(object);
			this.add(object);
		}
		else
		{
			Debug.logError('Failed to add object to stage');
		}
	}

	public function getObject(objectName:String):FlxBasic
	{
		if (objectName != null)
		{
			return objectsMap.get(objectName);
		}
		else
		{
			Debug.logError('Failed to get object from stage');
			return null;
		}
	}

	public function addGf()
	{
		add(gf);
	}

	public function addDad()
	{
		add(dad);
	}

	public function addBoyfriend()
	{
		add(boyfriend);
	}

	public function addGfGroup()
	{
		add(gfGroup);
	}

	public function addDadGroup()
	{
		add(dadGroup);
	}

	public function addBoyfriendGroup()
	{
		add(boyfriendGroup);
	}

	public function getCharacterByIndex(whose:Int):altronixengine.gameplayStuff.Character
	{
		switch (whose)
		{
			case 0:
				return dad;
			case 1:
				return boyfriend;
			case 2:
				return gf;
			default:
				return null;
		}
		return null;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (scriptHandler.exists('onUpdate'))
			scriptHandler.call('onUpdate', [elapsed]);
	}

	private function scriptHandlerPreset(){
		if (!scriptHandler.exists("PlayState"))
			scriptHandler.set("PlayState", playState);

		if (!scriptHandler.exists("stage"))
			scriptHandler.set("stage", this);

		if (!scriptHandler.exists("gf") && gf != null)
			scriptHandler.set("gf", gf);
		if (!scriptHandler.exists("dad") && dad != null)
			scriptHandler.set("dad", dad);
		if (!scriptHandler.exists("boyfriend") && boyfriend != null)
			scriptHandler.set("boyfriend", boyfriend);

		if (!scriptHandler.exists("gfGroup") && gfGroup != null)
			scriptHandler.set("gfGroup", gfGroup);
		if (!scriptHandler.exists("dadGroup") && dadGroup != null)
			scriptHandler.set("dadGroup", dadGroup);
		if (!scriptHandler.exists("boyfriendGroup") && boyfriendGroup != null)
			scriptHandler.set("boyfriendGroup", boyfriendGroup);

		scriptHandler.set("curBeat", 0);
		scriptHandler.set("curStep", 0);
		scriptHandler.set("curSectionNumber", 0);

		scriptHandler.set("songId", Data.SONG.songId);

		scriptHandler.set("setOnHscript", ScriptHelper.setOnHscript);
		scriptHandler.set("callOnHscript", ScriptHelper.callOnHscript);

		scriptHandler.set("camGame", playState.camGame);
		scriptHandler.set("camHUD", playState.camHUD);
		scriptHandler.set("PlayStateChangeables", PlayStateChangeables);
		scriptHandler.set('CutsceneHandler', CutsceneHandler);
		scriptHandler.set('BGSprite', BGSprite);
		scriptHandler.set('BackgroundGirls', BackgroundGirls);
		scriptHandler.set('BackgroundDancer', BackgroundDancer);
		scriptHandler.set('TankmenBG', TankmenBG);

		scriptHandler.set("setObjectCam", setObjectCam);

		scriptHandler.set("startDialogue", startDialogue);

		scriptHandler.set('isStoryMode', Data.isStoryMode);

		scriptHandler.set('add', add);
		scriptHandler.set('remove', remove);

		scriptHandler.set('destroyScript', destroyScript);

		scriptHandler.set("stage", this);
		scriptHandler.set("addGf", addGf);
		scriptHandler.set("addDad", addDad);
		scriptHandler.set("addBoyfriend", addBoyfriend);
		scriptHandler.set("addGfGroup", addGfGroup);
		scriptHandler.set("addDadGroup", addDadGroup);
		scriptHandler.set("addBoyfriendGroup", addBoyfriendGroup);
		scriptHandler.set("addObject", addObject);
		scriptHandler.set("getObject", getObject);
	}

	private function destroyScript()
	{
		if (ScriptHelper.hscriptFiles.contains(this))
			ScriptHelper.hscriptFiles.remove(this);
	}

	public function setObjectCam(object:FlxBasic, camera:String)
	{
		if (object != null)
		{
			object.cameras = [getCameraFromString(camera)];
		}
	}

		// TODO Redo to work with DialogueBox.hx
	public function startDialogue(dialogueFile:String, music:String = null)
	{
		var path:String = Paths.formatToDialoguePath(Data.SONG.songId + '/' + dialogueFile);

		if (path != null)
		{
			var shit:DialogueFile = DialogueBoxPsych.parseDialogue(path);
			if (shit.dialogue.length > 0)
			{
				PlayState.instance.startDialogue(shit, music);
			}
		}
		else
		{
			if (PlayState.instance.endingSong)
			{
				PlayState.instance.endSong();
			}
			else
			{
				PlayState.instance.startCountdown();
			}
		}
	}

	public function getCameraFromString(camera:String):FlxCamera
	{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				return PlayState.instance.camHUD;
		}
		return PlayState.instance.camGame;
	}
}
