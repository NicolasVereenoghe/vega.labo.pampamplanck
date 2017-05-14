package bayam.game;
import pixi.core.display.Container;

/**
 * ...
 * @author 
 */
class MobileMgr {
	public var mgr( get, null)					: MyGMgr;
	var _mgr									: MyGMgr									= null;
	function get_mgr() : MyGMgr { return _mgr; }
	
	var mobiles									: Array<MyMobile>							= null;
	
	public function new() { }
	
	public function init( pMgr : MyGMgr) : Void {
		_mgr	= pMgr;
		mobiles	= [];
	}
	
	public function add( pLayer : Container) : Void {
		mobiles.push( new MyMobile( this, pLayer));
	}
	
	public function destroy() : Void {
		var lMob	: MyMobile;
		
		for ( lMob in mobiles) lMob.destroy();
		mobiles = null;
		
		_mgr = null;
	}
	
	public function reset() : Void {
		var lMob	: MyMobile;
		
		for ( lMob in mobiles) lMob.reset();
	}
	
	public function lock() : Void {
		var lMob	: MyMobile;
		
		for ( lMob in mobiles) lMob.lock();
	}
	
	public function isUniqueTouch( pMobile : MyMobile, pTouchId : Int) : Bool {
		var lMob	: MyMobile;
		
		for ( lMob in mobiles){
			if ( lMob != pMobile && lMob.isFollowingTouch( pTouchId)) return false;
		}
		
		return true;
	}
	
	public function forceRelease() : Void {
		for ( iMob in mobiles) iMob.forceRelease();
	}
	
	public function doFrame( pDt : Float) : Void {
		var lMob	: MyMobile;
		
		for ( lMob in mobiles) lMob.doFrame( pDt);
	}
}