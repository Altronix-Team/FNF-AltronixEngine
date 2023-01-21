package utils;

//WIP
class ConvertUtil {
    public static function toString(value:Dynamic) {
        return Std.string(value);
    }

    public static function toInt(value:Dynamic){
        return Std.parseInt(value.toString());
    }

	public static function toFloat(value:Dynamic){
		return Std.parseFloat(value.toString());
	}
}