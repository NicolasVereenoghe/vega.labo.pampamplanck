package vega.screen;
import pixi.core.display.Container;
import pixi.core.text.Text;
import pixi.flump.Movie;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.local.LocalMgr;
import vega.shell.ApplicationMatchSize;
import vega.shell.VegaFramer;
import vega.utils.UtilsFlump;

/**
 * ...
 * @author nico
 */
class MyScreenInitLoad extends MyScreenLoad {
	public function new() {
		super();
		
		bgColor			= 0xFFFFFF;
		fadeFrontColor	= 0xFFFFFF;
		FADE_DELAY		/= 2;
		ASSET_ID		= "screenInitLoad";
	}
	
	override public function destroy() : Void {
		cast( asset.getContent(), Movie).getLayer( "barFront").getChildAt( 0).cacheAsBitmap = null;
		
		LocalMgr.instance.freeLocalTxtInMovie( cast asset.getContent());
		
		super.destroy();
	}
	
	override public function start() : Void { setModeProgress(); }
	
	override function doLoadFinal() : Void {
		super.doLoadFinal();
		
		shell.onScreenClose( this);
		
		setModeFadeFront();
	}
	
	override function buildContent() : Void {
		super.buildContent();
		
		cast( asset.getContent(), Movie).getLayer( "barFront").getChildAt( 0).cacheAsBitmap = true;
		
		LocalMgr.instance.parseAndSetLocalTxtInMovie( cast asset.getContent());
		
		refreshBar();
	}
	
	override function launchAfterInit() : Void { shell.onScreenReady( this); }
	
	override function doModeProgress( pTime : Float) : Void {
		super.doModeProgress( pTime);
		
		refreshBar();
	}
	
	function refreshBar() : Void {
		cast( asset.getContent(), Movie).getLayer( "barFront").getChildAt( 0).scale.x = Math.max( .005, curRate);
	}
}