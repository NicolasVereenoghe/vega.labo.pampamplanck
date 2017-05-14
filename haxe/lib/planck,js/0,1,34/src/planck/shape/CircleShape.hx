package planck.shape;

import planck.Shape;
import planck.common.Vec2;

import haxe.extern.EitherType;

@:native("planck.Circle")
extern class CircleShape extends Shape {
	static var TYPE				: String;
	
	var m_p						: Vec2;
	
	function new( ?a : EitherType<Vec2,Float>, ?b : Float);
	
	function getCenter() : Vec2;
	
	function getSupportVertex() : Vec2;
	
	function getVertex( index : Int) : Vec2;
	
	function getVertexCount( index : Int) : Int;
}