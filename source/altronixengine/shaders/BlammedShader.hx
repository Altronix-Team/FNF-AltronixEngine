package altronixengine.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class BlammedEffect
{
	public var shader(default, null):BlammedShader;
	public var rCol(default, set):FlxColor = FlxColor.WHITE;
	public var gCol(default, set):FlxColor = FlxColor.WHITE;
	public var bCol(default, set):FlxColor = FlxColor.WHITE;

	private function set_rCol(value:FlxColor)
	{
		rCol = value;
		shader.r.value = rCol.red;
		return rCol;
	}

	private function set_gCol(value:FlxColor)
	{
		gCol = value;
		shader.g.value = gCol.green;
		return gCol;
	}

	private function set_bCol(value:FlxColor)
	{
		bCol = value;
		shader.b.value = bCol.blue;
		return bCol;
	}

	public function new()
	{
		shader.r.value = rCol.red;
		shader.g.value = gCol.green;
		shader.b.value = bCol.blue;
	}
}

class BlammedShader extends FlxShader
{
	@:glFragmentSource('
        
        #pragma header

        uniform float r;
        uniform float g;
        uniform float b;
        uniform bool enabled;

        void main() {
            if (enabled) {
                vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
                float alpha = color.a;
                if (alpha == 0) {
                    gl_FragColor = vec4(0, 0, 0, alpha);
                } else {
                    float average = ((color.r + color.g + color.b) / 3) * 255;
                    float finalColor = (50 - average) / 50;
                    if (finalColor < 0) finalColor = 0;
                    if (finalColor > 1) finalColor = 1;
                    
                    gl_FragColor = vec4(finalColor * r * alpha, finalColor * g * alpha, finalColor * b * alpha, alpha);
                }
                
            } else {
                gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            }
        }
    ')
	public function new(r:Int, g:Int, b:Int)
	{
		super();
		setColors(r, g, b);
		this.enabled.value = [true];
	}

	public function setColors(r:Int, g:Int, b:Int)
	{
		this.r.value = [r / 255];
		this.g.value = [g / 255];
		this.b.value = [b / 255];
	}
}
