package gameplayStuff;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import animateatlas.AtlasFrameMaker;
import states.PlayState;

using StringTools;

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

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				if (animation.getByName('singRIGHT') != null && animation.getByName('singLEFT') != null){
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null && animation.getByName('singLEFTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData;
		if (OpenFlAssets.exists(Paths.json('characters/${curCharacter}')))
		{
			jsonData = Paths.loadJSON('characters/${curCharacter}');
		}
		else
		{
			Debug.logError('There is no character with this name!');
			jsonData = Paths.loadJSON('characters/dad');
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:CharacterData = cast jsonData;
		var tex:FlxAtlasFrames;

		if (data.usePackerAtlas)
		{
			tex = Paths.getPackerAtlas(data.asset, 'shared');
			frames = tex;
		}
		/*else if (data.useSpriteMap)
		{
			frames = AtlasFrameMaker.construct(data.asset);
		}*/
		else
		{
			tex = Paths.getSparrowAtlas(data.asset, 'shared');
			frames = tex;
		}

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
					dance();
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
				dance();
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

	public static function initCharacterList()
	{
		characterList = [];

		girlfriendList = [];

		var pathcheck = Paths.listJsonInPath('assets/data/characters/');

		for (charId in pathcheck)
		{
			characterList.push(charId);

			var charData:CharacterData = Paths.loadJSON('characters/${charId}');
			if (charData == null)
			{
				Debug.logError('Character $charId failed to load.');
				characterList.remove(charId);
				continue;
			}
			if (charData.isGF)
				girlfriendList.push(charId);								
		}
	}
}

typedef CharacterData =
{
	var name:String;
	var asset:String;
	var startingAnim:String;

	/**
	 * Value is true if the character is a Girlfriend character.
	 * Meant only to dance in the BG and play animations.
	 * Will not have singing animations.
	 * @default false
	 */
	 var ?isGF:Bool;

	/**
	 * Character health icon
	 * @default 'face'
	 */
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

	/**
	 * Whether this character uses PackerAtlas.
	 * @default false
	 */
	var ?usePackerAtlas:Bool;


	/**
	 * Whether this character uses SpriteMap.
	 * @default false
	 */
	 var ?useSpriteMap:Bool;

	/**
	 * Whether this character uses a dancing idle instead of a regular idle.
	 * (ex. gf, spooky)	
	 * @default false
	 */
	var ?isDancing:Bool;

	/**
	 * Whether this character has a trail behind them.
	 * @default false
	 */
	var ?hasTrail:Bool;

	/**
	 * Whether this character replaces gf if they are set as dad.
	 * @default false
	 */
	var ?replacesGF:Bool;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	var frameRate:Int;

	var frameIndices:Array<Int>;

	/**
	 * Whether this animation can be interrupted by the dance function.
	 * @default true
	 */
	var ?interrupt:Bool;

	/**
	 * The animation that this animation will go to after it is finished.
	 */
	var ?nextAnim:String;

	/**
	 * Whether this animation sets danced to true or false.
	 * Only works for characters with isDancing enabled.
	 */
	var ?isDanced:Bool;
}
