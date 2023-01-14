package utils;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.ExprTools;

class AbstractTools
{
    public static macro function getPropertyFromAbstract(abstractName:String, variable:String):Dynamic
    {
		switch (Context.getType(abstractName))
        {
			case TAbstract(ref, params):
                var abstrRef:AbstractType = ref.get();
                var values:Map<String, Dynamic> = new Map();
				for (field in abstrRef.impl.get().statics.get())
                {
					var fieldName:String = field.name;
					var typedExpr:Null<TypedExpr> = field.expr();
                    var expr:Expr = Context.getTypedExpr(typedExpr);
					values.set(fieldName, macro $expr.$fieldName);
                }
                return ExprTools.getValue(values.get(variable));

            default:
                return null;
        }

        return null;
    }
}