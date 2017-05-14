package vega.screen;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.shell.ApplicationMatchSize;
import vega.shell.IShell;
import vega.shell.ResizeBroadcaster;

/**
 * ...
 * @author nico
 */
class MyScreen {
	var FADE_DELAY				: Float				= 200;
	var fadeDelay				: Float;
	
	var ASSET_ID				: String;
	var asset					: AssetInstance;
	
	var container				: Container;
	
	var shell					: IShell;
	
	var content					: Container;
	
	var doMode					: Float -> Void;
	
	var bgColor					: Int				= -1;
	var bg						: Graphics;
	
	var fadeFrontColor			: Int				= 0;
	var fadeFront				: Graphics;
	
	public function new() { }
	
	public function destroy() : Void {
		ResizeBroadcaster.getInstance().remListener( onResize);
		
		if ( bg != null){
			container.removeChild( bg);
			bg.destroy();
			bg = null;
		}
		
		if ( asset != null){
			content.removeChild( asset);
			asset.free();
			asset = null;
		}
		
		if ( fadeFront != null){
			container.removeChild( fadeFront);
			fadeFront.destroy();
			fadeFront = null;
		}
		
		container.removeChild( content);
		content.destroy();
		content = null;
		
		container.parent.removeChild( container);
		container.destroy();
		container = null;
		
		doMode	= null;
		shell	= null;
	}
	
	public function initScreen( pShell : IShell, pContainer : Container) : Void {
		shell		= pShell;
		container	= pContainer;
		
		content		= cast container.addChild( new Container());
		
		buildContent();
		
		ResizeBroadcaster.getInstance().addListener( onResize);
		
		launchAfterInit();
	}
	
	public function start() : Void { }
	
	/**
	 * on demande de fermer l'écran
	 * @param	pNext	instance de prochain écran à ouvrir, ou null si non défini
	 */
	public function askClose( pNext : MyScreen = null) : Void { }
	
	public function doFrame( pTime : Float) : Void { if ( doMode != null) doMode( pTime); }
	
	public function getContainer() : Container { return container; }
	
	public function getShell() : IShell { return shell; }
	
	function onResize() : Void { }
	
	function launchAfterInit() : Void { }
	
	function buildContent() : Void {
		var lRect	: Rectangle;
		
		if ( bgColor >= 0){
			lRect = ApplicationMatchSize.instance.getScreenRectExt();
			
			bg = cast container.addChildAt( new Graphics(), 0);
			bg.beginFill( bgColor);
			bg.drawRect( lRect.x, lRect.y, lRect.width, lRect.height);
			bg.endFill();
		}
		
		if ( ASSET_ID != null){
			asset = cast content.addChild( AssetsMgr.instance.getAssetInstance( ASSET_ID));
		}
	}
	
	function onFadeInComplete() : Void { shell.onScreenReady( this); }
	
	function setModeFadeFront () : Void {
		var lRect	: Rectangle	= ApplicationMatchSize.instance.getScreenRectExt();
		
		fadeFront		= cast container.addChild( new Graphics());
		fadeFront.beginFill( fadeFrontColor);
		fadeFront.drawRect( lRect.x, lRect.y, lRect.width, lRect.height);
		fadeFront.endFill();
		fadeFront.alpha	= 0;
		
		fadeDelay		= 0;
		doMode			= doModeFadeFront;
	}
	
	function doModeFadeFront( pTime : Float) : Void {
		if ( pTime > FADE_DELAY / 2) pTime = FADE_DELAY / 2;
		
		if ( fadeDelay + pTime >= FADE_DELAY){
			content.visible	= false;
			fadeFront.alpha	= 1;
			
			setModeFadeOut();
		}else{
			fadeDelay		+= pTime;
			fadeFront.alpha	= fadeDelay / FADE_DELAY;
		}
	}
	
	function setModeFadeOut() : Void {
		fadeDelay	= 0;
		doMode		= doModeFadeOut;
	}
	
	function doModeFadeOut( pTime : Float) : Void {
		if ( pTime > FADE_DELAY / 2) pTime = FADE_DELAY / 2;
		
		if ( fadeDelay + pTime >= FADE_DELAY){
			container.alpha	= 0;
			
			doMode			= null;
			
			shell.onScreenEnd( this);
		}else{
			fadeDelay		+= pTime;
			container.alpha = 1 - fadeDelay / FADE_DELAY;
		}
	}
	
	function setModeFadeIn() : Void {
		container.alpha	= 0;
		
		fadeDelay		= 0;
		doMode			= doModeFadeIn;
	}
	
	function doModeFadeIn( pTime : Float) : Void {
		if ( pTime > FADE_DELAY / 2) pTime = FADE_DELAY / 2;
		
		if ( fadeDelay + pTime >= FADE_DELAY){
			container.alpha	= 1;
			
			doMode			= null;
			
			onFadeInComplete();
		}else{
			fadeDelay		+= pTime;
			container.alpha = fadeDelay / FADE_DELAY;
		}
	}
}