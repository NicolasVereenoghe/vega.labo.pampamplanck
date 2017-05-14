package planck.common;

import haxe.extern.EitherType;

@:native("planck.Rot")
extern class Rot {
	var c					: Float;
	var s					: Float;
	
	function new( angle : Float);
	
	static function neo( angle : Float) : Rot;
	
	static function clone( rot : Rot) : Rot;
	
	static function identity( rot : Rot) : Rot;
	
	static function isValid( o : Rot) : Bool;
	
	static function assert( o : Rot) : Void;
	
	function setIdentity() : Void;
	
	function set( angle : EitherType<Rot,Float>) : Void;
	
	function setAngle( angle : Float) : Void;
	
	function getAngle() : Float;
	
	function getXAxis() : Vec2;
	
	function getYAxis() : Vec2;
	
	static function mul( rot : Rot, m : EitherType<Rot,Vec2>) : EitherType<Rot,Vec2>;
	
	static function mulSub( rot : Rot, v : Vec2, w : Vec2) : Vec2;
	
	static function mulT( rot : Rot, m : EitherType<Rot,Vec2>) : EitherType<Rot,Vec2>;
}