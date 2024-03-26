package altronixengine.gameplayStuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flxanimate.FlxAnimate;
import openfl.utils.Assets as OpenFlAssets;
import altronixengine.core.musicbeat.FNFSprite;

class Character extends FNFSprite
{
	public static var DEFAULT_CHARACTER:String = 'bf';

	public var animInterrupt:Map<String, Bool>;
	public var animNext:Map<String, String>;
	public var animDanced:Map<String, Bool>;
	public var debugMode:Bool = false;
	public var stunned:Bool = false;

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
	public var specialAnim:Bool = false;
	public var psychChar:Bool = false;

	public var healthIcon:HealthIcon = null;

	var wasAltIdle:Bool = false;

	public var altIdle:Bool = false;

	public var ghost:FlxSprite = null;
	public var ghostTween:FlxTween = null;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		animInterrupt = new Map<String, Bool>();
		animNext = new Map<String, String>();
		animDanced = new Map<String, Bool>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		parseDataFile();

		ghost = new FlxSprite(x, y);
		ghost.frames = frames;
		ghost.visible = false;
		ghost.animation.copyFrom(animation);
		ghost.blend = HARDLIGHT;
		ghost.alpha = 0.8;
		ghost.animation.finishCallback = function(name:String)
		{
			ghost.visible = false;
		}

		recalculateDanceIdle();

		if (isPlayer && frames != null)
		{
			flipX = !flipX;
		}

		healthIcon = new HealthIcon(curCharacter, characterIcon, isPlayer);

