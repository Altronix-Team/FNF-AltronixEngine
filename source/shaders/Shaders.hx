package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class BuildingShaders
{
	public var shader(default, null):BuildingShader;
	public var daAlpha:Float = 1;

	public function new():Void
	{
		shader = new BuildingShader();
		shader.alphaShit.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.alphaShit.value[0] += elapsed;
	}

	public function reset()
	{
		shader.alphaShit.value[0] = 0;
	}
}

class BuildingShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float alphaShit;

        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            if (color.a > 0.0)
                color -= alphaShit;
            
            gl_FragColor = color;
        }

    ')
	public function new()
	{
		super();
	}
}

typedef ShaderEffect =
{
	var shader:Dynamic;
}

class VCRDistortionEffect
{
	public var shader:VCRDistortionShader = new VCRDistortionShader();

	public function new()
	{
		shader.iTime.value = [0];
		shader.vignetteOn.value = [true];
		shader.perspectiveOn.value = [true];
		shader.distortionOn.value = [true];
		shader.scanlinesOn.value = [true];
		shader.vignetteMoving.value = [true];
		shader.noiseOn.value = [true];
		shader.glitchModifier.value = [1];
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
		var noise = Assets.getBitmapData(Paths.image("noise2"));
		shader.noiseTex.input = noise;
	}

	public function update(elapsed:Float)
	{
		shader.iTime.value[0] += elapsed;
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
	}

	public function setVignette(state:Bool)
	{
		shader.vignetteOn.value[0] = state;
	}

	public function setNoise(state:Bool)
	{
		shader.noiseOn.value[0] = state;
	}

	public function setPerspective(state:Bool)
	{
		shader.perspectiveOn.value[0] = state;
	}

	public function setGlitchModifier(modifier:Float)
	{
		shader.glitchModifier.value[0] = modifier;
	}

	public function setDistortion(state:Bool)
	{
		shader.distortionOn.value[0] = state;
	}

	public function setScanlines(state:Bool)
	{
		shader.scanlinesOn.value[0] = state;
	}

	public function setVignetteMoving(state:Bool)
	{
		shader.vignetteMoving.value[0] = state;
	}
}

class VCRDistortionShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{
	@:glFragmentSource('
    #pragma header

    uniform float iTime;
    uniform bool vignetteOn;
    uniform bool perspectiveOn;
    uniform bool distortionOn;
    uniform bool scanlinesOn;
    uniform bool vignetteMoving;
    uniform sampler2D noiseTex;
    uniform float glitchModifier;
    uniform vec3 iResolution;
    uniform bool noiseOn;

    float onOff(float a, float b, float c)
    {
    	return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
    	float inside = step(start,y) - step(end,y);
    	float fact = (y-start)/(end-start)*inside;
    	return (1.-fact) * inside;

    }

    vec4 getVideo(vec2 uv)
      {
      	vec2 look = uv;
        if(distortionOn){
        	float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
        	look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(glitchModifier*2);
        	float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
        										 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
        	look.y = mod(look.y + vShift*glitchModifier, 1.);
        }
      	vec4 video = flixel_texture2D(bitmap,look);

      	return video;
      }

    vec2 screenDistort(vec2 uv)
    {
      if(perspectiveOn){
        uv = (uv - 0.5) * 2.0;
      	uv *= 1.1;
      	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
      	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
      	uv  = (uv / 2.0) + 0.5;
      	uv =  uv *0.92 + 0.04;
      	return uv;
      }
    	return uv;
    }
    float random(vec2 uv)
    {
     	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }
    float noise(vec2 uv)
    {
     	vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
    	float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
    	float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
    	float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
    	float amount = scan1 * scan2 * uv.x;

    	uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

    	return uv;

    }
    void main()
    {
    	vec2 uv = openfl_TextureCoordv;
      vec2 curUV = screenDistort(uv);
    	uv = scandistort(curUV);
    	vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)).x+0.05;
      video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);
      if(vignetteMoving)
    	  vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

    	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

      if(vignetteOn)
    	 video *= vignette;

      if(curUV.x<0 || curUV.x>1 || curUV.y<0 || curUV.y>1){
        gl_FragColor = vec4(0,0,0,0);
      }else{
        if(noiseOn){
          gl_FragColor = mix(video,vec4(noise(uv * 75.)),.05);
        }else{
          gl_FragColor = video;
        }

      }



    }
  ')
	public function new()
	{
		super();
	}
}
class ColorSwap
{
	public var shader(default, null):ColorSwapShader = new ColorSwapShader();
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;

	private function set_hue(value:Float)
	{
		hue = value;
		shader.uTime.value[0] = hue;
		return hue;
	}

	private function set_saturation(value:Float)
	{
		saturation = value;
		shader.uTime.value[1] = saturation;
		return saturation;
	}

	private function set_brightness(value:Float)
	{
		brightness = value;
		shader.uTime.value[2] = brightness;
		return brightness;
	}

	public function new()
	{
		shader.uTime.value = [0, 0, 0];
		shader.awesomeOutline.value = [false];
	}
}

