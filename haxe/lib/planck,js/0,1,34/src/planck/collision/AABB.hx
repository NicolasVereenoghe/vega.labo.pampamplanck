package planck.collision;

import planck.common.Vec2;

@:structInit
class RayCastInput {
	public var p1					: Vec2;
	public var p2					: Vec2;
	public var maxFraction			: Float;
	
	public function new( p1 : Vec2, p2 : Vec2, maxFraction : Float) {
		this.p1				= p1;
		this.p2				= p2;
		this.maxFraction	= maxFraction;
	}
}

@:structInit
class RayCastOutput {
	public var normal				: Vec2;
	public var fraction				: Float;
	
	public function new( normal : Vec2, fraction : Float) {
		this.normal		= normal;
		this.fraction	= fraction;
	}
}

@:native("planck.AABB")
extern class AABB {
	var lowerBound					: Vec2;
	var upperBound					: Vec2;
	
	function new( ?lower : Vec2, ?upper : Vec2);
	
	function isValid() : Bool;
	
	static function isValid( aabb : AABB) : Bool;
	
	function getCenter() : Vec2;
	
	function getExtents() : Vec2;
	
	function getPerimeter() : Float;
	
	function combine( a : AABB, ?b : AABB) : Void;
	
	function combinePoints( a : Vec2, b : Vec2) : Void;
	
	function set( aabb : AABB) : Void;
	
	function contains( aabb : AABB) : Bool;
	
	function extend( value : Float) : Void;
	
	static function extend( aabb : AABB, value : Float) : Void;
	
	static function testOverlap( a : AABB, b : AABB) : Bool;
	
	static function areEqual( a : AABB, b : AABB) : Bool;
	
	static function diff( a : AABB, b : AABB) : Float;
	
	function rayCast( output : RayCastOutput, input : RayCastInput) : Bool;
	
	function toString() : String;
}