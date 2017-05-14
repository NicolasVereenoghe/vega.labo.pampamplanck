package bayam.game;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author 
 */
class Samsam {
	var DROP_SHOOT_AT_FRAME							: Int										= 20;
	
	var hasShot										: Bool										= false;
	
	var mgr											: MyGMgr									= null;
	
	var model										: Container									= null;
	
	var doMode										: Float->Void								= null;
	
	public function new( pMgr : MyGMgr, pLayer : Container, pIsRight : Bool) {
		mgr		= pMgr;
		model	= pLayer;
		
		model.addChild( AssetsMgr.instance.getAssetInstance( "game_samsam"));
		
		getStateShootRight().visible = false;
		getStateShootRight().loop = false;
		getStateShootLeft().visible = false;
		getStateShootLeft().loop = false;
		
		getStateRight().visible = pIsRight;
		getStateLeft().visible = ! pIsRight;
		
		UtilsPixi.setQuickBt( getHitBoxZone(), onBt);
	}
	
	public function destroy() : Void {
		UtilsPixi.unsetQuickBt( getHitBoxZone());
		
		getStateShootRight().gotoAndStop( 0);
		getStateShootLeft().gotoAndStop( 0);
		
		cast( model.removeChildAt( 1), AssetInstance).free();
		
		doMode = null;
		model = null;
		mgr = null;
	}
	
	public function reset() : Void { UtilsPixi.setQuickBt( getHitBoxZone(), onBt); }
	
	public function getHitBoxZone() : DisplayObject {
		if ( getStateLeft().visible || getStateLeft().visible) return getStateLeft();
		else return getStateRight();
	}
	
	public function lock() : Void { UtilsPixi.unsetQuickBt( getHitBoxZone()); }
	
	public function beginShoot() : Void { setModeShoot(); }
	
	public function doFrame( pDt : Float) : Void { if ( doMode != null) doMode( pDt); }
	
	public function switchPause( pIsPause : Bool) : Void {
		if ( getStateShootLeft().visible){
			if ( pIsPause) getStateShootLeft().stop();
			else getStateShootLeft().play();
		}else if ( getStateShootRight().visible) {
			if ( pIsPause) getStateShootRight().stop();
			else getStateShootRight().play();
		}
	}
	
	function onBt( pE : InteractionEvent) : Void { mgr.beginShoot(); }
	
	function getStateRight() : DisplayObject { return cast( cast( model.getChildAt( 1), AssetInstance).getContent(), Movie).getLayer( "right").getChildAt( 0); }
	function getStateLeft() : DisplayObject { return cast( cast( model.getChildAt( 1), AssetInstance).getContent(), Movie).getLayer( "left").getChildAt( 0); }
	function getStateShootRight() : Movie { return cast cast( cast( model.getChildAt( 1), AssetInstance).getContent(), Movie).getLayer( "shootRight").getChildAt( 0); }
	function getStateShootLeft() : Movie { return cast cast( cast( model.getChildAt( 1), AssetInstance).getContent(), Movie).getLayer( "shootLeft").getChildAt( 0); }
	
	function setModeShoot() : Void {
		if ( getStateLeft().visible){
			getStateLeft().visible = false;
			getStateShootLeft().visible = true;
			getStateShootLeft().play();
		}else{
			getStateRight().visible = false;
			getStateShootRight().visible = true;
			getStateShootRight().play();
		}
		
		hasShot = false;
		
		doMode = doModeShoot;
	}
	
	function doModeShoot( pDt : Float) : Void {
		var lIsL	: Bool	= getStateShootLeft().visible;
		var lMc		: Movie	= lIsL ? getStateShootLeft() : getStateShootRight();
		
		if ( lMc.currentFrame >= DROP_SHOOT_AT_FRAME && ! hasShot) {
			hasShot = true;
			mgr.doShoot( ! lIsL);
		}
		
		if ( lMc.currentFrame == lMc.totalFrames - 1) setModeEnd();
	}
	
	function setModeEnd() : Void {
		if ( getStateShootLeft().visible){
			getStateShootLeft().gotoAndStop( 0);
			getStateShootLeft().visible = false;
			
			getStateLeft().visible = true;
		}else{
			getStateShootRight().gotoAndStop( 0);
			getStateShootRight().visible = false;
			
			getStateRight().visible = true;
		}
		
		doMode = null;
	}
}