		dance();
	}

	override public function draw()
	{
		ghost.x = x;
		ghost.y = y;
		ghost.flipX = flipX;
		ghost.flipY = flipY;
		if (ghost.visible)
			ghost.draw();
		super.draw();
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData;
		if (OpenFlAssets.exists(Paths.json('characters/${curCharacter}/${curCharacter}', "gameplay")))
		{
			jsonData = Paths.loadJSON('characters/${curCharacter}/${curCharacter}', "gameplay");
		}
		else
		{
			Debug.logError('There is no character with this name!');
			jsonData = Paths.loadJSON('characters/dad/dad', "gameplay");
		}
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		if (Reflect.field(jsonData, 'name') != null)
		{
			loadAltronixEngineCharacter(jsonData);
		}
		else if (Reflect.field(jsonData, 'no_antialiasing') != null)
		{
			psychChar = true;
			Debug.logTrace('Looks like Psych engine character');
			loadPsychEngineCharacter(jsonData);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!debugMode && !isAnimationNull())
		{
			var nextAnim = animNext.get(getCurAnimName());
			var forceDanced = animDanced.get(getCurAnimName());

			if (nextAnim != null && isAnimationFinished())
			{
				if (specialAnim)
					specialAnim = false;
				if (isDancing && forceDanced != null)
					danced = forceDanced;
				playAnim(nextAnim);
				return;
			}

			if (!isPlayer)
			{
				if (getCurAnimName().startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * holdLength * 0.001)
				{
					if (isDancing)
						playAnim('danceLeft');
					dance(false, wasAltIdle);
					holdTimer = 0;

					if (color != FlxColor.WHITE)
						color = FlxColor.WHITE;
				}
			}
		}

		if (isAnimationNull())
			dance(true, wasAltIdle);
	}

	private var danced:Bool = false;

	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			var canInterrupt = true;
			if (!isAnimationNull())
				canInterrupt = animInterrupt.get(getCurAnimName());

			if (altAnim != wasAltIdle)
				wasAltIdle = altAnim;

			if (canInterrupt)
			{
				if (animationExists('danceRight') && animationExists('danceLeft'))
				{
					danced = !danced;

					if (altAnim && animationExists('danceRight-alt') && animationExists('danceLeft-alt'))
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
					if (altAnim && animationExists('idle-alt'))
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
				}
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, autoEnd:Bool = false):Void
	{
		if (animateAtlas != null && animateAtlas.anim.getByName(AnimName) == null && AnimName.endsWith('alt'))
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		if (animateAtlas == null && AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		super.playAnim(AnimName, Force, Reversed, Frame);

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

	override public function beatHit()
	{
		if (curBeat % danceEveryNumBeats == 0)
		{
			if (!isAnimationNull())
			{
				if (!getCurAnimName().contains('sing') || isAnimationFinished())
				{
					dance(true, wasAltIdle);
				}
			}
			else
				dance(true, altIdle);
		}
	}

	public var danceEveryNumBeats:Int = 2;
	public var danceIdle:Bool = false;

	public function recalculateDanceIdle()
	{
		danceIdle = (animationExists('danceLeft') && animationExists('danceRight'));

		danceEveryNumBeats = (danceIdle ? 1 : 2);
	}

	function loadAltronixEngineCharacter(jsonData:Dynamic)
	{
		var data:CharacterData = cast jsonData;
		var tex:FlxFramesCollection = Paths.getCharacterFrames(curCharacter, data.asset.replaceAll('characters/', ''));

		if (tex != null)
			frames = tex;
		else
		{
			animateAtlas = new FlxAnimate(x, y, Paths.getPath('characters/$curCharacter/${data.asset.replaceAll('characters/', '')}', BINARY, 'gameplay'));
		}

		for (anim in data.animations)
		{
			var frameRate = anim.frameRate;
			var looped = anim.looped == null ? false : anim.looped;
			var flipX = anim.flipX == null ? false : anim.flipX;
			var flipY = anim.flipY == null ? false : anim.flipY;

			if (anim.frameIndices.length > 0)
			{
				if (animateAtlas != null)
					animateAtlas.anim.addBySymbolIndices(anim.name, anim.prefix, anim.frameIndices, frameRate, looped);
				else
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
			}
			else
			{
				if (animateAtlas != null)
					animateAtlas.anim.addBySymbol(anim.name, anim.prefix, frameRate, looped);
				else
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
			}

			animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
			animInterrupt[anim.name] = anim.interrupt == null ? true : anim.interrupt;
			animNext[anim.name] = anim.nextAnim;

			if (data.isDancing && anim.isDanced != null)
				animDanced[anim.name] = anim.isDanced;
		}

		replacesGF = data.replacesGF == null ? false : data.replacesGF;
		hasTrail = data.hasTrail == null ? false : data.hasTrail;
		isDancing = data.isDancing == null ? false : data.isDancing;
		positionArray = data.charPos == null ? [0, 0] : data.charPos;
		camPos = data.camPos == null ? [0, 0] : data.camPos;
		camFollow = data.camFollow == null ? [0, 0] : data.camFollow;
		holdLength = data.holdLength == null ? 4 : data.holdLength;
		characterIcon = data.characterIcon == null ? 'face' : data.characterIcon;

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

	function loadPsychEngineCharacter(rawJson:Dynamic)
	{
		var json:PsychCharacterFile = cast rawJson;
		var tex:FlxFramesCollection = Paths.getCharacterFrames(curCharacter, json.image.replaceAll('characters/', ''));

		if (tex != null)
			frames = tex;
		else
		{
			Debug.logInfo('Looks like character uses texture atlas');
			animateAtlas = new FlxAnimate(x, y, Paths.getPath('characters/$curCharacter/${json.image.replaceAll('characters/', '')}', BINARY, 'gameplay'));
		}

		if (json.scale != 1)
		{
			jsonScale = json.scale;
			setGraphicSize(Std.int(width * jsonScale));
			updateHitbox();
		}

		positionArray = json.position == null ? [0, 0] : json.position;
		camPos = json.camera_position == null ? [0, 0] : json.camera_position;
		camFollow = json.camera_position == null ? [0, 0] : json.camera_position;
		replacesGF = false;
		hasTrail = false;
		isDancing = false;
		holdLength = json.sing_duration == null ? 4 : json.sing_duration;
		characterIcon = json.healthicon == null ? 'face' : json.healthicon;

		flipX = json.flip_x == null ? false : !!json.flip_x;

		asset = json.image;
		jsonScale = json.scale;
		cameraPosition = json.camera_position;
		originalFlipX = json.flip_x == null ? false : !!json.flip_x;

		setGraphicSize(Std.int(width * jsonScale));
		updateHitbox();

		charAntialiasing = !json.no_antialiasing;

		antialiasing = !json.no_antialiasing;

		if (json.healthbar_colors != null && json.healthbar_colors.length > 2)
			healthColorArray = json.healthbar_colors;

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
					if (animateAtlas != null)
						animateAtlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					else
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}
				else
				{
					if (animateAtlas != null)
						animateAtlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
					else
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

// Well-well-well, psych engine characters...
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
