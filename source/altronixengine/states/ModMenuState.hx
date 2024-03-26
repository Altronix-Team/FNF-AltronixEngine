package altronixengine.states;

import altronixengine.gameplayStuff.FreeplaySongMetadata;
#if FEATURE_MODCORE
import polymod.Polymod.ModMetadata;
#end
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import altronixengine.modding.*;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

class ModMenuState extends MusicBeatState
{
	public var bg:FlxSprite;

	var modsObjects:FlxTypedGroup<ModObject>;

	var emptyModFolder:FlxText;

	var curSelected:Int = 0;

	public static var instance:ModMenuState = null;

	override public function create()
	{
		instance = this;

		super.create();

		// create background
		bg = new FlxSprite().loadGraphic(Paths.loadImage('menuDesat'));
		bg.setGraphicSize(Std.int(FlxG.width));
		bg.scrollFactor.set();
		bg.blend = BlendMode.DIFFERENCE;
		bg.color = 0x3DC749;
		bg.screenCenter();
		add(bg);

		modsObjects = new FlxTypedGroup<ModObject>();
		add(modsObjects);

		generateModsItems();

		if (emptyModFolder == null)
			changeSelection();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (upP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		else if (downP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}

		if (controls.ACCEPT)
		{
			modsObjects.members[curSelected].isEnabled = !modsObjects.members[curSelected].isEnabled;
		}

		if (controls.BACK)
		{
			FreeplaySongMetadata.preloaded = false;

			ModCore.loadConfiguredMods();
			ModUtil.reloadSavedMods();

			MusicBeatState.switchState(new TitleState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = modsObjects.members.length - 1;
		if (curSelected >= modsObjects.members.length)
			curSelected = 0;

		var shit = 0;
		@:privateAccess
		modsObjects.forEach(function(spr:ModObject)
		{
			spr.titleText.targetY = shit - curSelected;
			shit++;
			if (spr._ModId == curSelected)
				spr.alpha = 1;
			else
				spr.alpha = 0.5;
		});
	}

	function generateModsItems():Void
	{
		var allMods:Array<ModMetadata> = ModUtil.getAllMods();
		if (allMods.length > 0)
		{
			for (i in 0...allMods.length)
			{
				var mod = allMods[i];
				var modObj:ModObject = new ModObject(0, (70 * i) + 60, mod, i);
				modObj.isEnabled = ModUtil.modList.get(mod.id);
				@:privateAccess
				modObj.firstLoad = false;
				modsObjects.add(modObj);
			}
			add(modsObjects);
		}
		else
		{
			emptyModFolder = new FlxText(0, 0, 0, 'NO MODS INSTALLED\nPRESS BACK TO EXIT AND INSTALL A MOD');
			emptyModFolder.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
			emptyModFolder.screenCenter(XY);
			add(emptyModFolder);
		}
	}
}

class ModObject extends FlxTypedSpriteGroup<FlxSprite>
{
	private var _ModId:Int = 0;
	private var _modData(default, set):ModMetadata = null;

	private var titleText:Alphabet;
	private var descriptionText:AttachedText;

	private var modIcon:AttachedSprite;
	private var checkbox:AttachedSprite;

	public var isEnabled(default, set):Bool = false;

	private var firstLoad:Bool = true;

	public function new(x:Int = 0, y:Int = 0, modData:ModMetadata, modId:Int = 0)
	{
		super();

		this.x = x;
		this.y = y;
		this._ModId = modId;

		_modData = modData;
	}

	private function generateAll()
	{
		if (_modData == null)
			return;

		titleText = new Alphabet(-100, y, _modData.title == '' ? 'Unknown mod title' : _modData.title, true, false);
		titleText.isMenuItem = true;
		titleText.targetY = _ModId;
		titleText.size = 0.2;

		checkbox = new AttachedSprite('checkboxanim', 'checkbox0', 'core', false);
		checkbox.playAnim('idle', true, false, 0, true);
		checkbox.xAdd = titleText.width + 20;
		checkbox.yAdd = -20;
		checkbox.sprTracker = titleText;
		checkbox.addOffset('idle', 0, 2);
		checkbox.animation.addByPrefix('check', 'checkbox anim0', 24, false);
		checkbox.addOffset('check', 34, 25);
		checkbox.animation.addByPrefix('checked-idle', 'checkbox finish0', 24, false);
		checkbox.addOffset('checked-idle', 3, 12);
		checkbox.animation.addByPrefix('check-reversed', 'checkbox anim reverse0', 24, false);
		checkbox.addOffset('check-reversed', 25, 28);
		checkbox.setGraphicSize(100, 100);
		checkbox.updateHitbox();

		if (isEnabled)
			checkbox.playAnim('checked-idle', true, false, 0, true);

		if (_modData.icon != null)
		{
			modIcon = new AttachedSprite();
			modIcon.loadGraphic(FlxGraphic.fromBitmapData(ImageOutline.outline(BitmapData.fromBytes(_modData.icon), 6, 0x000000, 1, true)));
			modIcon.setGraphicSize(100, 100);
			modIcon.updateHitbox();
			modIcon.xAdd = -100;
			modIcon.yAdd = -20;
			modIcon.sprTracker = titleText;
		};

		descriptionText = new AttachedText(titleText.x, titleText.getGraphicMidpoint().y);
		descriptionText.text = _modData.description;
		descriptionText.size = 16;
		descriptionText.sprTracker = titleText;
		descriptionText.yAdd = titleText.height;
		descriptionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);

		if (_modData.icon != null)
			add(modIcon);
		add(titleText);
		add(descriptionText);
		add(checkbox);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (checkbox.animation.curAnim != null)
			if (checkbox.animation.curAnim.finished
				&& (checkbox.animation.curAnim.name == 'check' || checkbox.animation.curAnim.name == 'check-reversed'))
			{
				if (isEnabled)
					checkbox.playAnim('checked-idle', true);
				else
					checkbox.playAnim('idle', true);
			}
	}

	function set__modData(value:ModMetadata):ModMetadata
	{
		if (value != null)
		{
			_modData = value;
			generateAll();
		}
		return value;
	}

	function set_isEnabled(value:Bool):Bool
	{
		if (!firstLoad)
			ModUtil.setModEnabled(_modData.id, value);
		if (value)
		{
			checkbox.playAnim('check', true);
		}
		else
		{
			checkbox.playAnim('check-reversed', true);
		}
		isEnabled = value;
		return value;
	}
}

class AttachedText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var strumTime:Float = 0;
	public var position:Int = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}
