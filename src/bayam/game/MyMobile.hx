package bayam.game;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import planck.Body;
import vega.shell.ApplicationMatchSize;
import vega.shell.GlobalPointer;
import vega.sound.SndMgr;
import vega.ui.MyButtonFlump;

/**
 * ...
 * @author 
 */
class MyMobile {
	var DRAG_MOUSE_MIN_TIME				: Float											= 300;
	
	var mgr								: MobileMgr										= null;
	
	var doMode							: Float->Void									= null;
	
	var ctrTime							: Float											= 0;
	
	var wasDown							: Bool											= false;
	
	var model							: Container										= null;
	
	var modelOrigX						: Float											= 0;
	var modelOrigY						: Float											= 0;
	
	var instance						: Movie											= null;
	
	var btInstance						: MyButtonFlump									= null;
	var btModel							: MyButtonFlump									= null;
	
	var dragTouchId						: Int											= -1;
	var dragDelt						: Point											= null;
	
	var shadeDelt						: Point											= null;
	
	var body							: Body											= null;
	
	public function new( pMgr : MobileMgr, pLayerModel : Container) {
		mgr				= pMgr;
		model			= pLayerModel;
		
		model.visible	= false;
		modelOrigX		= model.x;
		modelOrigY		= model.y;
		
		btModel			= new MyBtInGame( cast model.getChildAt( 0), onBtModel);
		btModel.switchEnable( false);
		
		instance		= cast mgr.mgr.myHUD.getMobileCont().addChild( new Movie( cast( model.getChildAt( 0), Movie).symbolId));
		btInstance		= new MyButtonFlump( instance, onBtInstance);
		
		shadeDelt		= new Point( getModelCurShade().x - getModelCurDraw().x, getModelCurShade().y - getModelCurDraw().y);
		
		setModeHUDWait();
	}
	
	public function destroy() : Void {
		freeBody();
		
		dragDelt = null;
		
		getModelCurShade().x	= getModelCurDraw().x + shadeDelt.x;
		getModelCurShade().y	= getModelCurDraw().y + shadeDelt.y;
		
		shadeDelt = null;
		
		btInstance.destroy();
		btInstance = null;
		
		instance.parent.removeChild( instance);
		instance.destroy();
		instance = null;
		
		btModel.destroy();
		btModel = null;
		
		model.visible	= true;
		model.rotation	= 0;
		model.x			= modelOrigX;
		model.y			= modelOrigY;
		model			= null;
		
		doMode = null;
		mgr = null;
	}
	
	public function reset() : Void {
		if ( doMode == doModeHUDWait){
			btInstance.switchEnable( true);
			btInstance.reset();
		}else if ( doMode == doModeTabloWait){
			freeBody();
			
			btModel.switchEnable( false);
			btModel.reset();
			
			btInstance.switchEnable( true);
			btInstance.reset();
			
			model.visible = false;
			instance.visible = true;
			
			setModeHUDWait();
		}
	}
	
	public function lock() : Void {
		if ( doMode == doModeHUDWait){
			btInstance.switchEnable( false);
			btInstance.reset();
		}else if ( doMode == doModeTabloWait){
			btModel.switchEnable( false);
			btModel.reset();
		}else if ( doMode == doModeDrag || doMode == doModePreDrag){
			setModeHUDWait();
			
			btInstance.switchEnable( false);
			btInstance.reset();
		}
	}
	
	public function forceRelease() : Void {
		if ( doMode == doModeDrag || doMode == doModePreDrag){
			setModeHUDWait();
			
			btInstance.reset();
		}
	}
	
	public function isFollowingTouch( pTouchId : Int) : Bool { return ( doMode == doModeDrag || doMode == doModePreDrag) && dragTouchId == pTouchId; }
	
	public function doFrame( pDt : Float) : Void { if ( doMode != null) doMode( pDt); }
	
	function freeBody() : Void {
		if ( body != null){
			mgr.mgr.tablo.m_world.destroyBody( body);
			body = null;
		}
	}
	
	function onBtModel( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= GlobalPointer.instance.getTouchEvent( pE);
		var lPt		: Point;
		
		if ( ! mgr.isUniqueTouch( this, lTouch.id)) return;
		
		freeBody();
		
		dragTouchId	= lTouch.id;
		dragDelt	= pE.data.getLocalPosition( model.parent);
		dragDelt.x	-= model.x;
		dragDelt.y	-= model.y;
		lPt			= pE.data.getLocalPosition( instance.parent);
		instance.x	= lPt.x - dragDelt.x;
		instance.y	= lPt.y - dragDelt.y;
		
		if ( lTouch.isMouse) setModePreDrag();
		else setModeDrag();
	}
	
	function onBtInstance( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= GlobalPointer.instance.getTouchEvent( pE);
		
		if ( ! mgr.isUniqueTouch( this, lTouch.id)) return;
		
		dragTouchId	= lTouch.id;
		dragDelt	= pE.data.getLocalPosition( instance.parent);
		dragDelt.x	-= instance.x;
		dragDelt.y	-= instance.y;
		
		if ( lTouch.isMouse) setModePreDrag();
		else setModeDrag();
	}
	
