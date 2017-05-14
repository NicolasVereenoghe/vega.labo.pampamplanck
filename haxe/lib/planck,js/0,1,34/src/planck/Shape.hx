package planck;

import planck.Body.MassData;
import planck.collision.AABB;
import planck.collision.AABB.RayCastInput;
import planck.collision.AABB.RayCastOutput;
import planck.collision.Distance.DistanceProxy;
import planck.common.Transform;
import planck.common.Vec2;

@:native("planck.Shape")
extern class Shape {
	var m_type							: String;
	var m_radius						: Float;
	
	function new();
	
	static function isValid( shape : Shape) : Bool;
	
	function getRadius() : Float;
	
	function getType() : String;
	
	function getChildCount() : Int;
	
	function testPoint( xf : Transform, p : Vec2) : Bool;
	
	function rayCast( output : RayCastOutput, input : RayCastInput, transform : Transform, childIndex : Int) : Bool;
	
	function computeAABB( aabb : AABB, xf : Transform, childIndex : Int) : Void;
	
	function computeMass( massData : MassData, density : Float) : Void;
	
	function computeDistanceProxy( proxy : DistanceProxy, ?childIndex : Int) : Void;
	
	function _clone() : Shape;
}