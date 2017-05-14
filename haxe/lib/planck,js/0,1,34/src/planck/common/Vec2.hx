package planck.common;

import haxe.extern.EitherType;

@:native("planck.Vec2")
extern class Vec2 {
	var x						: Float;
	var y						: Float;
	
	function new( ?x : EitherType<Float,Vec2>, ?y : Float);
	
	static function zero() : Vec2;
	
	static function neo() : Vec2;
	
	static function clone( v : Vec2, ?depricated : Bool) : Vec2;
	
	function toString() : String;
	
	static function isValid( v : Vec2) : Bool;
	
	static function assert( o : Vec2) : Void;
	
	function clone( ?depricated : Bool) : Vec2;
	
	function setZero() : Vec2;
	
	function set( x : EitherType<Float,Vec2>, ?y : Float) : Vec2;
	
	function wSet( a : Float, v : Vec2, ?b : Float, ?w : Vec2) : Vec2;
	
	function add( w : Vec2) : Vec2;
	
	function wAdd( a : Float, v : Vec2, ?b : Float, ?w : Vec2) : Vec2;
	
	function wSub( a : Float, v : Vec2, ?b : Float, ?w : Vec2) : Vec2;
	
	function sub( w : Vec2) : Vec2;
	
	function mul( m : Float) : Vec2;
	
	function length() : Float;
	
	function lengthSquared() : Float;
	
	function normalize() : Float;
	
	static function lengthOf( v : Vec2) : Float;
	
	static function lengthSquared( v : Vec2) : Float;
	
	static function distance( v : Vec2, w : Vec2) : Float;
	
	static function distanceSquared( v : Vec2, w : Vec2) : Float;
	
	static function areEqual( v : Vec2, w : Vec2) : Bool;
	
	static function skew( v : Vec2) : Vec2;
	
	static function dot( v : Vec2, w : Vec2) : Float;
	
	static function cross( v : EitherType<Float,Vec2>, w : EitherType<Float,Vec2>) : EitherType<Float,Vec2>;
	
	static function addCross( a : EitherType<Float,Vec2>, v : EitherType<Float,Vec2>, w : Vec2) : Vec2;
	
	static function add( v : Vec2, w : Vec2) : Vec2;
	
	static function wAdd( a : Float, v : Vec2, ?b : Float, ?w : Vec2) : Vec2;
	
	static function sub( v : Vec2, w : Vec2) : Vec2;
	
	static function mul( a : EitherType<Float,Vec2>, b : EitherType<Float,Vec2>) : Vec2;
	
	function neg() : Vec2;
	
	static function neg( v : Vec2) : Vec2;
	
	static function abs( v : Vec2) : Vec2;
	
	static function mid( v : Vec2, w : Vec2) : Vec2;
	
	static function upper( v : Vec2, w : Vec2) : Vec2;
	
	static function lower( v : Vec2, w : Vec2) : Vec2;
	
	function clamp( max : Float) : Vec2;
	
	static function clamp( v : Vec2, max : Float) : Vec2;
}