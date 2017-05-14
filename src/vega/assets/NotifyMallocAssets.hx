package vega.assets;

/**
 * ...
 * @author nico
 */
class NotifyMallocAssets implements INotifyMallocAssets {
	var _onEnd				: Void -> Void;
	var _onProgress			: Int -> Int -> Void;
	
	public function new( pOnEnd : Void -> Void, pOnProgress : Int -> Int -> Void = null) {
		_onEnd		= pOnEnd;
		_onProgress	= pOnProgress;
	}
	
	public function onMallocAssetsProgress( pCurrent : Int, pTotal : Int) : Void {
		if ( _onProgress != null) _onProgress( pCurrent, pTotal);
	}
	
	public function onMallocAssetsEnd() : Void {
		if ( _onEnd != null) {
			_onEnd();
			
			_onEnd		= null;
			_onProgress	= null;
		}
	}
}