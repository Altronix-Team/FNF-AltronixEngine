package utils;

class HaxeRelative
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		if (!checkSuperclass(cls))
		{
			return fields;
		}

		//Context.info('${cls.name}: Implementing IRelative...', cls.pos);

		// Create properties which additionally run this code when the updatePosition function when set.
		var propertyBody = [macro this.updatePosition()];
		fields = fields.concat(MacroUtil.buildProperty("parent", macro:flixel.FlxObject, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeX", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeY", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeAngle", macro:Float, null, null, propertyBody, true));

		var updatePosBody = macro
			{
				if (this.parent != null)
				{
					// Set the absolute X and Y relative to the parent.
					this.x = this.parent.x + this.relativeX;
					this.y = this.parent.y + this.relativeY;
					this.angle = this.parent.angle + this.relativeAngle;
				}
				else
				{
					this.x = this.relativeX;
					this.y = this.relativeY;
				}
			};
		fields.push(MacroUtil.buildFunction("updatePosition", [updatePosBody], false, false));

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