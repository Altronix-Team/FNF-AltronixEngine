package scriptStuff;

import utils.Paths;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameplayStuff.BGSprite;
import gameplayStuff.BackgroundDancer;
import gameplayStuff.BackgroundGirls;
import gameplayStuff.Boyfriend;
import gameplayStuff.Character;
import gameplayStuff.CutsceneHandler;
import gameplayStuff.DialogueBoxPsych;
import gameplayStuff.PlayStateChangeables;
import gameplayStuff.TankmenBG;
import openfl.utils.Assets;
import scriptStuff.HScriptHandler;
import states.MusicBeatState;
import states.playState.PlayState;
import states.playState.GameData as Data;

class HScriptModchart extends FlxTypedGroup<FlxBasic>
{
	public var scriptHandler:HScriptHandler;

	var curState:PlayState;

	public function new(path:String, state:PlayState)
	{
		super();

		curState = state;

		scriptHandler = new HScriptHandler(path);

		if (!scriptHandler.exists("PlayState"))
			scriptHandler.set("PlayState", curState);

		if (curState.hscriptStage != null)
		{
			if (!scriptHandler.exists("stage"))
				scriptHandler.set("stage", curState.hscriptStage);
		}

		if (!scriptHandler.exists("gf") && curState.gf != null)
			scriptHandler.set("gf", curState.gf);
		if (!scriptHandler.exists("dad") && curState.dad != null)
			scriptHandler.set("dad", curState.dad);
		if (!scriptHandler.exists("boyfriend") && curState.boyfriend != null)
			scriptHandler.set("boyfriend", curState.boyfriend);

		if (!scriptHandler.exists("gfGroup") && curState.gfGroup != null)
			scriptHandler.set("gfGroup", curState.gfGroup);
		if (!scriptHandler.exists("dadGroup") && curState.dadGroup != null)
			scriptHandler.set("dadGroup", curState.dadGroup);
		if (!scriptHandler.exists("boyfriendGroup") && curState.boyfriendGroup != null)
			scriptHandler.set("boyfriendGroup", curState.boyfriendGroup);

		scriptHandler.set("curBeat", 0);
		scriptHandler.set("curStep", 0);
		scriptHandler.set("curSectionNumber", 0);

		scriptHandler.set("songId", Data.SONG.songId);

		scriptHandler.set("setOnHscript", ScriptHelper.setOnHscript);
		scriptHandler.set("callOnHscript", ScriptHelper.callOnHscript);

		scriptHandler.set("camGame", curState.camGame);
		scriptHandler.set("camHUD", curState.camHUD);
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

		scriptHandler.call('onCreate', []);

		Debug.logInfo('Successfully loaded new hscript file: ' + path.removeBefore('/'));
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

	public function getCameraFromString(camera:String):FlxCamera
	{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				return PlayState.instance.camHUD;
		}
		return PlayState.instance.camGame;
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

	override public function add(Object:FlxBasic):FlxBasic
	{
		try
		{
			if (!Main.save.data.antialiasing && Reflect.field(Object, 'antialiasing') != null)
				Reflect.setField(Object, 'antialiasing', false);
		}
		catch (e)
			Debug.logError(e.details());
		return super.add(Object);
	}
}
