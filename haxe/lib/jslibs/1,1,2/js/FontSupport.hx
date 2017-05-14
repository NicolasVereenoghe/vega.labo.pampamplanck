package js;

/**
 * See https://github.com/drdk/dr-font-support.
 */
extern class FontSupport
{
	static function __init__() : Void
	{
		haxe.macro.Compiler.includeFile("js/FontSupport.js");
	}
	
	static inline function isFormatSupported(format:String, callb:Bool->Void) : Void (cast js.Browser.window).fontSupport(callb, format);
	static inline function getSupportedFormat(formats:Array<String>, callb:String->Void) : Void (cast js.Browser.window).fontSupport(callb, formats);
	static inline function getSupportedFormats(callb:{ woff2:Bool, woff:Bool, ttf:Bool, svg:Bool }->Void) : Void (cast js.Browser.window).fontSupport(callb);
}