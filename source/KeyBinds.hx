import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
	public static var gamepad:Bool = false;

	public static function resetBinds():Void
	{
		Main.save.data.upBindP2 = "W";
		Main.save.data.downBindP2 = "S";
		Main.save.data.leftBindP2 = "A";
		Main.save.data.rightBindP2 = "D";
		Main.save.data.upBind = "UP";
		Main.save.data.downBind = "DOWN";
		Main.save.data.leftBind = "LEFT";
		Main.save.data.rightBind = "RIGHT";
		Main.save.data.muteBind = "ZERO";
		Main.save.data.volUpBind = "PLUS";
		Main.save.data.volDownBind = "MINUS";
		Main.save.data.fullscreenBind = "F";
		Main.save.data.gpupBind = "DPAD_UP";
		Main.save.data.gpdownBind = "DPAD_DOWN";
		Main.save.data.gpleftBind = "DPAD_LEFT";
		Main.save.data.gprightBind = "DPAD_RIGHT";
		Main.save.data.pauseBind = "ENTER";
		Main.save.data.gppauseBind = "START";
		Main.save.data.resetBind = "R";
		Main.save.data.gpresetBind = "SELECT";

		FlxG.sound.muteKeys = ["ZERO", "NUMPADZERO"];
		FlxG.sound.volumeDownKeys = ["MINUS", "NUMPADMINUS"];
		FlxG.sound.volumeUpKeys = ["PLUS", "NUMPADPLUS"];
		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
		if (Main.save.data.upBindP2 == null)
		{
			Main.save.data.upBindP2 = "W";
			trace("No UP");
		}
		if (Main.save.data.downBindP2 == null)
		{
			Main.save.data.downBindP2 = "S";
			trace("No DOWN");
		}
		if (Main.save.data.leftBindP2 == null)
		{
			Main.save.data.leftBindP2 = "A";
			trace("No LEFT");
		}
		if (Main.save.data.rightBindP2 == null)
		{
			Main.save.data.rightBindP2 = "D";
			trace("No RIGHT");
		}

		if (Main.save.data.upBind == null)
		{
			Main.save.data.upBind = "UP";
			trace("No UP");
		}
		if (Main.save.data.downBind == null)
		{
			Main.save.data.downBind = "DOWN";
			trace("No DOWN");
		}
		if (Main.save.data.leftBind == null)
		{
			Main.save.data.leftBind = "LEFT";
			trace("No LEFT");
		}
		if (Main.save.data.rightBind == null)
		{
			Main.save.data.rightBind = "RIGHT";
			trace("No RIGHT");
		}

		if (Main.save.data.gpupBind == null)
		{
			Main.save.data.gpupBind = "DPAD_UP";
			trace("No GUP");
		}
		if (Main.save.data.gpdownBind == null)
		{
			Main.save.data.gpdownBind = "DPAD_DOWN";
			trace("No GDOWN");
		}
		if (Main.save.data.gpleftBind == null)
		{
			Main.save.data.gpleftBind = "DPAD_LEFT";
			trace("No GLEFT");
		}
		if (Main.save.data.gprightBind == null)
		{
			Main.save.data.gprightBind = "DPAD_RIGHT";
			trace("No GRIGHT");
		}
		if (Main.save.data.pauseBind == null)
		{
			Main.save.data.pauseBind = "ENTER";
			trace("No ENTER");
		}
		if (Main.save.data.gppauseBind == null)
		{
			Main.save.data.gppauseBind = "START";
			trace("No ENTER");
		}
		if (Main.save.data.resetBind == null)
		{
			Main.save.data.resetBind = "R";
			trace("No RESET");
		}
		if (Main.save.data.gpresetBind == null)
		{
			Main.save.data.gpresetBind = "SELECT";
			trace("No RESET");
		}
		// VOLUME CONTROLS !!!!
		if (Main.save.data.muteBind == null)
		{
			Main.save.data.muteBind = "ZERO";
			trace("No MUTE");
		}
		if (Main.save.data.volumeUpKeys == null)
		{
			Main.save.data.volumeUpKeys = ["PLUS"];
			trace("No VOLUP");
		}
		if (Main.save.data.volumeDownKeys == null)
		{
			Main.save.data.volumeDownKeys = ["MINUS"];
			trace("No VOLDOWN");
		}
		if (Main.save.data.fullscreenBind == null)
		{
			Main.save.data.fullscreenBind = "F";
			trace("No FULLSCREEN");
		}

		trace('${Main.save.data.leftBind}-${Main.save.data.downBind}-${Main.save.data.upBind}-${Main.save.data.rightBind}');
	}
}
