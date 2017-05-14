package js;

typedef RgbQuantOptions =
{
	/**
	 * Desired palette size (256).
	 */
    @:optional var colors : Int;
    
	/**
	 * Histogram method, 2: min-population threshold within subregions; 1: global top-population (2).
	 */
    @:optional var method : Int;
    
	/**
	 * Subregion dims if method = 2 ([64, 64]).
	 */
    @:optional var boxSize : Array<Int>;
    
	/**
	 * Min-population threshold if method = 2 (2);
	 */
    @:optional var boxPxls : Int;
    
	/**
	 * Count of top-occurring colors  to start with if method = 1 (4096).
	 */
    @:optional var initColors : Int;
    
	/**
	 * Count of colors per hue group to evaluate regardless of counts, to retain low-count hues (0).
	 */
    @:optional var minHueCols : Int;
    
	/**
	 * Dithering kernel name: 
     * FloydSteinberg
     * FalseFloydSteinberg
     * Stucki
     * Atkinson
     * Jarvis
     * Burkes
     * Sierra
     * TwoSierra
     * SierraLite
	 */
    @:optional var dithKern : String;
    
	/**
	 * Dithering threshhold (0-1) e.g: 0.05 will not dither colors with <= 5% difference (0).
	 */
    @:optional var dithDelta : Float;
    
	/**
	 * Enable serpentine pattern dithering (false).
	 */
    @:optional var dithSerp : Bool;
    
	/**
	 * A predefined palette to start with in r,g,b tuple format: [[r,g,b],[r,g,b]...].
	 */
    @:optional var palette : Array<Array<Int>>;
    
	/**
	 * Affects predefined palettes only.
	 * If true, allows compacting of sparsed palette once target palette size is reached. 
	 * Also enables palette sorting. (false)
	 */
    @:optional var reIndex : Bool;
    
	/**
	 * Enables caching for perf usually, but can reduce perf in some cases, like pre-def palettes (true).
	 */
    @:optional var useCache : Bool;
    
	/**
	 * Min color occurance count needed to qualify for caching (10).
	 */
    @:optional var cacheFreq : Int;
    
    /**
     * Method used to determine color distance, can be "euclidean" or "manhattan".
     */
	@:optional var colorDist : String;
}

/**
 * https://github.com/leeoniya/RgbQuant.js - sources
 * http://o-0.me/RgbQuant/ - playground
 */
@:native("RgbQuant") extern class RgbQuant
{
	private static function __init__() : Void
	{
		haxe.macro.Compiler.includeFile("js/RgbQuant.js");
	}

	function new(opts:RgbQuantOptions) : Void;
	
	/**
	 * Performs histogram analysis.
	 * @param	image May be any of <img>, <canvas>, Context2D, ImageData, Typed Array, Array.
	 * @param	width Is required if image is an array.
	 */
	function sample(image:Dynamic, ?width:Int) : Void;
	
	/**
	 * Retrieves the palette, building it on first call.
	 * @param	tuples if true will return an array of [r,g,b] triplets, otherwise a Uint8Array is returned by default.
	 * @param	noSort if true will disable palette sorting by hue/luminance and leaves it ordered from highest to lowest color occurrence counts.
	 */
	function palette(?tuples:Bool, ?noSort:Bool) : Dynamic;
	
	/**
	 * Quantizes an image.
	 * @param	image May be any of <img>, <canvas>, Context2D, ImageData, Typed Array, Array.
	 * @param	retType Determines returned type. 1 - Uint8Array (default), 2 - Indexed array.
	 * @param	dithKern Is a dithering kernel that can override what was specified in global opts.
	 * @param	dithSerp Can be true or false and determines if dithering is done in a serpentine pattern.
	 */
	function reduce(image:Dynamic, retType:Int, ?dithKern:String, ?dithSerp:Bool) : Dynamic;
	
	inline function paletteAsTypedArray(?noSort:Bool) : js.html.Uint8Array return palette(false, noSort);
	inline function paletteAsTuples(?noSort:Bool) : Array<Array<Int>> return palette(true, noSort);
	
	inline function reduceAsTypedArray(image:Dynamic, ?dithKern:String, ?dithSerp:Bool) : js.html.Uint8Array return reduce(image, 1, dithKern, dithSerp);
	inline function reduceAsArray(image:Dynamic, ?dithKern:String, ?dithSerp:Bool) : Array<Int> return reduce(image, 2, dithKern, dithSerp);
}
