package vega.utils;

/**
 * ...
 * @author nico
 */
class RectangleIJ {
	public var i						: Int;
	public var j						: Int;
	public var width					: Int;
	public var height					: Int;

	public function new( pI : Int = 0, pJ : Int = 0, pWidth : Int = 0, pHeight : Int = 0) {
		i		= pI;
		j		= pJ;
		width	= pWidth;
		height	= pHeight;
	}
	
	public function clone() : RectangleIJ { return new RectangleIJ( i, j, width, height); }
	
	public function offset( pDI : Int, pDJ : Int) : Void {
		i += pDI;
		j += pDJ;
	}
	
	public function getRight() : Int { return i + width; }
	public function getLeft() : Int { return i; }
	public function getBottom() : Int { return j + height; }
	public function getTop() : Int { return j; }
}