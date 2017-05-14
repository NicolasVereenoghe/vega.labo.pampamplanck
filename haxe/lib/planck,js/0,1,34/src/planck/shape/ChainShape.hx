package planck.shape;

import planck.Shape;
import planck.common.Vec2;

@:native("planck.Chain")
extern class ChainShape extends Shape {
	static var TYPE				: String;
	
	var m_vertices				: Array<Vec2>;
	var m_count					: Int;
	var m_prevVertex			: Vec2;
	var m_nextVertex			: Vec2;
	var m_hasPrevVertex			: Bool;
	var m_hasNextVertex			: Bool;
	
	function new( ?vertices : Array<Vec2>, ?loop : Bool);
	
	function _createLoop( vertices : Array<Vec2>) : ChainShape;
	
	function _createChain( vertices : Array<Vec2>) : ChainShape;
	
	function _setPrevVertex( prevVertex : Vec2) : Void;
	
	function _setNextVertex( nextVertex : Vec2) : Void;
	
	function getChildEdge( edge : EdgeShape, childIndex : Int) : Void;
	
	function getVertex( index : Int) : Vec2;
}