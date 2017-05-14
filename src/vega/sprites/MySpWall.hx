package vega.sprites;

import pixi.core.math.Point;
import vega.sprites.MySprite;

/**
 * sprite de mur simple
 * 
 * @author nico
 */
class MySpWall extends MySprite {
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function doBounce( pSp : MySprite, pXY : Point = null, pIsFeet : Bool = true) : Bool { return getHitRect().contains( pXY.x, pXY.y); }
}