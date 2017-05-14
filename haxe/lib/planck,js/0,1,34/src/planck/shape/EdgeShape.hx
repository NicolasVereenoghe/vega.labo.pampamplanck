package planck.shape;

import planck.Shape;
import planck.common.Vec2;

@:native("planck.Edge")
extern class EdgeShape extends Shape {
	static var TYPE				: String;
	
	var m_vertex1				: Vec2;
	var m_vertex2				: Vec2;
	
	var m_vertex0				: Vec2;
	var m_vertex3				: Vec2;
	var m_hasVertex0			: Bool;
	var m_hasVertex3			: Bool;
	
	function new( ?v1 : Vec2, ?v2 : Vec2);
	
	function setNext( ?v3 : Vec2) : EdgeShape;
	
	function setPrev( ?v0 : Vec2) : EdgeShape;
	
	function _set( v1 : Vec2, v2 : Vec2) : EdgeShape;
}