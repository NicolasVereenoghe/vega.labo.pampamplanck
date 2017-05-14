package bayam.game;
import pixi.core.display.Container;
import pixi.interaction.InteractionEvent;
import planck.Body;
import vega.shell.ApplicationMatchSize;
import vega.ui.MyButtonFlump;

/**
 * ...
 * @author 
 */
class MyBalle {
	var layerBalle								: Container								= null;
	
	var origX									: Float									= 0;
	var origY									: Float									= 0;
	
	var mgr										: MyGMgr								= null;
	
	var doMode									: Float->Void							= null;
	var ctrTime									: Float									= -1;
	
	var bt										: MyButtonFlump							= null;
	
	var body									: Body									= null;
	
	public function new( pMgr : MyGMgr, pLayerBalle : Container) {
		mgr			= pMgr;
		layerBalle	= pLayerBalle;
		origX		= layerBalle.x;
		origY		= layerBalle.y;
		
		bt			= new MyButtonFlump( cast layerBalle.getChildAt( 0), onBt);
	}
	
	public function destroy() : Void {
		clearBody();
		
		resetPos();
		
		bt.destroy();
		bt = null;
		
		layerBalle.scale.x = layerBalle.scale.y = 1;
		
		doMode = null;
		layerBalle = null;
		mgr = null;
	}
	
	public function reset() : Void {
		resetPos();
		
		bt.switchEnable( true);
		bt.reset();
	}
	
	public function resetHighlight() : Void {
		layerBalle.scale.x = layerBalle.scale.y = 1;
		
		doMode = null;
	}
	
	public function lock() : Void {
		bt.switchEnable( false);
		bt.reset();
	}
	
	public function doShoot( pIsRight : Bool) : Void {
		body = mgr.tablo.createBalle( layerBalle, pIsRight);
		
		setModeShoot();
	}
	
	public function isSleeping() : Bool { return body == null || doMode == doModePending; }
	
	public function setSleeping() : Void {
		clearBody();
		
		doMode = null;
	}
	
	public function askSleeping() : Void { setModePending(); }
	
	public function doFrame( pDt : Float) : Void { if ( doMode != null) doMode( pDt); }
	
	function resetPos() : Void {
		layerBalle.x		= origX;
		layerBalle.y		= origY;
		layerBalle.rotation	= 0;
	}
	
	function onBt( pE : InteractionEvent) : Void { mgr.beginShoot(); }
	
	function clearBody() : Void {
		if ( body != null){
			ApplicationMatchSize.instance.traceDebug( "INFO : MyBalle:clearBody : " + mgr.tablo.m_world.destroyBody( body));
			body = null;
		}
	}
	
	function setModeShoot() : Void {
		ctrTime = mgr.getLvlBalleTimeout();
		
		doMode = doModeShoot;
	}
	
	function doModeShoot( pDt : Float) : Void {
		ctrTime -= pDt;
		
		if ( ctrTime < 0) mgr.onBalleTimeout();
	}
	
	function setModePending() : Void { doMode = doModePending; }
	
	function doModePending( pDt : Float) : Void { setSleeping(); }
}