package vega.effect.particles;
import pixi.core.sprites.Sprite;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;

/**
 * ...
 * @author nico
 */
class MyParticleAsset extends MyParticle {
	var asset							: AssetInstance							= null;
	
	public function new( pId : String, pX : Float, pY : Float) { super( pId, pX, pY); }
	
	override function instanciateTextureSprite( pId : String) : Sprite {
		asset = AssetsMgr.instance.getAssetInstance( pId);
		
		return cast asset.getContent();
	}
	
	override function freeTextureSprite() : Void {
		if ( _sprite != null){
			if ( _sprite.parent != null) _sprite.parent.removeChild( _sprite);
			
			_sprite = null;
			
			asset.free();
			asset = null;
		}
	}
}