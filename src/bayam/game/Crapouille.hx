package bayam.game;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.flump.Movie;
import planck.Body;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.sound.SndMgr;
import vega.sound.SndPlayModeDelayed;
import vega.utils.UtilsFlump;

/**
 * ...
 * @author 
 */
class Crapouille {
	var FRAME_IDLE_FIX								: Int										= 100;
	var FRAME_IDLE_RAND								: Int										= 200;
	
	var mgr											: MyGMgr									= null;
	
	var layer										: Container									= null;
	
	var body										: Body										= null;
	
	var doMode										: Float->Void								= null;
	var ctrFrame									: Int										= -1;
	
	public function new( pMgr : MyGMgr, pLayer : Container) {
		mgr		= pMgr;
		layer	= pLayer;
		
		body	= mgr.tablo.setHitZoneCrap( layer);
		
		pLayer.addChild( AssetsMgr.instance.getAssetInstance( "game_crap"));
		
		getStateIdle().loop = false;
		getStateEchec().loop = false;
		getStateEchecEnd().loop = false;
		getStateReussite().loop = false;
		
		setModeWait();
	}
	
	public function destroy() : Void {
		mgr.tablo.m_world.destroyBody( body);
		body = null;
		
		// TODO !!
		
		UtilsFlump.recursiveGotoAndStop( getContent(), 0);
		
		cast( layer.removeChildAt( 1), AssetInstance).free();
		
		doMode = null;
		layer = null;
		mgr = null;
	}
	
	public function reset() : Void { setModeWait(); }
	
	public function switchPause( pIsPause : Bool) : Void {
		var lMc : Movie = getCurAnime();
		
		if ( lMc != null){
			if ( pIsPause) lMc.stop();
			else lMc.play();
		}
	}
	
	public function lanceAnimEchec( pIsBalleOut : Bool = false) : Void { setModeEchec(); }
	
	public function lanceAnimReussite() : Void { setModeReussite(); }
	
	public function doFrame( pDt : Float) : Void { if ( doMode != null) doMode( pDt); }
	
	function setState( pDisp : DisplayObject) : Void {
		var lMc	: Movie;
		
		if ( doMode != null){
			lMc = getCurAnime();
			
			if ( lMc != null && lMc != pDisp) lMc.stop();
		}
		
		getStateWait().visible		= ( getStateWait() == pDisp);
		getStateIdle().visible		= ( getStateIdle() == pDisp);
		getStateEchec().visible		= ( getStateEchec() == pDisp);
		getStateEchecLoop().visible	= ( getStateEchecLoop() == pDisp);
		getStateEchecEnd().visible	= ( getStateEchecEnd() == pDisp);
		getStateReussite().visible	= ( getStateReussite() == pDisp);
	}
	
	function getCurAnime() : Movie {
		if ( getStateIdle().visible) return getStateIdle();
		if ( getStateEchec().visible) return getStateEchec();
		if ( getStateEchecLoop().visible) return getStateEchecLoop();
		if ( getStateEchecEnd().visible) return getStateEchecEnd();
		if ( getStateReussite().visible) return getStateReussite();
		
		return null;
	}
	
	function getContent() : Movie { return cast cast( layer.getChildAt( 1), AssetInstance).getContent(); }
	function getStateWait() : DisplayObject { return getContent().getLayer( "wait").getChildAt( 0); }
	function getStateIdle() : Movie { return cast getContent().getLayer( "idle").getChildAt( 0); }
	function getStateEchec() : Movie { return cast getContent().getLayer( "echec").getChildAt( 0); }
	function getStateEchecLoop() : Movie { return cast getContent().getLayer( "echecLoop").getChildAt( 0); }
	function getStateEchecEnd() : Movie { return cast getContent().getLayer( "echecEnd").getChildAt( 0); }
	function getStateReussite() : Movie { return cast getContent().getLayer( "reussite").getChildAt( 0); }
	
	function setModeWait() : Void {
		setState( getStateWait());
		
		ctrFrame = FRAME_IDLE_FIX;
		
		doMode = doModeWait;
	}
	
	function doModeWait( pDt : Float) : Void {
		if ( getStateWait().visible){
			if ( --ctrFrame < 0){
				getStateWait().visible = false;
				getStateIdle().visible = true;
				
				getStateIdle().gotoAndPlay( 0);
			}
		}else if ( getStateIdle().currentFrame == getStateIdle().totalFrames - 1){
			ctrFrame = FRAME_IDLE_FIX + Math.floor( FRAME_IDLE_RAND * Math.random());
			
			getStateWait().visible = true;
			getStateIdle().visible = false;
		}
	}
	
	function setModeEchec() : Void {
		setState( getStateEchec());
		
		getStateEchec().gotoAndPlay( 0);
		
		doMode = doModeEchec;
	}
	
	function doModeEchec( pDt : Float) : Void {
		if ( getStateEchec().visible){
			if ( getStateEchec().currentFrame == getStateEchec().totalFrames - 1){
				getStateEchec().visible		= false;
				getStateEchecLoop().visible	= true;
				
				getStateEchecLoop().gotoAndPlay( 0);
			}
		}else if( getStateEchecLoop().visible){
			getStateEchecLoop().stop();
			getStateEchecLoop().visible = false;
			
			getStateEchecEnd().visible = true;
			getStateEchecEnd().gotoAndPlay( 0);
		}else{
			if ( getStateEchecEnd().currentFrame == getStateEchecEnd().totalFrames - 1) mgr.reset();
		}
	}
	
	function setModeReussite() : Void {
		setState( getStateReussite());
		
		getStateReussite().gotoAndPlay( 0);
		
		doMode = doModeReussite;
	}
	
	function doModeReussite( pDt : Float) : Void {
		if ( getStateReussite().currentFrame == getStateReussite().totalFrames - 1){
			setModeWait();
			
			mgr.onWin();
		}
	}
}