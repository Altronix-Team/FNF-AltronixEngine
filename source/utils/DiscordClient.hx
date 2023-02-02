package utils;

import Sys.sleep;
#if desktop
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	public static var isInitialized:Bool = false;
	public function new()
	{
		#if desktop
		Debug.logInfo("Discord Client starting...");
		DiscordRpc.start({
			clientID: "489437279799083028", // change this to what ever the fuck you want lol
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		Debug.logInfo("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if desktop
		DiscordRpc.shutdown();
		#end
	}

	static function onReady()
	{
		#if desktop
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		Debug.logError('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		Debug.logInfo('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if desktop
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		Debug.logInfo("Discord Client initialized");
		isInitialized = true;
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		#if desktop
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
		#end
	}
}