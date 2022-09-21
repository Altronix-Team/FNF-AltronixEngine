package scriptStuff;

import gameplayStuff.PlayStateChangeables;
import gameplayStuff.DialogueBoxPsych;
import gameplayStuff.Boyfriend;
import gameplayStuff.Character;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import scriptStuff.HScriptHandler;
import states.PlayState;
import openfl.utils.Assets;
import scriptStuff.FunkinLua;

@:access(states.PlayState)
class HScriptModchart extends FlxTypedGroup<FlxBasic>
{
	public var scriptHelper:HScriptHandler;
	var playState:PlayState;
	
	var cachedChars:Map<String, Character> = [];
	var cachedBFs:Map<String, Boyfriend> = [];

	public function new(path:String, state:PlayState)
	{
		super();
		
		this.playState = state;

		if (scriptHelper == null)
			scriptHelper = new HScriptHandler();

		if (!scriptHelper.expose.exists("PlayState"))
			scriptHelper.expose.set("PlayState", playState);
		
		if (playState.hscriptStage != null){
			if (!scriptHelper.expose.exists("stage"))
				scriptHelper.expose.set("stage", playState.hscriptStage);}
		
		if (!scriptHelper.expose.exists("gf") && playState.gf != null)
			scriptHelper.expose.set("gf", playState.gf);
		if (!scriptHelper.expose.exists("dad") && playState.dad != null)
			scriptHelper.expose.set("dad", playState.dad);
		if (!scriptHelper.expose.exists("boyfriend") && playState.boyfriend != null)
			scriptHelper.expose.set("boyfriend", playState.boyfriend);

		if (!scriptHelper.expose.exists("gfGroup") && playState.gfGroup != null)
			scriptHelper.expose.set("gfGroup", playState.gfGroup);
		if (!scriptHelper.expose.exists("dadGroup") && playState.dadGroup != null)
			scriptHelper.expose.set("dadGroup", playState.dadGroup);
		if (!scriptHelper.expose.exists("boyfriendGroup") && playState.boyfriendGroup != null)
			scriptHelper.expose.set("boyfriendGroup", playState.boyfriendGroup);

		scriptHelper.expose.set("curBeat", 0);
		scriptHelper.expose.set("curStep", 0);
		scriptHelper.expose.set("curSectionNumber", 0);

		scriptHelper.expose.set("setOnScripts", ScriptHelper.setOnScripts);
		scriptHelper.expose.set("callOnScripts", ScriptHelper.callOnScripts);

		scriptHelper.expose.set("camGame", playState.camGame);
		scriptHelper.expose.set("camHUD", playState.camHUD);
		scriptHelper.expose.set("cacheCharacter", cacheCharacter);
		scriptHelper.expose.set("changeCharacter", changeCharacter);
		scriptHelper.expose.set("PlayStateChangeables", PlayStateChangeables);

		scriptHelper.expose.set("setObjectCam", setObjectCam);

		scriptHelper.expose.set("startDialogue", startDialogue);

		scriptHelper.loadScript(path);

		scriptHelper.call('onCreate', []);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		scriptHelper.call('onUpdate', [elapsed]);
	}

	public function changeCharacter(tag:String = 'bf', charName:String = 'bf')
	{
		if (tag == 'bf')
		{
			if (cachedBFs.get(charName) != null)
			{
				PlayState.instance.changeCharacterToCached(tag, cachedBFs.get(charName));
			}
			else
			{
				Debug.logError('This character not cached');
				return;
			}
		}
		else
		{
			if (cachedChars.get(charName) != null)
			{
				PlayState.instance.changeCharacterToCached(tag, cachedChars.get(charName));
			}
			else
			{
				Debug.logError('This character not cached');
				return;
			}
		}	
	}

	public function cacheCharacter(x:Float = 0, y:Float = 0, charName:String = 'bf', charType:String = 'bf')
	{
		if (charType == 'bf')
		{
			var newChar:Boyfriend = new Boyfriend(x, y, charName);
			cachedBFs.set(charName, newChar);

			if (cachedBFs.get(charName) == null)
			{
				Debug.logError('Error with character caching $charName');
				cachedBFs.remove(charName);
				return;
			}
		}
		else
		{
			var newChar:Character = new Character(x, y, charName);
			cachedChars.set(charName, newChar);

			if (cachedChars.get(charName) == null)
			{
				Debug.logError('Error with character caching $charName');
				cachedChars.remove(charName);
				return;
			}
		}	
	}

	public function startLuaScript(scriptName:String) //In Psych Engine you can start hscript from lua, but in Altronix we have another rules XD
	{
		if (Assets.exists('assets/scripts/$scriptName.lua'))
		{
			ScriptHelper.luaArray.push(new FunkinLua(Assets.getPath('assets/scripts/$scriptName.lua')));
		}
	}

	public function startDialogue(dialogueFile:String, music:String = null)
	{
		var path:String = Paths.json('songs/' + PlayState.SONG.songId + '/' + dialogueFile);

		if (Assets.exists(path))
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

	public function getCameraFromString(camera:String):FlxCamera{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				return PlayState.instance.camHUD;
			case 'camsustains' | 'sustains':
				return PlayState.instance.camSustains;
			case 'camnotes' | 'notes':
				return PlayState.instance.camNotes;
		}
		return PlayState.instance.camGame;
	}

	public function setObjectCam(object:FlxBasic, camera:String)
	{
		if (object != null)
		{
			object.cameras = [getCameraFromString(camera)];
		}
	}

	public function get(field:String):Dynamic
		return scriptHelper.get(field);

	public function set(field:String, value:Dynamic)
		scriptHelper.set(field, value);
}