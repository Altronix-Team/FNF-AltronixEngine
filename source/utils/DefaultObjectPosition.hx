package utils;

class DefaultObjectPosition
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		if (!checkSuperclass(cls))
		{
			return fields;
		}

		Context.info('${cls.name}: Implementing IDefObjPos...', cls.pos);

		// Create properties which additionally run this code when the updatePosition function when set.
		var xPropertyBody = [macro this.getDefaultXPosition()];
		var yPropertyBody = [macro this.getDefaultYPosition()];
		fields = fields.concat(MacroUtil.buildProperty("defaultX", macro:Float, null, xPropertyBody, null, true));
		fields = fields.concat(MacroUtil.buildProperty("defaultY", macro:Float, null, yPropertyBody, null, true));
		var getDefaultXPosition = macro
		{
			return defaultX;
		};
		var getDefaultYPosition = macro
		{
			return defaultY;
		};
		fields.push(MacroUtil.buildFunction("getDefaultXPosition", [getDefaultXPosition], false, false));
		fields.push(MacroUtil.buildFunction("getDefaultYPosition", [getDefaultYPosition], false, false));

		return fields;
	}

	static function checkSuperclass(cls:haxe.macro.Type.ClassType)
	{
		// Superclasses need to be checked recursively.
		if (cls.superClass != null)
		{
			var superCls = cls.superClass.t.get();
			for (field in superCls.fields.get())
			{
				// Parent already added, return false.
				if (field.name == 'parent')
					return false;
			}
			// Else, we need to check for the superclass's superclass.
			return checkSuperclass(superCls);
		}
		else
		{
			// No superclass, parent needs to be added. Return true;
			return true;
		}
	}
}