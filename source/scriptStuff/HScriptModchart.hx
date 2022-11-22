package scriptStuff;

import gameplayStuff.CutsceneHandler;
import states.MusicBeatState;
import flixel.FlxSprite;
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
import gameplayStuff.TankmenBG;
import gameplayStuff.BackgroundDancer;
import gameplayStuff.BackgroundGirls;
import gameplayStuff.BGSprite;

#if !USE_SSCRIPT
@:access(states.PlayState)
class HScriptModchart extends FlxTypedGroup<FlxBasic>
{
	public var scriptHandler:HScriptHandler;
	var playState:PlayState;
	
	var cachedChars:Map<String, Character> = [];
	var cachedBFs:Map<String, Boyfriend> = [];

	public function new(path:String, state:PlayState)
	{
		super();
		
		this.playState = state;

		if (scriptHandler == null)
			scriptHandler = new HScriptHandler();

		if (!scriptHandler.expose.exists("PlayState"))
			scriptHandler.expose.set("PlayState", playState);
		
		if (playState.hscriptStage != null){
			if (!scriptHandler.expose.exists("stage"))
				scriptHandler.expose.set("stage", playState.hscriptStage);}
		
		if (!scriptHandler.expose.exists("gf") && playState.gf != null)
			scriptHandler.expose.set("gf", playState.gf);
		if (!scriptHandler.expose.exists("dad") && playState.dad != null)
			scriptHandler.expose.set("dad", playState.dad);
		if (!scriptHandler.expose.exists("boyfriend") && playState.boyfriend != null)
			scriptHandlerexpose.set("boyfriend", playState.boyfriend);

		if (!scriptHandler.expose.exists("gfGroup") && playState.gfGroup != null)
			scriptHandler.expose.set("gfGroup", playState.gfGroup);
		if (!scriptHandler.expose.exists("dadGroup") && playState.dadGroup != null)
			scriptHandler.expose.set("dadGroup", playState.dadGroup);
		if (!scriptHandler.expose.exists("boyfriendGroup") && playState.boyfriendGroup != null)
			scriptHandler.expose.set("boyfriendGroup", playState.boyfriendGroup);

		scriptHandler.expose.set("curBeat", 0);
		scriptHandler.expose.set("curStep", 0);
		scriptHandler.expose.set("curSectionNumber", 0);

		scriptHandler.expose.set("setOnScripts", ScriptHelper.setOnScripts);
		scriptHandler.expose.set("callOnScripts", ScriptHelper.callOnScripts);

		scriptHandler.expose.set("camGame", playState.camGame);
		scriptHandler.expose.set("camHUD", playState.camHUD);
		scriptHandler.expose.set("cacheCharacter", cacheCharacter);
		scriptHandler.expose.set("changeCharacter", changeCharacter);
		scriptHandler.expose.set("PlayStateChangeables", PlayStateChangeables);

		scriptHandler.expose.set("setObjectCam", setObjectCam);

		scriptHandler.expose.set("startDialogue", startDialogue);

		scriptHandler.expose.set('add', add);
		scriptHandler.expose.set('remove', remove);

		scriptHandler.loadScript(path);

		scriptHandler.call('onCreate', []);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		scriptHandler.call('onUpdate', [elapsed]);
	}

	override public function add(Object:FlxBasic):FlxBasic
	{
		if (!Main.save.data.antialiasing && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
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

	//TODO Redo to work with DialogueBox.hx
	public function startDialogue(dialogueFile:String, music:String = null)
	{
		var path:String = Paths.formatToDialoguePath(PlayState.SONG.songId + '/' + dialogueFile);

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
		return scriptHandler.get(field);

	public function set(field:String, value:Dynamic)
		scriptHandler.set(field, value);
}
#else
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

		scriptHandler.set("setOnScripts", ScriptHelper.setOnScripts);
		scriptHandler.set("callOnScripts", ScriptHelper.callOnScripts);

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

		scriptHandler.set('isStoryMode', PlayState.isStoryMode);

		scriptHandler.set('add', add);
		scriptHandler.set('remove', remove);

		scriptHandler.set('destroyScript', destroyScript);

		scriptHandler.call('onCreate', []);

		Debug.logInfo('Successfully loaded new hscript file: ' + path.removeBefore('/'));
	}

	private function destroyScript() {
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
		var path:String = Paths.formatToDialoguePath(PlayState.SONG.songId + '/' + dialogueFile);

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
		try{if (!Main.save.data.antialiasing && Reflect.field(Object, 'antialiasing') != null)
			Reflect.setField(Object, 'antialiasing', false);} catch(e) Debug.logError(e.details());
		return super.add(Object);
	}
}
#end