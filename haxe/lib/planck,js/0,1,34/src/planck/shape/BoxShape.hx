package planck.shape;

import planck.common.Vec2;
import planck.shape.PolygonShape;

@:native("planck.Box")
extern class BoxShape extends PolygonShape {
	static var TYPE				: String;
	
	function new( hx : Float, hy : Float, ?center : Vec2, ?angle : Float);
}