	function setDragState() : Void {
		btInstance.switchEnable( false);
		//btInstance.reset();
		btInstance.enableState( btInstance.getModel().getLayer( MyButtonFlump.NAME_OVER).getChildAt( 0));
		
		btModel.switchEnable( false);
		btModel.reset();
		
		model.visible = false;
		instance.visible = true;
	}
	
	function releaseDragInvalid() : Void {
		btInstance.switchEnable( true);
		btInstance.reset();
		
		setModeHUDWait();
	}
	
	function doRelease() : Void {
		if ( instance.alpha == 1 && ! mgr.mgr.myHUD.testTopWithRect( instance.getLayer( MyGMgr.LAYER_RECT_BOUNDS))) setModeTabloWait();
		else releaseDragInvalid();
	}
	
	function doDrag() : Void {
		var lCoord	: Point		= GlobalPointer.instance.getTouchId( dragTouchId).coord;
		
		if ( ! ApplicationMatchSize.instance.getScreenRect().contains( lCoord.x, lCoord.y)){
			lCoord.x = Math.max( lCoord.x, ApplicationMatchSize.instance.getScreenRect().x);
			lCoord.y = Math.max( lCoord.y, ApplicationMatchSize.instance.getScreenRect().y);
			
			lCoord.x = Math.min( lCoord.x, ApplicationMatchSize.instance.getScreenRect().x + ApplicationMatchSize.instance.getScreenRect().width);
			lCoord.y = Math.min( lCoord.y, ApplicationMatchSize.instance.getScreenRect().y + ApplicationMatchSize.instance.getScreenRect().height);
		}
		
		lCoord		= instance.parent.toLocal( lCoord, GlobalPointer.instance.getRepere());
		
		instance.x	= lCoord.x - dragDelt.x;
		instance.y	= lCoord.y - dragDelt.y;
		
		if ( mgr.mgr.testWorldWithMobileRect( instance.getLayer( MyGMgr.LAYER_RECT_BOUNDS))) instance.alpha = .2;
		else instance.alpha = 1;
	}
	
	function getModelCurShade() : DisplayObject { return cast( btModel.getCurState(), Movie).getLayer( "shade"); }
	function getModelCurDraw() : DisplayObject { return cast( btModel.getCurState(), Movie).getLayer( "draw"); }
	
	function setModeTabloWait() : Void {
		var lCoord	: Point	= model.parent.toLocal( new Point( instance.x, instance.y), instance.parent);
		
		instance.visible	= false;
		
		model.visible		= true;
		model.rotation		= 0;
		model.x				= lCoord.x;
		model.y				= lCoord.y;
		
		btModel.switchEnable( true);
		btModel.reset();
		
		if ( model.name == MyGMgr.LAYER_SPE_U) body = mgr.mgr.tablo.createSpecialU( model);
		else body = mgr.mgr.tablo.createBoite( model, true);
		
		doModeTabloWait( 0);
		
		doMode = doModeTabloWait;
	}
	
	function doModeTabloWait( pDt : Float) : Void {
		var lCos	: Float	= Math.cos( model.rotation);
		var lSin	: Float	= -Math.sin( model.rotation);
		
		getModelCurShade().x	= getModelCurDraw().x + shadeDelt.x * lCos - shadeDelt.y * lSin;
		getModelCurShade().y	= getModelCurDraw().y + shadeDelt.x * lSin + shadeDelt.y * lCos;
	}
	
	function setModeHUDWait() : Void {
		instance.x		= modelOrigX;
		instance.y		= modelOrigY;
		instance.alpha	= 1;
		
		doMode = doModeHUDWait;
	}
	
	function doModeHUDWait( pDt : Float) : Void { }
	
	function setModePreDrag() : Void {
		wasDown = true;
		
		ctrTime = 0;
		
		setDragState();
		
		doMode = doModePreDrag;
	}
	
	function doModePreDrag( pDt : Float) : Void {
		var lTouch	: TouchDesc	= GlobalPointer.instance.getTouchId( dragTouchId);
		
		ctrTime += pDt;
		
		if ( ctrTime < DRAG_MOUSE_MIN_TIME){
			doDrag();
		}else if ( lTouch.isDown){
			if( wasDown){
				setModeDrag();
				
				doDrag();
			}else doRelease();
		}else {
			wasDown = false;
			
			doDrag();
		}
	}
	
	function setModeDrag() : Void {
		setDragState();
		
		doMode = doModeDrag;
	}
	
	function doModeDrag( pDt : Float) : Void {
		var lTouch	: TouchDesc	= GlobalPointer.instance.getTouchId( dragTouchId);
		
		if ( lTouch != null && lTouch.isDown) doDrag();
		else doRelease();
	}
}