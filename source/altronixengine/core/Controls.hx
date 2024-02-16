package altronixengine.core;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

enum abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
	var ATTACK = "attack";
	var UPP2 = "w";
	var LEFTP2 = "a";
	var RIGHTP2 = "d";
	var DOWNP2 = "s";
	var UP_PP2 = "w-press";
	var LEFT_PP2 = "a-press";
	var RIGHT_PP2 = "d-press";
	var DOWN_PP2 = "s-press";
	var UP_RP2 = "w-release";
	var LEFT_RP2 = "a-release";
	var RIGHT_RP2 = "d-release";
	var DOWN_RP2 = "s-release";
}

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum abstract Control(String) to String from String
{
	var UP = 'up';
	var LEFT = 'left';
	var RIGHT = 'right';
	var DOWN = 'down';
	var UPP2 = 'upP2';
	var LEFTP2 = 'leftP2';
	var RIGHTP2 = 'rightP2';
	var DOWNP2 = 'downP2';
	var RESET = 'reset';
	var ACCEPT = 'accept';
	var BACK = 'back';
	var PAUSE = 'pause';
	var CHEAT = 'cheat';
	var ATTACK = 'attack';
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	public static var gamepad:Bool = false;

	var _up = new Key(Action.UP, Action.UP_P, Action.UP_R);
	var _left = new Key(Action.LEFT, Action.LEFT_P, Action.LEFT_R);
	var _right = new Key(Action.RIGHT, Action.RIGHT_P, Action.RIGHT_R);
	var _down = new Key(Action.DOWN, Action.DOWN_P, Action.DOWN_R);

	var _upP2 = new Key(Action.UPP2, Action.UP_PP2, Action.UP_RP2);
	var _leftP2 = new Key(Action.LEFTP2, Action.LEFT_PP2, Action.LEFT_RP2);
	var _rightP2 = new Key(Action.RIGHTP2, Action.RIGHT_PP2, Action.RIGHT_RP2);
	var _downP2 = new Key(Action.DOWNP2, Action.DOWN_PP2, Action.DOWN_RP2);

	var _accept = new Key(null, Action.ACCEPT);
	var _back = new Key(Action.BACK);
	var _pause = new Key(Action.PAUSE);
	var _reset = new Key(Action.RESET);
	var _cheat = new Key(Action.CHEAT);
	var _attack = new Key(Action.ATTACK);

	var byName:Map<String, FlxActionDigital> = [];

	public var gamepadsAdded:Array<Int> = [];

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.key.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.key.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.key.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.key.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _up.keyP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _left.keyP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _right.keyP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _down.keyP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _up.keyR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _left.keyR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _right.keyR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _down.keyR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.keyP.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.key.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.key.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.key.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.key.check();

	public var ATTACK(get, never):Bool;

	inline function get_ATTACK()
		return _attack.key.check();

	public var UPP2(get, never):Bool;

	inline function get_UPP2()
		return _upP2.key.check();

	public var LEFTP2(get, never):Bool;

	inline function get_LEFTP2()
		return _leftP2.key.check();

	public var RIGHTP2(get, never):Bool;

	inline function get_RIGHTP2()
		return _rightP2.key.check();

	public var DOWNP2(get, never):Bool;

	inline function get_DOWNP2()
		return _downP2.key.check();

	public var UP_PP2(get, never):Bool;

	inline function get_UP_PP2()
		return _upP2.keyP.check();

	public var LEFT_PP2(get, never):Bool;

	inline function get_LEFT_PP2()
		return _leftP2.keyP.check();

	public var RIGHT_PP2(get, never):Bool;

	inline function get_RIGHT_PP2()
		return _rightP2.keyP.check();

	public var DOWN_PP2(get, never):Bool;

	inline function get_DOWN_PP2()
		return _downP2.keyP.check();

	public var UP_RP2(get, never):Bool;

	inline function get_UP_RP2()
		return _upP2.keyR.check();

	public var LEFT_RP2(get, never):Bool;

	inline function get_LEFT_RP2()
		return _leftP2.keyR.check();

	public var RIGHT_RP2(get, never):Bool;

	inline function get_RIGHT_RP2()
		return _rightP2.keyR.check();

	public var DOWN_RP2(get, never):Bool;

	inline function get_DOWN_RP2()
		return _downP2.keyR.check();

	public function new(name)
	{
		super(name);

		add(_up.key);
		add(_left.key);
		add(_right.key);
		add(_down.key);
		add(_up.keyP);
		add(_left.keyP);
		add(_right.keyP);
		add(_down.keyP);
		add(_up.keyR);
		add(_left.keyR);
		add(_right.keyR);
		add(_down.keyR);
		add(_accept.keyP);
		add(_back.key);
		add(_pause.key);
		add(_reset.key);
		add(_cheat.key);
		add(_attack.key);

		add(_upP2.key);
		add(_leftP2.key);
		add(_rightP2.key);
		add(_downP2.key);
		add(_upP2.keyP);
		add(_leftP2.keyP);
		add(_rightP2.keyP);
		add(_downP2.keyP);
		add(_upP2.keyR);
		add(_leftP2.keyR);
		add(_rightP2.keyR);
		add(_downP2.keyR);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyBinds();
	}

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(token.toUpperCase()));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up.key;
			case DOWN: _down.key;
			case LEFT: _left.key;
			case RIGHT: _right.key;
			case ACCEPT: _accept.keyP;
			case BACK: _back.key;
			case PAUSE: _pause.key;
			case RESET: _reset.key;
			case CHEAT: _cheat.key;
			case ATTACK: _attack.key;
			case UPP2: _upP2.key;
			case DOWNP2: _downP2.key;
			case LEFTP2: _leftP2.key;
			case RIGHTP2: _rightP2.key;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		try
		{
			var curKey = cast(Reflect.field(this, '_$control'), Key);
			if (curKey.key != null)
				func(curKey.key, PRESSED);
			if (curKey.keyP != null)
				func(curKey.keyP, JUST_PRESSED);
			if (curKey.keyR != null)
				func(curKey.keyR, JUST_RELEASED);
		}
		catch (e)
		{
			Debug.logWarn(e.details());
			return;
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyBinds()
	{
		loadKeyBinds();
		loadKeyBindsP2();
	}

	public function loadKeyBindsP2()
	{
		removeKeyboard();
		if (gamepadsAdded.length != 0)
			removeGamepad();
		EngineData.keyCheck();

		var buttons = new Map<Control, Array<FlxGamepadInputID>>();

		if (gamepad)
		{
			buttons.set(Control.UPP2, [FlxGamepadInputID.fromString(Main.save.data.upBindP2)]);
			buttons.set(Control.LEFTP2, [FlxGamepadInputID.fromString(Main.save.data.leftBindP2)]);
			buttons.set(Control.DOWNP2, [FlxGamepadInputID.fromString(Main.save.data.downBindP2)]);
			buttons.set(Control.RIGHTP2, [FlxGamepadInputID.fromString(Main.save.data.rightBindP2)]);

			addGamepad(0, buttons);
		}
		inline bindKeys(Control.UPP2, [FlxKey.fromString(Main.save.data.upBindP2), FlxKey.W]);
		inline bindKeys(Control.DOWNP2, [FlxKey.fromString(Main.save.data.downBindP2), FlxKey.S]);
		inline bindKeys(Control.LEFTP2, [FlxKey.fromString(Main.save.data.leftBindP2), FlxKey.A]);
		inline bindKeys(Control.RIGHTP2, [FlxKey.fromString(Main.save.data.rightBindP2), FlxKey.D]);
	}

	public function loadKeyBinds()
	{
		// trace(FlxKey.fromString(Main.save.data.upBind));

		removeKeyboard();
		if (gamepadsAdded.length != 0)
			removeGamepad();
		EngineData.keyCheck();

		var buttons = new Map<Control, Array<FlxGamepadInputID>>();

		if (gamepad)
		{
			buttons.set(Control.UP, [FlxGamepadInputID.fromString(Main.save.data.upBind)]);
			buttons.set(Control.LEFT, [FlxGamepadInputID.fromString(Main.save.data.leftBind)]);
			buttons.set(Control.DOWN, [FlxGamepadInputID.fromString(Main.save.data.downBind)]);
			buttons.set(Control.RIGHT, [FlxGamepadInputID.fromString(Main.save.data.rightBind)]);
			buttons.set(Control.ACCEPT, [FlxGamepadInputID.A]);
			buttons.set(Control.BACK, [FlxGamepadInputID.B]);
			buttons.set(Control.PAUSE, [FlxGamepadInputID.fromString(Main.save.data.pauseBind)]);

			addGamepad(0, buttons);
		}

		inline bindKeys(Control.UP, [FlxKey.fromString(Main.save.data.upBind), FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.fromString(Main.save.data.downBind), FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.fromString(Main.save.data.leftBind), FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.fromString(Main.save.data.rightBind), FlxKey.RIGHT]);
		inline bindKeys(Control.ACCEPT, [ENTER]);
		inline bindKeys(Control.BACK, [ESCAPE]);
		inline bindKeys(Control.PAUSE, [FlxKey.fromString(Main.save.data.pauseBind)]);
		inline bindKeys(Control.RESET, [FlxKey.fromString(Main.save.data.resetBind)]);
		inline bindKeys(Control.ATTACK, [FlxKey.fromString(Main.save.data.attackBind), FlxKey.SHIFT]);

		FlxG.sound.muteKeys = [FlxKey.fromString(Main.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(Main.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(Main.save.data.volUpBind)];
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		if (gamepadsAdded.contains(id))
			gamepadsAdded.remove(id);

		gamepadsAdded.push(id);
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Gamepad(id):
				removeGamepad(id);
			default:
				// do nothing
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}

class Key
{
	public var key:FlxActionDigital;

	public var keyP:FlxActionDigital;

	public var keyR:FlxActionDigital;

	public function new(key:String, ?keyP:String, ?keyR:String)
	{
		if (key != null)
			this.key = new FlxActionDigital(key);

		if (keyP != null)
			this.keyP = new FlxActionDigital(keyP);

		if (keyR != null)
			this.keyR = new FlxActionDigital(keyR);

		if (key == null && keyP == null && keyR == null)
			Debug.logWarn('No action was set!');
	}
}
