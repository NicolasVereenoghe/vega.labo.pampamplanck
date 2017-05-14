package js;

@:native("fullScreenApi") extern class FullScreenApi
{
	static function __init__() : Void
	{
		haxe.macro.Compiler.includeFile("js/FullScreenApi.js");
	}
	
	public static var supportsFullScreen(default, null) : Bool;
	public static var fullScreenEventName(default, null) : String;
	
	public static function isFullScreen() : Bool;
	public static function requestFullScreen(el:js.html.Element) : Bool;
	public static function cancelFullScreen() : Void;
}