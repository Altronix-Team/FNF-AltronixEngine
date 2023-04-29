package macros;

import haxe.Http;
import haxe.Json;

class GetFunkinVersion {
	@:access(macros.MacroUtil)
	public static macro function getFunkinVersion():ExprOf<String>
	{
		try
		{
			var http = new Http('https://api.github.com/repos/FunkinCrew/Funkin/releases');
			http.setHeader("User-Agent", "request");
			var r = null;
			http.onData = function(d)
			{
				r = d;
			}
			http.onError = function(e)
			{
				throw e;
			}
			http.request(false);

			var lastRelease = Json.parse(r)[0];

			var relName:String = Reflect.getProperty(lastRelease, 'name');

			return macro ${MacroUtil.toExpr(relName.removeAfter(' '))};
		}
		catch (e)
		{
			trace(e.details());
			return macro ${MacroUtil.toExpr('0.2.7.1')};
		}	
	}
}
