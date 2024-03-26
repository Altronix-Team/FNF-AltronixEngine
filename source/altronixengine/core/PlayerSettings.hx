package altronixengine.core;

import altronixengine.core.Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings
{
	static public var numPlayers(default, null) = 0;
	static public var numAvatars(default, null) = 0;
	static public var player1(default, null):PlayerSettings;
	static public final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	static public final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();

	public var id(default, null):Int;

	public final controls:Controls;

	function new(id)
	{
		this.id = id;
		this.controls = new Controls('player$id');
	}

	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0);
			++numPlayers;
		}

		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.controls.addDefaultGamepad(0);
		}
		// DeviceManager.init();
	}

	static public function reset()
	{
		player1 = null;
		numPlayers = 0;
	}
}
