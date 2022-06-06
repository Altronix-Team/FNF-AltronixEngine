package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

// Psych code comparability
// With some deletions
class ClientPrefs {
	public static var downScroll:Bool = FlxG.save.data.downscroll;
	public static var middleScroll:Bool = FlxG.save.data.middleScroll;
	public static var showFPS:Bool = FlxG.save.data.fps;
	public static var flashing:Bool = FlxG.save.data.flashing;
	public static var globalAntialiasing:Bool = FlxG.save.data.antialiasing;
	public static var noteSplashes:Bool = FlxG.save.data.notesplashes;
	public static var framerate:Int = FlxG.save.data.fpsCap;
	public static var camZooms:Bool = FlxG.save.data.camzoom;
	public static var noteOffset:Int = FlxG.save.data.offset;
	public static var imagesPersist:Bool = FlxG.save.data.cacheImages;
	public static var ghostTapping:Bool = FlxG.save.data.ghost;
	public static var noReset:Bool = FlxG.save.data.InstantRespawn;
	public static var healthBarAlpha:Float = FlxG.save.data.laneTransparency;

	public static var sickWindow:Int = FlxG.save.data.sickMs;
	public static var goodWindow:Int = FlxG.save.data.goodMs;
	public static var badWindow:Int = FlxG.save.data.badMs;
}