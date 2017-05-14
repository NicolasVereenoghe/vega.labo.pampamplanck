package planck.common;

import haxe.extern.EitherType;

@:native("planck.Transform")
extern class Transform {
	var p					: Vec2;
	var q					: Rot;
	
	function new( ?position : Vec2, ?rotation : Rot);
	
	static function clone( xf : Transform) : Transform;
	
	static function neo( position : Vec2, rotation : Rot) : Transform;
	
	static function identity() : Transform;
	
	function setIdentity() : Void;
	
	function set( a : EitherType<Transform,Vec2>, ?b : EitherType<Rot,Float>) : Void;
	
	static function isValid( o : Transform) : Bool;
	
	static function assert( o : Transform) : Void;
	
	static function mul( a : Transform, b : EitherType<Vec2,Transform>) : EitherType<Vec2,Transform>;
	
	static function mulT( a : Transform, b : EitherType<Vec2,Transform>) : EitherType<Vec2,Transform>;
}