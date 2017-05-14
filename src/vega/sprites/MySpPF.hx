package vega.sprites;

import pixi.core.math.Point;
import vega.sprites.MySprite;

/**
 * sprite de plateforme simple
 * 
 * @author nico
 */
class MySpPF extends MySprite implements ISpPF {
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function doBounce( pSp : MySprite, pXY : Point = null, pIsFeet : Bool = true) : Bool { return pIsFeet && getHitRect().contains( pXY.x, pXY.y); }
}