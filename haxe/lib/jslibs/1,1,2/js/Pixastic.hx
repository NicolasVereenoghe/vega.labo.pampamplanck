package js;

private typedef Rect =
{
	var left : Int;
	var right : Int;
	var width : Int;
	var height : Int;
}

@:native("Pixastic") extern class Pixastic
{
	static function process(image:Dynamic, action:String, options:Dynamic, ?callb:Dynamic->Void) : Dynamic;
	
	/**
	 * mode: normal, multiply, lighten, darken, darkercolor, lightercolor, lineardodge, linearburn, difference, screen, exclusion, overlay, softlight, hardlight, colordodge, colorburn, linearlight, vividlight, pinlight, hardmix
	 */
	static inline function blend(image:Dynamic, amount:Float, mode:String, ?rect:Rect) : Dynamic
	{
		return process(image, "blend",
		{
			amount:amount,
			mode:mode,
			rect:rect 
		});
	}
	
	static inline function blur(image:Dynamic, ?fixMargin:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "blur",
		{
			fixMargin:fixMargin,
			rect:rect 
		});
	}
	
	static inline function blurfast(image:Dynamic, ?clear:Bool, ?fixMargin:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "blurfast",
		{
			clear:clear,
			fixMargin:fixMargin,
			rect:rect 
		});
	}
	
	/**
	 * @param	brightness -150..150
	 * @param	contrast -1..1
	 */
	static inline function brightness(image:Dynamic, brightness:Int, contrast:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "brightness",
		{
			brightness:brightness,
			contrast:contrast,
			rect:rect 
		});
	}
	
	static inline function coloradjust(image:Dynamic, red:Float, green:Float, blue:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "coloradjust",
		{
			red:red,
			green:green,
			blue:blue,
			rect:rect 
		});
	}
	
	static inline function colorhistogram(image:Dynamic, ?paint:Bool, ?rect:Rect) : { rvals:Array<Float>, gvals:Array<Float>, bvals:Array<Float> }
	{
		return process(image, "colorhistogram",
		{
			paint:paint,
			rect:rect 
		});
	}
	
	static inline function crop(image:Dynamic, rect:Rect) : Dynamic
	{
		return process(image, "crop",
		{
			rect:rect 
		});
	}
	
	static inline function desaturate(image:Dynamic, ?average:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "desaturate",
		{
			average:average,
			rect:rect 
		});
	}
	
	static inline function edges(image:Dynamic, ?mono:Bool, ?invert:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "edges",
		{
			mono:mono,
			invert:invert,
			rect:rect 
		});
	}
	
	static inline function edges2(image:Dynamic, ?rect:Rect) : Dynamic
	{
		return process(image, "edges2",
		{
			rect:rect 
		});
	}
	
	static inline function emboss(image:Dynamic, ?strength:Float, ?greyLevel:Int, ?direction:String, ?blend:Bool, ?invertAlpha:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "emboss",
		{
			rect:rect 
		});
	}
	
	static inline function flipHorizontal(image:Dynamic, ?rect:Rect) : Dynamic
	{
		return process(image, "flip",
		{
			axis:"horizontal"
			rect:rect 
		});
	}
	
	static inline function flipVertical(image:Dynamic, ?rect:Rect) : Dynamic
	{
		return process(image, "flip",
		{
			axis:"vertical"
			rect:rect 
		});
	}
	
	static inline function glow(image:Dynamic, amount:Float, radius:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "glow",
		{
			amount:amount,
			radius:radius,
			rect:rect 
		});
	}
	
	static inline function histogram(image:Dynamic, ?average:Bool, ?paint:Bool, ?rect:Rect) : Array<Float>
	{
		return process(image, "histogram",
		{
			average:average,
			paint:paint,
			rect:rect 
		});
	}
	
	static inline function histogram(image:Dynamic, ?average:Bool, ?paint:Bool, ?color:String, ?rect:Rect) : Array<Float>
	{
		return process(image, "histogram",
		{
			average:average,
			paint:paint,
			color:color,
			rect:rect 
		});
	}
	
	/**
	 * @param	hue Angle in degrees (0..360)
	 * @param	saturation 0..100
	 * @param	lightness 0..100
	 */
	static inline function hsl(image:Dynamic, ?hue:Int, ?saturation:Int, ?lightness:Int, ?rect:Rect) : Dynamic
	{
		return process(image, "hsl",
		{
			hue:hue,
			saturation:saturation,
			lightness:lightness,
			rect:rect 
		});
	}
	
	static inline function invert(image:Dynamic, ?invertAlpha:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "invert",
		{
			invertAlpha:invertAlpha,
			rect:rect 
		});
	}
	
	static inline function laplace(image:Dynamic, ?invert:Bool, ?edgeStrength:Float, ?greyLevel:Int, ?rect:Rect) : Dynamic
	{
		return process(image, "laplace",
		{
			invert:invert,
			edgeStrength:edgeStrength,
			greyLevel:greyLevel,
			rect:rect 
		});
	}
	
	static inline function lighten(image:Dynamic, amount:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "lighten",
		{
			amount:amount,
			rect:rect 
		});
	}
	
	static inline function mosaic(image:Dynamic, blockSize:Int, ?rect:Rect) : Dynamic
	{
		return process(image, "mosaic",
		{
			blockSize:blockSize,
			rect:rect 
		});
	}
	
	static inline function noise(image:Dynamic, amount:Float, strength:Float, ?mono:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "noise",
		{
			amount:amount,
			strength:strength,
			mono:mono,
			rect:rect 
		});
	}
	
	static inline function posterize(image:Dynamic, levels:Int, ?rect:Rect) : Dynamic
	{
		return process(image, "posterize",
		{
			levels:levels,
			rect:rect 
		});
	}
	
	static inline function pointillize(image:Dynamic, radius:Int, density:Float, noise:Float, ?transparent:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "pointillize",
		{
			radius:radius,
			density:density,
			noise:noise,
			transparent:transparent,
			rect:rect 
		});
	}
	
	static inline function removenoise(image:Dynamic, ?rect:Rect) : Dynamic
	{
		return process(image, "removenoise",
		{
			rect:rect 
		});
	}
	
	static inline function resize(image:Dynamic, width:Int, height:Int) : Dynamic
	{
		return process(image, "resize",
		{
			width:width, 
			height:height, 
			rect:rect 
		});
	}
	
	static inline function rotate(image:Dynamic, angleDeg:Float) : Dynamic
	{
		return process(image, "rotate",
		{
			angle:angleDeg
		});
	}
	
	/**
	 * @param	mode 0 or 1
	 */
	static inline function sepia(image:Dynamic, mode:Int, ?rect:Rect) : Dynamic
	{
		return process(image, "sepia",
		{
			mode:mode, 
			rect:rect 
		});
	}
	
	static inline function sharpen(image:Dynamic, amount:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "sharpen",
		{
			amount:amount, 
			rect:rect 
		});
	}
	
	static inline function solarize(image:Dynamic, ?average:Bool, ?rect:Rect) : Dynamic
	{
		return process(image, "solarize",
		{
			average:average, 
			rect:rect 
		});
	}
	
	static inline function unsharpmask(image:Dynamic, amount:Float, radius:Float, threshold:Float, ?rect:Rect) : Dynamic
	{
		return process(image, "unsharpmask",
		{
			amount:amount, 
			radius:radius, 
			threshold:threshold, 
			rect:rect 
		});
	}
}