class ColorSwapShader extends FlxShader
{
	@:glFragmentSource('
		varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;

		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;
		uniform sampler2D bitmap;

		uniform bool hasTransform;
		uniform bool hasColorTransform;

		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!hasTransform)
			{
				return color;
			}

			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}

			color = vec4(color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}

		uniform vec3 uTime;
		uniform bool awesomeOutline;

		const float offset = 1.0 / 128.0;
		vec3 normalizeColor(vec3 color)
		{
			return vec3(
				color[0] / 255.0,
				color[1] / 255.0,
				color[2] / 255.0
			);
		}

		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

			vec4 swagColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

			// [0] is the hue???
			swagColor[0] = swagColor[0] + uTime[0];
			swagColor[1] = swagColor[1] + uTime[1];
			swagColor[2] = swagColor[2] * (1.0 + uTime[2]);
			
			if(swagColor[1] < 0.0)
			{
				swagColor[1] = 0.0;
			}
			else if(swagColor[1] > 1.0)
			{
				swagColor[1] = 1.0;
			}

			color = vec4(hsv2rgb(vec3(swagColor[0], swagColor[1], swagColor[2])), swagColor[3]);

			if (awesomeOutline)
			{
				 // Outline bullshit?
				vec2 size = vec2(3, 3);

				if (color.a <= 0.5) {
					float w = size.x / openfl_TextureSize.x;
					float h = size.y / openfl_TextureSize.y;
					
					if (flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0.
					|| flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0.
					|| flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0.
					|| flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.)
						color = vec4(1.0, 1.0, 1.0, 1.0);
				}
			}
			gl_FragColor = color;

			/* 
			if (color.a > 0.5)
				gl_FragColor = color;
			else
			{
				float a = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv + offset, openfl_TextureCoordv.y)).a +
						  flixel_texture2D(bitmap, vec2(openfl_TextureCoordv, openfl_TextureCoordv.y - offset)).a +
						  flixel_texture2D(bitmap, vec2(openfl_TextureCoordv - offset, openfl_TextureCoordv.y)).a +
						  flixel_texture2D(bitmap, vec2(openfl_TextureCoordv, openfl_TextureCoordv.y + offset)).a;
				if (color.a < 1.0 && a > 0.0)
					gl_FragColor = vec4(0.0, 0.0, 0.0, 0.8);
				else
					gl_FragColor = color;
			} */
		}')
	@:glVertexSource('
		attribute float openfl_Alpha;
		attribute vec4 openfl_ColorMultiplier;
		attribute vec4 openfl_ColorOffset;
		attribute vec4 openfl_Position;
		attribute vec2 openfl_TextureCoord;

		varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;

		uniform mat4 openfl_Matrix;
		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;

		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
		
		void main(void)
		{
			openfl_Alphav = openfl_Alpha;
			openfl_TextureCoordv = openfl_TextureCoord;

			if (openfl_HasColorTransform) {
				openfl_ColorMultiplierv = openfl_ColorMultiplier;
				openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
			}

			gl_Position = openfl_Matrix * openfl_Position;

			openfl_Alphav = openfl_Alpha * alpha;
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}')
	public function new()
	{
		super();
	}
}

class ColorMask
{
	public var shader(default, null):ColorMaskShader = new ColorMaskShader();
	public var rCol(default, set):FlxColor = FlxColor.WHITE;
	public var gCol(default, set):FlxColor = FlxColor.WHITE;
	public var bCol(default, set):FlxColor = FlxColor.WHITE;

	private function set_rCol(value:FlxColor)
	{
		rCol = value;
		shader.rCol.value = [rCol.red, rCol.green, rCol.blue];
		return rCol;
	}

	private function set_gCol(value:FlxColor)
	{
		gCol = value;
		shader.gCol.value = [gCol.red, gCol.green, gCol.blue];
		return gCol;
	}

	private function set_bCol(value:FlxColor)
	{
		bCol = value;
		shader.bCol.value = [bCol.red, bCol.green, bCol.blue];
		return bCol;
	}

	public function new()
	{
		shader.rCol.value = [rCol.red, rCol.green, rCol.blue];
		shader.gCol.value = [gCol.red, gCol.green, gCol.blue];
		shader.bCol.value = [bCol.red, bCol.green, bCol.blue];
	}
}

class ColorMaskShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	uniform vec3 rCol;
	uniform vec3 gCol;
	uniform vec3 bCol;

	vec3 rgb(vec3 col)
	{
		return col / vec3(255.0);
	}

	void main()
	{
		vec4 texture = flixel_texture2D(bitmap, openfl_TextureCoordv.xy) / openfl_Alphav;
		float alpha = texture.a * openfl_Alphav;

		vec3 rCol = rgb(rCol);
		vec3 gCol = rgb(gCol);
		vec3 bCol = rgb(bCol);

		vec3 red = mix(vec3(0.0), rCol, texture.r);
		vec3 green = mix(vec3(0.0), gCol, texture.g);
		vec3 blue = mix(vec3(0.0), bCol, texture.b);
		vec3 color = red + green + blue;

		gl_FragColor = vec4(color * openfl_Alphav, alpha);
	}
	')
	public function new()
	{
		super();
	}
}