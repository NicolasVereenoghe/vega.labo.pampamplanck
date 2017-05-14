package planck.common;

@:native("planck.internal.Sweep")
extern class Sweep {
	var localCenter		: Vec2;
	var c0				: Vec2;
	var c				: Vec2;
	
	var a0				: Float;
	var a				: Float;
	var alpha0			: Float;
	
	function new( c : Vec2, a : Float);
	
	function setTransform( xf : Transform) : Void;
	
	function setLocalCenter( localCenter : Vec2, xf : Transform) : Void;
	
	function getTransform( xf : Transform, ?beta : Float) : Transform;
	
	function advance( alpha : Float) : Void;
	
	function forward() : Void;
	
	function normalize() : Void;
	
	function clone() : Sweep;
	
	function set( that : Sweep) : Void;
}