package;

import flixel.input.gamepad.FlxGamepad;
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

#if (haxe >= "4.0.0")
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
#else
@:enum
abstract Action(String) to String from String
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
#end

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
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	UPP2;
	LEFTP2;
	RIGHTP2;
	DOWNP2;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
	ATTACK;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);
	var _attack = new FlxActionDigital(Action.ATTACK);

	var _upP2 = new FlxActionDigital(Action.UPP2);
	var _leftP2 = new FlxActionDigital(Action.LEFTP2);
	var _rightP2 = new FlxActionDigital(Action.RIGHTP2);
	var _downP2 = new FlxActionDigital(Action.DOWNP2);
	var _upPP2 = new FlxActionDigital(Action.UP_PP2);
	var _leftPP2 = new FlxActionDigital(Action.LEFT_PP2);
	var _rightPP2 = new FlxActionDigital(Action.RIGHT_PP2);
	var _downPP2 = new FlxActionDigital(Action.DOWN_PP2);
	var _upRP2 = new FlxActionDigital(Action.UP_RP2);
	var _leftRP2 = new FlxActionDigital(Action.LEFT_RP2);
	var _rightRP2 = new FlxActionDigital(Action.RIGHT_RP2);
	var _downRP2 = new FlxActionDigital(Action.DOWN_RP2);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	public var ATTACK(get, never):Bool;

	inline function get_ATTACK()
		return _attack.check();

	public var UPP2(get, never):Bool;

	inline function get_UPP2()
		return _upP2.check();

	public var LEFTP2(get, never):Bool;

	inline function get_LEFTP2()
		return _leftP2.check();

	public var RIGHTP2(get, never):Bool;

	inline function get_RIGHTP2()
		return _rightP2.check();

	public var DOWNP2(get, never):Bool;

	inline function get_DOWNP2()
		return _downP2.check();

	public var UP_PP2(get, never):Bool;

	inline function get_UP_PP2()
		return _upPP2.check();

	public var LEFT_PP2(get, never):Bool;

	inline function get_LEFT_PP2()
		return _leftPP2.check();

	public var RIGHT_PP2(get, never):Bool;

	inline function get_RIGHT_PP2()
		return _rightPP2.check();

	public var DOWN_PP2(get, never):Bool;

	inline function get_DOWN_PP2()
		return _downPP2.check();

	public var UP_RP2(get, never):Bool;

	inline function get_UP_RP2()
		return _upRP2.check();

	public var LEFT_RP2(get, never):Bool;

	inline function get_LEFT_RP2()
		return _leftRP2.check();

	public var RIGHT_RP2(get, never):Bool;

	inline function get_RIGHT_RP2()
		return _rightRP2.check();

	public var DOWN_RP2(get, never):Bool;

	inline function get_DOWN_RP2()
		return _downRP2.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);
		add(_attack);

		add(_upP2);
		add(_leftP2);
		add(_rightP2);
		add(_downP2);
		add(_upPP2);
		add(_leftPP2);
		add(_rightPP2);
		add(_downPP2);
		add(_upRP2);
		add(_leftRP2);
		add(_rightRP2);
		add(_downRP2);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);
		add(_attack);

		add(_upP2);
		add(_leftP2);
		add(_rightP2);
		add(_downP2);
		add(_upPP2);
		add(_leftPP2);
		add(_rightPP2);
		add(_downPP2);
		add(_upRP2);
		add(_leftRP2);
		add(_rightRP2);
		add(_downRP2);

		for (action in digitalActions)
			byName[action.name] = action;

		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

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
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
			case ATTACK: _attack;
			case UPP2: _upP2;
			case DOWNP2: _downP2;
			case LEFTP2: _leftP2;
			case RIGHTP2: _rightP2;
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
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
			case ATTACK:
				func(_attack, JUST_PRESSED);
			case UPP2:
				func(_upP2, PRESSED);
				func(_upPP2, JUST_PRESSED);
				func(_upRP2, JUST_RELEASED);
			case LEFTP2:
				func(_leftP2, PRESSED);
				func(_leftPP2, JUST_PRESSED);
				func(_leftRP2, JUST_RELEASED);
			case RIGHTP2:
				func(_rightP2, PRESSED);
				func(_rightPP2, JUST_PRESSED);
				func(_rightRP2, JUST_RELEASED);
			case DOWNP2:
				func(_downP2, PRESSED);
				func(_downPP2, JUST_PRESSED);
				func(_downRP2, JUST_RELEASED);
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

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
						gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
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

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		loadKeyBinds();
		loadKeyBindsP2();
	}

	public function loadKeyBindsP2()
	{
		// trace(FlxKey.fromString(FlxG.save.data.upBind));

		removeKeyboard();
		if (gamepadsAdded.length != 0)
			removeGamepad();
		KeyBinds.keyCheck();

		var buttons = new Map<Control, Array<FlxGamepadInputID>>();

		if (KeyBinds.gamepad)
		{
			buttons.set(Control.UPP2, [FlxGamepadInputID.fromString(FlxG.save.data.upBindP2)]);
			buttons.set(Control.LEFTP2, [FlxGamepadInputID.fromString(FlxG.save.data.leftBindP2)]);
			buttons.set(Control.DOWNP2, [FlxGamepadInputID.fromString(FlxG.save.data.downBindP2)]);
			buttons.set(Control.RIGHTP2, [FlxGamepadInputID.fromString(FlxG.save.data.rightBindP2)]);

			addGamepad(0, buttons);
		}

		inline bindKeys(Control.UPP2, [FlxKey.fromString(FlxG.save.data.upBindP2), FlxKey.W]);
		inline bindKeys(Control.DOWNP2, [FlxKey.fromString(FlxG.save.data.downBindP2), FlxKey.S]);
		inline bindKeys(Control.LEFTP2, [FlxKey.fromString(FlxG.save.data.leftBindP2), FlxKey.A]);
		inline bindKeys(Control.RIGHTP2, [FlxKey.fromString(FlxG.save.data.rightBindP2), FlxKey.D]);
	}

	public function loadKeyBinds()
	{
		// trace(FlxKey.fromString(FlxG.save.data.upBind));

		removeKeyboard();
		if (gamepadsAdded.length != 0)
			removeGamepad();
		KeyBinds.keyCheck();

		var buttons = new Map<Control, Array<FlxGamepadInputID>>();

		if (KeyBinds.gamepad)
		{
			buttons.set(Control.UP, [FlxGamepadInputID.fromString(FlxG.save.data.upBind)]);
			buttons.set(Control.LEFT, [FlxGamepadInputID.fromString(FlxG.save.data.leftBind)]);
			buttons.set(Control.DOWN, [FlxGamepadInputID.fromString(FlxG.save.data.downBind)]);
			buttons.set(Control.RIGHT, [FlxGamepadInputID.fromString(FlxG.save.data.rightBind)]);
			buttons.set(Control.ACCEPT, [FlxGamepadInputID.A]);
			buttons.set(Control.BACK, [FlxGamepadInputID.B]);
			buttons.set(Control.PAUSE, [FlxGamepadInputID.fromString(FlxG.save.data.pauseBind)]);

			addGamepad(0, buttons);
		}

		inline bindKeys(Control.UP, [FlxKey.fromString(FlxG.save.data.upBind), FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.fromString(FlxG.save.data.downBind), FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.fromString(FlxG.save.data.leftBind), FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.fromString(FlxG.save.data.rightBind), FlxKey.RIGHT]);
		inline bindKeys(Control.ACCEPT, [ENTER]);
		inline bindKeys(Control.BACK, [ESCAPE]);
		inline bindKeys(Control.PAUSE, [FlxKey.fromString(FlxG.save.data.pauseBind)]);
		inline bindKeys(Control.RESET, [FlxKey.fromString(FlxG.save.data.resetBind)]);
		inline bindKeys(Control.ATTACK, [FlxKey.fromString(FlxG.save.data.attackBind), FlxKey.SHIFT]);

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];
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

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
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
		#if !switch
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
		#else
		addGamepadLiteral(id, [
			// Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			// Swap Y and X for switch
			Control.RESET => [Y],
			Control.CHEAT => [X]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
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
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
