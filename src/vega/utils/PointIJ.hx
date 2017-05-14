package vega.utils;

/**
 * ...
 * @author nico
 */
class PointIJ {
	public var i				: Int;
	public var j				: Int;
	
	public function new( pI : Int = 0, pJ : Int = 0) {
		i	= pI;
		j	= pJ;
	}
	
	public function add( pPt : PointIJ) : PointIJ { return new PointIJ( i + pPt.i, j + pPt.j); }
	
	public function clone() : PointIJ { return new PointIJ( i, j); }
}