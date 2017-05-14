package planck.common;

@:native("planck.Math")
extern class Math {
	static var EPSILON				: Float;
	
	static function isFinite( x : Float) : Bool;
	
	static function assert( x : Float) : Void;
	
	static function invSqrt( x : Float) : Float;
	
	static function nextPowerOfTwo( x : Int) : Int;
	
	static function isPowerOfTwo( x : Int) : Bool;
	
	static function mod( num : Float, ?min : Float, ?max : Float) : Float;
	
	static function clamp( num : Float, min : Float, max : Float) : Float;
	
	static function random( ?min : Float, ?max : Float) : Float;
}