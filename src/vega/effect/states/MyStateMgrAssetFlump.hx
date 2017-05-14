package vega.effect.states;
import pixi.core.display.Container;
import pixi.flump.Movie;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.utils.UtilsFlump;

/**
 * ...
 * @author 
 */
class MyStateMgrAssetFlump {
	var cont								: Container								= null;
	
	public var state( get, null)			: AssetInstance;
	var _state								: AssetInstance							= null;
	function get_state() : AssetInstance { return _state; }
	
	public function new() { }
	
	public function init( pCont : Container) : Void { cont = pCont; }
	
	public function destroy() : Void {
		if ( _state != null){
			UtilsFlump.recursiveGotoAndStop( cast _state.getContent(), 0);
			
			cont.removeChild( _state);
			_state.free();
			
			_state = null;
		}
		
		cont = null;
	}
	
	public function setState( pState : String) : Void {
		if ( _state != null){
			if ( _state.getDesc().id != pState){
				UtilsFlump.recursiveGotoAndStop( cast _state.getContent(), 0);
				
				cont.removeChild( _state);
				_state.free();
			}
		}
		
		_state = cast cont.addChild( AssetsMgr.instance.getAssetInstance( pState));
	}
	
	public function isComplete() : Bool {
		var lMc	: Movie;
		
		if ( Std.is( _state.getContent(), Movie)){
			lMc = cast _state.getContent();
			
			return ( lMc.currentFrame == lMc.totalFrames - 1);
		}else return true;
	}
}