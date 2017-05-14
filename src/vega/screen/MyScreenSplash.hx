package vega.screen;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import vega.loader.VegaLoaderMgr;

/**
 * ...
 * @author nico
 */
class MyScreenSplash extends MyScreen {
	var CTRD_DELAY							: Float						= 1500;
	var ctrDDelay							: Float;
	
	public function new() {
		super();
		
		bgColor			= 0xFFFFFF;
		fadeFrontColor	= 0xFFFFFF;
		FADE_DELAY		/= 2;
		ASSET_ID		= "screenSplash";
	}
	
	override public function start() : Void { setModeCtrD(); }
	
	override function launchAfterInit() : Void { shell.onScreenReady( this); }
	
	override function buildContent() : Void {
		super.buildContent();
		
		if ( VegaLoaderMgr.getInstance().getLoadingFile( asset.getDesc().getFile().getId()).isIMG()) {
			asset.x	= -asset.width / 2;
			asset.y	= -asset.height / 2;
		}
	}
	
	function setModeCtrD() : Void {
		ctrDDelay	= 0;
		doMode		= doModeCtrD;
	}
	
	function doModeCtrD( pTime : Float) : Void {
		if ( ctrDDelay + pTime >= CTRD_DELAY){
			shell.onScreenClose( this);
		
			setModeFadeFront();
		}else{
			ctrDDelay += pTime;
		}
	}
}