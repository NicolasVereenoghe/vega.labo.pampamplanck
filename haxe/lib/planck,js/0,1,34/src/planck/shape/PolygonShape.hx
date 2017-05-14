package planck.shape;

import planck.Shape;
import planck.common.Vec2;

@:native("planck.Polygon")
extern class PolygonShape extends Shape {
	static var TYPE				: String;
	
	var m_centroid				: Vec2;
	var m_vertices				: Array<Vec2>;
	var m_normals				: Array<Vec2>;
	var m_count					: Int;
	
	function new( ?vertices : Array<Vec2>);
	
	function getVertex( index : Int) : Vec2;
	
	function _set( vertices : Array<Vec2>) : Void;
	
	function validate() : Bool;
}