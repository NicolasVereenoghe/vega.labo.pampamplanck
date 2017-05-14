package pixi.core;

import js.html.CanvasElement;

typedef RenderOptions = {
	@:optional var width:Float;
	@:optional var height:Float;
	@:optional var noWebGL:Bool;
	@:optional var sharedTicker:Bool;
	@:optional var view:CanvasElement;
	@:optional var resolution:Float;
	@:optional var antialias:Bool;
	@:optional var forceFXAA:Bool;
	@:optional var autoResize:Bool;
	@:optional var transparent:Bool;
	@:optional var backgroundColor:Int;
	@:optional var clearBeforeRender:Bool;
	@:optional var preserveDrawingBuffer:Bool;
	@:optional var roundPixels:Bool;
	@:optional var legacy:Bool;
}