package gameplayStuff;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import states.PlayState;

using StringTools;
using hx.strings.Strings;

class Character extends FlxSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf';
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animInterrupt:Map<String, Bool>;
	public var animNext:Map<String, String>;
	public var animDanced:Map<String, Bool>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;

	public var holdTimer:Float = 0;

	public var replacesGF:Bool;
	public var hasTrail:Bool;
	public var isDancing:Bool;
	public var holdLength:Float;
	public var positionArray:Array<Float>;
	public var camPos:Array<Float>;
	public var camFollow:Array<Float>;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var animationsArray:Array<AnimationData> = [];
	public var asset:String = '';
	public var jsonScale:Float = 1;
	public var cameraPosition:Array<Float> = [0, 0];
	public var originalFlipX:Bool = false;
	public var charAntialiasing:Bool = false;
	public var startingAnim:String = '';
	public var interruptAnim:Bool = true;
	public var colorTween:FlxTween;
	public var characterIcon:String = 'face';
	public var animationNotes:Array<Dynamic> = [];
	public var specialAnim:Bool = false;
	public var psychChar:Bool = false;

	public var healthIcon:HealthIcon = null;

	var wasAltIdle:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		animInterrupt = new Map<String, Bool>();
		animNext = new Map<String, String>();
		animDanced = new Map<String, Bool>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		parseDataFile();

		if (curCharacter == 'picospeaker') 
		{
			loadMappedAnims();
		}

		if (isPlayer && frames != null)
		{
			flipX = !flipX;
		}

		healthIcon = new HealthIcon(curCharacter, characterIcon, isPlayer);
	}

	function parseDataFile(){
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData;
		if (OpenFlAssets.exists(Paths.getJson('characters/${curCharacter}/${curCharacter}')))
		{
			jsonData = Paths.loadJSONInDefaultLibrary('characters/${curCharacter}/${curCharacter}');
		}
		else
		{
			Debug.logError('There is no character with this name!');
			jsonData = Paths.loadJSONInDefaultLibrary('characters/dad/dad');
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		if (Reflect.field(jsonData, 'name') != null){
			loadAltronixEngineCharacter(jsonData);}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null){
			psychChar = true;
			Debug.logTrace('Looks like Psych engine character');
			loadPsychEngineCharacter(jsonData);}		
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * holdLength * 0.001)
				{
					if (isDancing)
						playAnim('danceLeft'); // overridden by dance correctly later
					dance(false, wasAltIdle);
					holdTimer = 0;
				}
			}
		}

		if (PlayState.SONG != null)
		{
			if (curCharacter == 'picospeaker') 
				{
					if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
						{
							var noteData:Int = 1;
							if(animationNotes[0][1] > 2) noteData = 3;
		
							noteData += FlxG.random.int(0, 1);
							playAnim('shoot' + noteData, true);
							animationNotes.shift();
						}
					if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
				}
		}

		if (!debugMode)
		{
			var nextAnim = animNext.get(animation.curAnim.name);
			var forceDanced = animDanced.get(animation.curAnim.name);

			if (nextAnim != null && animation.curAnim.finished)
			{
				if (isDancing && forceDanced != null)
					danced = forceDanced;
				playAnim(nextAnim);
			}
		}

		if (animation.curAnim != null)
		{
			if (animation.curAnim.finished && specialAnim)
			{
				specialAnim = false;
				dance(false, wasAltIdle);
			}
		}

		super.update(elapsed);
	}

	public function loadMappedAnims() {
		var picoAnims = Song.picospeakerLoad(curCharacter, "stress").notes;
		for (anim in picoAnims) {
			for (note in anim.sectionNotes) {
				animationNotes.push(note);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			var canInterrupt = animInterrupt.get(animation.curAnim.name);
			
			if (altAnim != wasAltIdle)
				wasAltIdle = altAnim;

			if (canInterrupt)
			{
				if (animation.exists('danceRight') && animation.exists('danceLeft'))
				{
					danced = !danced;

					if (altAnim && animation.getByName('danceRight-alt') != null && animation.getByName('danceLeft-alt') != null)
					{
						if (danced)
							playAnim('danceRight-alt');
						else
							playAnim('danceLeft-alt');
					}
					else
					{
						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				}
				else
				{
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		if (animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such animation doesnt exist: ' + AnimName]);
			#end
			return;
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function changeCharacter(name:String)
	{
		curCharacter = name;
		jsonScale = 1;
		parseDataFile();
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	public static var characterList:Array<String> = [];

	public static var girlfriendList:Array<String> = [];

	static var missingChars:Array<String> = [];

	public static function initDefaultCharacters():Bool {
		#if CHECK_FOR_DEFAULT_CHARACTERS
		for (char in EngineConstants.defaultCharacters)
		{
			if (OpenFlAssets.exists(Paths.getJson('characters/${char}/${char}')))
				characterList.push(char);
			else
				missingChars.push(char);
		}

		if (missingChars.length == 0)
			return true;
		else
			return false;
		#else
			return true;
		#end
	}

	public static function initCharacterList()
	{
		characterList = [];

		girlfriendList = [];

		var pathcheck = listCharacters();

		if (initDefaultCharacters())
		{
			Debug.logInfo('Succesfully loaded all default characters, starting loading mod chars');
			for (charId in pathcheck)
			{
				if (characterList.contains(charId))
					continue;
				else{
					characterList.push(charId);

					var charData:CharacterData = Paths.loadJSONInDefaultLibrary('characters/${charId}/${charId}');
					if (charData == null)
					{
						Debug.logError('Character $charId failed to load.');
						characterList.remove(charId);
						continue;
					}
				}
			}
		}
		else
		{
			var missChars:String = '';
			if (missingChars.length > 1)
			{
				for (char in missingChars)
				{
					if (missingChars.indexOf(char) != missingChars.length - 1)
						missChars += char + ', ';
					else
						missChars += char;
				}
			}
			else
				missChars = missingChars[0];

			Debug.logWarn('Missing default characters: ' + missChars);

			for (charId in pathcheck)
			{
				if (characterList.contains(charId))
					continue;
				else{
					characterList.push(charId);

					var charData:CharacterData = Paths.loadJSONInDefaultLibrary('characters/${charId}/${charId}');
					if (charData == null)
					{
						Debug.logError('Character $charId failed to load.');
						characterList.remove(charId);
						continue;
					}
				}
			}
		}	
	}

	public static function getCharacterIcon(char:String):String
	{
		var jsonData;
		if (OpenFlAssets.exists(Paths.getJson('characters/${char}/${char}')))
		{
			jsonData = Paths.loadJSONInDefaultLibrary('characters/${char}/${char}');
		}
		else
		{
			Debug.logError('There is no character with this name!');
			return 'face';
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${char}');
			return 'face';
		}

		if (Reflect.field(jsonData, 'name') != null)
		{
			var data:CharacterData = cast jsonData;
			return data.characterIcon;
		}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null)
		{
			var data:PsychCharacterFile = cast jsonData;
			return data.healthicon;
		}
		else
			return 'face';
	}

	public static function getCharacterColor(char:String):Array<Int>
	{
		var jsonData;
		if (OpenFlAssets.exists(Paths.getJson('characters/${char}/${char}')))
		{
			jsonData = Paths.loadJSONInDefaultLibrary('characters/${char}/${char}');
		}
		else
		{
			Debug.logError('There is no character with this name!');
			return [0, 0, 0];
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${char}');
			return [0, 0, 0];
		}

		if (Reflect.field(jsonData, 'name') != null)
		{
			var data:CharacterData = cast jsonData;
			return data.barColorJson;
		}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null)
		{
			var data:PsychCharacterFile = cast jsonData;
			return data.healthbar_colors;
		}
		else
			return [0, 0, 0];
	}

	function loadAltronixEngineCharacter(jsonData:Dynamic)
	{
		var data:CharacterData = cast jsonData;
		var tex:FlxAtlasFrames;

		frames = Paths.getCharacterFrames(curCharacter, data.asset.replaceAll('characters/', ''));

		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipX = anim.flipX == null ? false : anim.flipX;
				var flipY = anim.flipY == null ? false : anim.flipY;

				if (anim.frameIndices.length > 0)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
				}

				animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
				animInterrupt[anim.name] = anim.interrupt == null ? true : anim.interrupt;

				if (data.isDancing && anim.isDanced != null)
					animDanced[anim.name] = anim.isDanced;

				if (anim.nextAnim != null)
					animNext[anim.name] = anim.nextAnim;
			}

		this.replacesGF = data.replacesGF == null ? false : data.replacesGF;
		this.hasTrail = data.hasTrail == null ? false : data.hasTrail;
		this.isDancing = data.isDancing == null ? false : data.isDancing;
		this.positionArray = data.charPos == null ? [0, 0] : data.charPos;
		this.camPos = data.camPos == null ? [0, 0] : data.camPos;
		this.camFollow = data.camFollow == null ? [0, 0] : data.camFollow;
		this.holdLength = data.holdLength == null ? 4 : data.holdLength;
		this.characterIcon = data.characterIcon == null ? 'face' : data.characterIcon;

		flipX = data.flipX == null ? false : data.flipX;

		animationsArray = data.animations;
		asset = data.asset;
		jsonScale = data.scale;
		cameraPosition = data.camPos;
		originalFlipX = data.flipX;
		startingAnim = data.startingAnim;

		setGraphicSize(Std.int(width * jsonScale));
		updateHitbox();

		charAntialiasing = data.antialiasing;

		antialiasing = data.antialiasing;

		if (data.barColorJson != null && data.barColorJson.length > 2)
			healthColorArray = data.barColorJson;

		barColor = FlxColor.fromRGB(healthColorArray[0], healthColorArray[1], healthColorArray[2]);

		playAnim(data.startingAnim);
	}

	function loadPsychEngineCharacter(rawJson:Dynamic) {
		var json:PsychCharacterFile = cast rawJson;
		
		frames = Paths.getCharacterFrames(curCharacter, json.image.replaceAll('characters/', ''));

		if (json.scale != 1)
		{
			jsonScale = json.scale;
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}

		this.positionArray = json.position == null ? [0, 0] : json.position;
		this.camPos = json.camera_position == null ? [0, 0] : json.camera_position;
		this.camFollow = json.camera_position == null ? [0, 0] : json.camera_position;
		this.replacesGF = false;
		this.hasTrail = false;
		this.isDancing = false;
		this.holdLength = json.sing_duration == null ? 4 : json.sing_duration;
		this.characterIcon = json.healthicon == null ? 'face' : json.healthicon;

		flipX = json.flip_x == null ? false : !!json.flip_x;

		asset = json.image;
		jsonScale = json.scale;
		cameraPosition = json.camera_position;
		originalFlipX = json.flip_x == null ? false : !!json.flip_x;

		setGraphicSize(Std.int(width * jsonScale));
		updateHitbox();

		if (json.no_antialiasing)
		{
			antialiasing = false;
		}

		if (json.healthbar_colors != null && json.healthbar_colors.length > 2)
			healthColorArray = json.healthbar_colors;

		if (!FlxG.save.data.antialiasing)
			antialiasing = false;

		if (json.animations != null && json.animations.length > 0)
		{
			for (anim in json.animations)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; // Bruh
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0)
				{
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}
				else
				{
					animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}

				animOffsets[animAnim] = anim.offsets == null ? [0, 0] : anim.offsets;
				animInterrupt[animAnim] = true;

				animNext[animAnim] = 'idle';
			}
		}
		else
		{
			quickAnimAdd('idle', 'BF idle dance');
		}

		barColor = FlxColor.fromRGB(healthColorArray[0], healthColorArray[1], healthColorArray[2]);

		playAnim('idle');
	}

	static function listCharacters()
	{
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = 'assets/characters/';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.contains(queryPath) && data.endsWith('.json'))
			{
				results.push(data.replaceAll('.json', '').replaceAll(queryPath, '').removeBefore('/').replaceAll('/', ''));
			}
		}
		return results;
	}
}

typedef CharacterData =
{
	var name:String;
	var asset:String;
	var startingAnim:String;

	var ?isGF:Bool;

	var ?characterIcon:String;

	var ?charPos:Array<Float>;
	var ?camPos:Array<Float>;
	var ?camFollow:Array<Float>;
	var ?holdLength:Float;

	var barColorJson:Array<Int>;

	var animations:Array<AnimationData>;

	var scale:Int;

	var ?flipX:Bool;

	var antialiasing:Bool;

	var ?usePackerAtlas:Bool;

	var ?useSpriteMap:Bool;

	var ?isDancing:Bool;

	var ?hasTrail:Bool;

	var ?replacesGF:Bool;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var offsets:Array<Int>;

	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	var frameRate:Int;

	var frameIndices:Array<Int>;

	var ?interrupt:Bool;

	var ?nextAnim:String;

	var ?isDanced:Bool;
}

//Well-well-well, psych engine characters...
typedef PsychCharacterFile =
{
	var animations:Array<PsychAnimArray>;
	var image:String;
	var scale:Float;
	var ?sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var ?flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef PsychAnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}