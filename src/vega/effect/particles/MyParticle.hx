package vega.effect.particles;
import pixi.core.sprites.Sprite;

/**
 * ...
 * @author nico
 */
class MyParticle {
	var mgr									: MyParticleMgr								= null;
	
	public var sprite( get, null)			: Sprite;
	var _sprite								: Sprite									= null;
	function get_sprite() : Sprite { return _sprite; }
	
	public function new( pId : String, pX : Float, pY : Float) {
		_sprite	= instanciateTextureSprite( pId);
		
		_sprite.x	= pX;
		_sprite.y	= pY;
	}
	
	public function initDisplayOn( pMgr : MyParticleMgr) : Void {
		mgr = pMgr;
		
		addSpriteToContainer();
	}
	
	public function doFrame( pDt : Float) : Void { }
	
	public function destroy() : Void {
		freeTextureSprite();
		
		mgr.remParticle( this);
		
		mgr = null;
	}
	
	function addSpriteToContainer() : Void { mgr.container.addChild( _sprite); }
	
	function instanciateTextureSprite( pId : String) : Sprite { return null; }
	
	function freeTextureSprite() : Void {
		if ( _sprite != null){
			if ( _sprite.parent != null) _sprite.parent.removeChild( _sprite);
			
			_sprite.destroy();
			_sprite = null;
		}
	}
}