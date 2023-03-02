package;

import flixel.system.FlxAssets.FlxGraphicAsset;
import gameplayStuff.Section.SwagSection;
import flxanimate.FlxAnimate;
import flixel.FlxSprite;

class FNFSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

	public var animateAtlas:FlxAnimate;

	private var atlasPlayingAnim:String = '';

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		animOffsets = new Map();
		
		Main.fnfSignals.beatHit.add(beatHit);
		Main.fnfSignals.stepHit.add(stepHit);
		Main.fnfSignals.sectionHit.add(sectionHit);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, autoEnd:Bool = false):Void
	{
		if (animateAtlas != null && animateAtlas.anim.getByName(AnimName) == null)
		{
			Debug.logWarn(['Such animation doesnt exist: ' + AnimName]);
			return;
		}

		if (animateAtlas == null && animation.getByName(AnimName) == null)
		{
			Debug.logWarn(['Such animation doesnt exist: ' + AnimName]);
			return;
		}

		if (animateAtlas != null)
		{
			@:privateAccess
			animateAtlas.anim.play(AnimName, Force, Reversed, Frame);
			atlasPlayingAnim = AnimName;
		}
		else
		{
			if (!animation.exists(AnimName))
				return;
			animation.play(AnimName, Force, Reversed, Frame);
		}

		if (autoEnd)
		{
			if (animateAtlas != null)
			{
				animateAtlas.anim.curFrame = animateAtlas.anim.length;
			}
			else
				animation.curAnim.finish();
		}

		var daOffset = animOffsets.get(AnimName);
		if (animateAtlas != null)
		{
			if (animOffsets.exists(AnimName))
			{
				animateAtlas.offset.set(daOffset[0], daOffset[1]);
			}
			else
				animateAtlas.offset.set(0, 0);
		}
		else
		{
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}
	}

	public function copyAtlasValues()
	{
		animateAtlas.cameras = cameras;
		animateAtlas.scrollFactor = scrollFactor;
		animateAtlas.scale = scale;
		animateAtlas.angle = angle;
		animateAtlas.alpha = alpha;
		animateAtlas.visible = visible;
		animateAtlas.flipX = flipX;
		animateAtlas.flipY = flipY;
		animateAtlas.shader = shader;
		animateAtlas.antialiasing = antialiasing;
	}

	public override function draw()
	{
		if (animateAtlas != null)
		{
			copyAtlasValues();
			animateAtlas.draw();
		}
		else
		{
			super.draw();
		}
	}

	public override function destroy()
	{
		Main.fnfSignals.beatHit.remove(beatHit);
		Main.fnfSignals.stepHit.remove(stepHit);
		Main.fnfSignals.sectionHit.remove(sectionHit);
		super.destroy();
		if (animateAtlas != null)
		{
			animateAtlas.destroy();
			animateAtlas = null;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	public function getCurAnim():Dynamic
	{
		if (animateAtlas != null)
			return animateAtlas.anim;
		else
			return animation.curAnim;
	}

	public inline function getCurAnimName()
	{
		var name = null;
		if (animateAtlas != null)
		{
			name = atlasPlayingAnim;
		}
		else
		{
			if (animation.curAnim != null)
				name = animation.curAnim.name;
		}
		return name;
	}

	public function animationExists(animName:String):Bool
	{
		@:privateAccess
		if (animateAtlas != null)
			return animateAtlas.anim.animsMap.exists(animName) || animateAtlas.anim.symbolDictionary.exists(animName);
		else
			return animation.exists(animName);
	}

	@:noCompletion
	override function set_x(value:Float):Float
	{
		if (animateAtlas != null)
			animateAtlas.x = value;
		return super.set_x(value);
	}

	@:noCompletion
	override function set_y(value:Float):Float
	{
		if (animateAtlas != null)
			animateAtlas.y = value;
		return super.set_y(value);
	}

	public function beatHit(beat:Int){}

	public function stepHit(step:Int){}

	public function sectionHit(section:SwagSection){}
}