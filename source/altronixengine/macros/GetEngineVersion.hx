package altronixengine.macros;

import haxe.Http;
import haxe.Json;
import haxe.crypto.Base64;

class GetEngineVersion
{
	@:access(altronixengine.macros.MacroUtil)
	public static macro function getEngineVersion():ExprOf<String>
	{
		try
		{
			var http = new Http('https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/contents/version.downloadMe');
			http.setHeader("User-Agent", "request");
			var responce:GitHubFileData = null;
			http.onData = function(d)
			{
				responce = cast Json.parse(d);
			}
			http.onError = function(e)
			{
				throw e;
			}
			http.request(false);

			var content = Base64.decode(responce.content.removeAll('\n')).toString();

			var lines = content.split('\n');
			return macro ${MacroUtil.toExpr(lines[0])};
		}
		catch (e)
		{
			trace(e.details());
			return macro ${MacroUtil.toExpr('0.5')};
		}
	}
}

typedef GitHubFileData =
{
	var name:String;
	var path:String;
	var sha:String;
	var size:Int;
	var url:String;
	var html_url:String;
	var git_url:String;
	var download_url:String;
	var type:String;
	var content:String;
	var encoding:String;
	var _links:Links;
}

typedef Links =
{
	var self:String;
	var git:String;
	var html:String;
}
