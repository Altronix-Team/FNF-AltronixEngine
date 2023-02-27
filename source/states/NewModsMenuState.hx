package states;

import flixel.FlxObject;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUISprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import modding.*;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

#if FEATURE_MODCORE
import polymod.Polymod;
#end

/*
	the Mods Menu, handles mod managment;
 */
class NewModsMenuState extends MusicBeatState
{
	public var background:FlxSprite;
	public var boyfriend:FlxSprite;
	public var itemGroup:FlxTypedGroup<Alphabet>;
	public var modBackground:FlxUI9SliceSprite;

	var modsObjects:FlxTypedGroup<ModObject>;

	var emptyModFolder:FlxText;

	var curSelected:Int = 0;

	var curSelectedMod:ModObject = null;

	public static var instance:NewModsMenuState = null;

	var camFollow:FlxObject;

	override public function create()
	{
		instance = this;

		ModUtil.reloadSavedMods();

		super.create();

		// create background
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(19, 21, 33));
		background.scrollFactor.set();
		background.screenCenter();
		add(background);

		boyfriend = new FlxSprite().loadGraphic(Paths.loadImage('menuBG'));
		boyfriend.setGraphicSize(Std.int(FlxG.width));
		boyfriend.scrollFactor.set();
		boyfriend.blend = BlendMode.DIFFERENCE;
		boyfriend.screenCenter();
		boyfriend.alpha = 0;
		add(boyfriend);
		FlxTween.tween(boyfriend, {alpha: 0.07}, 0.4);

		modBackground = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_CHROME, new Rectangle(0, 0, 1100, 450));
		modBackground.screenCenter(XY);
		modBackground.x -= modBackground.width / 2;
		modBackground.y -= modBackground.height / 2;
		add(modBackground);

		modsObjects = new FlxTypedGroup<ModObject>();
		add(modsObjects);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		generateModsItems();

		changeSelection();

		FlxG.camera.follow(camFollow, null, 1);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;

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

		if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = modsObjects.members.length - 1;
		if (curSelected >= modsObjects.members.length)
			curSelected = 0;

		modsObjects.forEach(function(spr:ModObject)
		{
			spr.moveAll(Std.int(modBackground.getGraphicMidpoint().x), Std.int(modBackground.getGraphicMidpoint().y + 100 * curSelected));
		});
	}

	function generateModsItems():Void
	{
		var allMods:Array<ModMetadata> = ModUtil.getAllMods();
		if (allMods.length > 0)
		{
			for (mod in allMods)
			{
				var modObj:ModObject = new ModObject(Std.int(modBackground.x - modBackground.width / 2), Std.int(modBackground.y - modBackground.height / 2 - 100 * allMods.indexOf(mod)), mod);
				modObj.isEnabled = ModUtil.modList.get(mod.title);
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

class ModObject extends FlxTypedGroup<FlxSprite>
{
	private var _modData(default, set):ModMetadata = null;

	private var tittleText:Alphabet;
	private var descriptionText:FlxText = new FlxText();

	private var modIcon:ModIcon = new ModIcon();

	public var isEnabled(default, set):Bool = false;

	public var targetY:Int = 0;

	private var x:Int = 0;
	private var y:Int = 0;

	public function new(x:Int = 0, y:Int = 0, modData:ModMetadata)
	{
		super();

		this.x = x;
		this.y = y;

		_modData = modData;
	}

	private function regenerateAll()
	{
		if (_modData == null)
			return;

		if (members.contains(tittleText))
			remove(tittleText);
		if (members.contains(descriptionText))
			remove(descriptionText);
		if (members.contains(modIcon))
			remove(modIcon);

		modIcon.loadGraphic(FlxGraphic.fromBitmapData(if (_modData.icon != null)
		{
			BitmapData.fromBytes(_modData.icon);
		} else
		{
			new BitmapData(80, 80);
		}));
		modIcon.setGraphicSize(80, 80);
		tittleText = new Alphabet(modIcon.x + modIcon.width + 15, NewModsMenuState.instance.modBackground.y + 15);
		tittleText.text = if (_modData.title != null)
		{
			_modData.title;
		}
		else
		{
			"UnknownTitle";
		}
		// tittleText.size = 48;
		descriptionText.text = _modData.description;
		descriptionText.size = 32;

		descriptionText.x = modIcon.x + modIcon.width + 15;

		descriptionText.y = tittleText.y + 15;

		add(modIcon);
		add(tittleText);
		add(descriptionText);
	}

	public function moveAll(targetX:Int = 0, targetY:Int = 0)
	{
		tittleText.x = modIcon.x + modIcon.width + 15;
		descriptionText.x = modIcon.x + modIcon.width + 15;

		tittleText.y = NewModsMenuState.instance.modBackground.y + 15;
		descriptionText.y = tittleText.y + 15;
	}

	function set__modData(value:ModMetadata):ModMetadata
	{
		if (value != null)
		{
			_modData = value;
			regenerateAll();
		}
		return value;
	}

	function set_isEnabled(value:Bool):Bool
	{
		// loadButton.color = if (value) FlxColor.GREEN; else FlxColor.RED;
		isEnabled = value;
		return value;
	}
}

class ModIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x - width, sprTracker.y - 30);
	}
}
