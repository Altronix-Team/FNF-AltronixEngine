package utils;

import Sys.sleep;
#if DISCORD_ALLOWED
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private static final _defaultID:String = "489437279799083028";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordRichPresence = DiscordRichPresence.create();

	public static function initialize()
	{
		#if DISCORD_ALLOWED
		var discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), 1, null);

		if(!isInitialized) Debug.logTrace("Discord Client initialized");

		sys.thread.Thread.create(() ->
		{
			var localID:String = clientID;
			while (localID == clientID)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();

				// Wait 0.5 seconds until the next loop...
				Sys.sleep(0.5);
			}
		});
		isInitialized = true;
		Application.current.window.onClose.add(function() {
			if(isInitialized) shutdown();
		});
		#end
	}

	public static function shutdown()
	{
		#if DISCORD_ALLOWED
		Discord.Shutdown();
		isInitialized = false;
		#end
	}

	static function onReady(request:cpp.RawConstPointer<DiscordUser>)
	{
		#if DISCORD_ALLOWED
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0) //New Discord IDs/Discriminator system
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)}#${cast(requestPtr.discriminator, String)})');
		else //Old discriminators
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)})');

		changePresence();
		#end
	}

	static function onError(errorCode:Int, message:cpp.ConstCharStar)
	{
		Debug.logError('Discord: Error ($errorCode: ${cast(message, String)})');
	}

	static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar)
	{
		Debug.logInfo('Discord: Disconnected ($errorCode: ${cast(message, String)})');
	}

	public static function changePresence(?details:String = 'In the Menus', ?state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		#if DISCORD_ALLOWED
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		presence.details = details;
		presence.state = state;
		presence.largeImageKey = 'icon';
		presence.largeImageText = "fridaynightfunkin";
		presence.smallImageKey = smallImageKey;
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		updatePresence();
		#end
	}

	public static function updatePresence()
	{
		#if DISCORD_ALLOWED 
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence)); 
		#end
	}
		

	public static function resetClientID()
		clientID = _defaultID;

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if(change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}
}
