package bayam.shell;

import bayam.game.MyGMgr;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import pixi.flump.Movie;
import pixi.flump.Sprite;
import pixi.interaction.InteractionEvent;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.shell.ApplicationMatchSize;
import vega.shell.GlobalPointer;
import vega.shell.IGameShell;
import vega.shell.IMyHUD;
import vega.shell.ResizeBroadcaster;
import vega.sound.SndMgr;
import vega.ui.MyButtonFlump;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author nico
 */
class MyHUD implements IMyHUD {
	var shell												: IGameShell					= null;
	
	var asset												: AssetInstance					= null;
	
	var container											: Container						= null;
	
	var doMode												: Float->Void					= null;
	
	var ctrTime												: Float							= -1;
	
	var origScale											: Float							= -1;

	public function new() { }
	
	public function init( pShell : IGameShell, pContainer : Container, pType : String = null) : Void {
		shell		= pShell;
		container	= pContainer;
		
		initAsset();
		
		ResizeBroadcaster.getInstance().addListener( onResize);
		
		onResize();
	}
	
	public function destroy() : Void {
		freeAsset();
		
		container = null;
		shell = null;
		doMode = null;
	}
	
	public function getMobileCont() : Movie { return cast cast( getLayerLeft().getChildAt( 0), Movie).getLayer( "mobiles").getChildAt( 0); }
	
	public function testTopWithRect( pZone : DisplayObject) : Bool {
		var lZone	: DisplayObject	= getTopZone();
		
		return UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds());
	}
	
	public function instanciateSolAsset() : Sprite { return new Sprite( getBotContent().symbolId); }
	
	public function doFrame( pDt : Float) : Void { if ( doMode != null) doMode( pDt); }
	
	public function switchPause( pPause : Bool) : Void { }
	
	function initAsset() : Void {
		var lMc	: Movie;
		
		asset = cast container.addChild( AssetsMgr.instance.getAssetInstance( "myHUD"));
		
		getBotContent().visible = false;
		
		origScale = getMobileCont().scale.x;
	}
	
	function freeAsset() : Void {
		getMobileCont().scale.x = getMobileCont().scale.y = origScale;
		
		container.removeChild( asset);
		asset.free();
		asset = null;
		
		container = null;
	}
	
	function onResize() : Void {
		var lRect	: Rectangle	= ApplicationMatchSize.instance.getScreenRect();
		
		getLayerTop().y		= lRect.y;
		getLayerLeft().x	= lRect.x;
	}
	
	function getLayerTop() : Container { return cast( asset.getContent(), Movie).getLayer( "top"); }
	function getLayerLeft() : Container { return cast( getLayerTop().getChildAt( 0), Movie).getLayer( "left"); }
	
	function getBotContent() : Sprite { return cast cast( asset.getContent(), Movie).getLayer( "bot").getChildAt( 0); }
	
	function getTopZone() : DisplayObject { return cast( getLayerTop().getChildAt( 0), Movie).getLayer( "zone"); }
}