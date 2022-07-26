package gameplayStuff;

import IHook;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

/*@:hscript({
	context: [
		add, remove, Paths, PLAYER, OPPONENT, GIRLFRIEND, getCharacter, getBoyfriend, getDad, getGirlfriend
	]
})
class HscriptStage extends FlxTypedGroup<FlxBasic> implements polymod.hscript.HScriptable
{
	public static final PLAYER = 0;
	public static final OPPONENT = 1;
	public static final GIRLFRIEND = 2;

	public final stageId:String;
	public final stageCharacters:Map<Int, Character> = new Map<Int, Character>();

	public static var currentBeat(get, null):Int = 0;
	public static var currentStep(get, null):Int = 0;

	public var camZoom:Float = 1.0;

	private final cbOnCreate:() -> Void;
	private final cbOnBeatHit:(Int) -> Void;
	private final cbOnStepHit:(Int) -> Void;
	private final cbOnUpdate:(Float) -> Void;
	private final cbOnPlayerHitNote:(Note) -> Void;
	private final cbOnCPUHitNote:(Note) -> Void;
	private final cbOnPlayerMissNote:(Note) -> Void;
	private final cbOnCPUMissNote:(Note) -> Void;
	private final cbOnUpdateNote:(Note) -> Void;
	private final cbOnDestroy:() -> Void;

	function buildPathName():String
	{
		return 'play/stage/$stageId';
	}

	/**
	 * Mod hook called when the credits sequence starts.
	 */
	/*@:hscript({
		pathName: buildPathName, // Path name is generated at the time the function is called.
	})
	function buildStageHooks():Void
	{
		if (script_variables.get('onCreate') != null)
		{
			Debug.logInfo('Found stage hook: onCreate');
			cbOnCreate = script_variables.get('onCreate');
		}
		if (script_variables.get('onBeatHit') != null)
		{
			Debug.logInfo('Found stage hook: onBeatHit');
			cbOnBeatHit = script_variables.get('onBeatHit');
		}
		if (script_variables.get('onStepHit') != null)
		{
			Debug.logInfo('Found stage hook: onStepHit');
			cbOnStepHit = script_variables.get('onStepHit');
		}
		if (script_variables.get('onUpdate') != null)
		{
			Debug.logInfo('Found stage hook: onUpdate');
			cbOnUpdate = script_variables.get('onUpdate');
		}
		if (script_variables.get('onPlayerHitNote') != null)
		{
			Debug.logInfo('Found stage hook: onPlayerHitNote');
			cbOnPlayerHitNote = script_variables.get('onPlayerHitNote');
		}
		if (script_variables.get('onCPUHitNote') != null)
		{
			Debug.logInfo('Found stage hook: onCPUHitNote');
			cbOnCPUHitNote = script_variables.get('onCPUHitNote');
		}
		if (script_variables.get('onPlayerMissNote') != null)
		{
			Debug.logInfo('Found stage hook: onPlayerMissNote');
			cbOnPlayerMissNote = script_variables.get('onPlayerMissNote');
		}
		if (script_variables.get('onCPUMissNote') != null)
		{
			Debug.logInfo('Found stage hook: onCPUMissNote');
			cbOnCPUMissNote = script_variables.get('onCPUMissNote');
		}
		if (script_variables.get('onUpdateNote') != null)
		{
			Debug.logInfo('Found stage hook: onUpdateNote');
			cbOnUpdateNote = script_variables.get('onUpdateNote');
		}
		if (script_variables.get('onDestroy') != null)
		{
			Debug.logInfo('Found stage hook: onDestroy');
			cbOnDestroy = script_variables.get('onDestroy');
		}
		Debug.logTrace('Script hooks retrieved.');
	}

	static function get_currentBeat():Int
	{
		return states.MusicBeatState.curBeat;
	}

	static function get_currentStep():Int
	{
		return states.MusicBeatState.curStep;
	}

	public function new(stageId:String)
	{
		this.stageId = stageId;

		buildStageHooks();

		if (cbOnCreate != null)
		{
			cbOnCreate();
		}
		else
		{
			Debug.logError('Stage: Could not load onCreate hook for $stageId! Did you setup your HScript file properly?');
		}
	}

	var pixelMode:Bool = false;

	public function setPixelMode(value:Bool)
	{
		pixelMode = value;
	}

	function addToLayer(object:FlxBasic, layer:Int)
	{
		stageLayers.get(layer).push(object);
	}

	public override function add(object:FlxBasic)
	{
		object.antialiasing = pixelMode ? false : FlxG.save.data.antialiasing;
		super.add(object);
	}

	/**
	 * The default characters get added by the PlayState, so you don't need to run this yourself.
	 * Using this to add custom characters should work though. 
	 */
	/*public function addCharacter(character:Character, id:Int)
	{
	}

	// TODO: Add addToLayer() function.

	public function onBeatHit()
	{
		if (cbOnBeatHit != null)
		{
			cbOnBeatHit();
		}
	}

	public function onStepHit()
	{
		if (cbOnStepHit != null)
		{
			cbOnStepHit();
		}
	}

	public function onPlayerHitNote(note:Note)
	{
		if (cbOnPlayerHitNote != null)
		{
			cbOnPlayerHitNote(note);
		}
	}

	public function onPlayerMissNote(note:Note)
	{
		if (cbOnPlayerMissNote != null)
		{
			cbOnPlayerMissNote(note);
		}
	}

	public function onCPUHitNote(note:Note)
	{
		if (cbOnCPUHitNote != null)
		{
			cbOnCPUHitNote(note);
		}
	}

	public function onCPUMissNote(note:Note)
	{
		if (cbOnCPUMissNote != null)
		{
			cbOnCPUMissNote(note);
		}
	}

	public override function update(elapsed:Float)
	{
		if (cbOnUpdate != null)
		{
			cbOnUpdate(elapsed);
		}
	}

	public override function destroy():Void
	{
		super.destroy();

		if (cbOnDestroy != null)
		{
			cbOnDestroy();
		}
	}

	public function getCharacter(id:Int)
	{
		if (stageCharacters.get(id) != null)
		{
			return stageCharacters.get(id);
		}
		else
		{
			switch (id)
			{
				case PLAYER:
					return states.PlayState.boyfriend;
				case OPPONENT:
					return states.PlayState.dad;
				case GIRLFRIEND:
					return states.PlayState.gf;
			}
		}
	}

	public function getBoyfriend():Character
	{
		return getCharacter(PLAYER);
	}

	public function getDad():Character
	{
		return getCharacter(OPPONENT);
	}

	public function getGirlfriend():Character
	{
		return getCharacter(GIRLFRIEND);
	}
}*/