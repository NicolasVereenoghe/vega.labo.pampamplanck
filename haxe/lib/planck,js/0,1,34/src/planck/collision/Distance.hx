package planck.collision;

import planck.Shape;
import planck.common.Transform;
import planck.common.Vec2;

@:native("planck.internal.Distance")
extern class Distance {
	function new( output : DistanceOutput, cache : SimplexCache, input : DistanceInput);
	
	static function testOverlap( shapeA : Shape, indexA : Int, shapeB : Shape, indexB : Int, xfA : Transform, xfB : Transform) : Bool;
}

@:native("planck.internal.Distance.Input")
extern class DistanceInput {
	var proxyA					: DistanceProxy;
	var proxyB					: DistanceProxy;
	var transformA				: Transform;
	var transformB				: Transform;
	var useRadii				: Bool;
	
	function new();
}

@:native("planck.internal.Distance.Output")
extern class DistanceOutput {
	var pointA					: Vec2;
	var pointB					: Vec2;
	var distance				: Float;
	var iterations				: Int;
	
	function new();
}

@:native("planck.internal.Distance.Cache")
extern class SimplexCache {
	var metric					: Float;
	var indexA					: Array<Int>;
	var indexB					: Array<Int>;
	var count					: Int;
	
	function new();
}

@:native("planck.internal.Distance.Proxy")
extern class DistanceProxy {
	var m_buffer				: Array<Vec2>;
	var m_vertices				: Array<Vec2>;
	var m_count					: Int;
	var m_radius				: Float;
	
	function new();
	
	function getVertexCount() : Int;
	
	function getVertex( index : Int) : Vec2;
	
	function getSupport( d : Vec2) : Int;
	
	function getSupportVertex( d : Vec2) : Vec2;
	
	function set( shape : Shape, index : Int) : Void;
}