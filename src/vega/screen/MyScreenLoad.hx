package vega.screen;

/**
 * ...
 * @author nico
 */
class MyScreenLoad extends MyScreen {
	var MAX_POINTS_PER_FRAME			: Float							= .05;
	
	var curRate							: Float							= 0;
	var toRate							: Float							= 0;
	
	var isComplete						: Bool							= false;
	
	public function new() { super(); }
	
	public function onLoadProgress( pLoadRate : Float) : Void { toRate = pLoadRate; }
	
	public function onLoadComplete() : Void {
		isComplete = true;
		toRate = 1;
	}
	
	function doLoadFinal() : Void { doMode = null; }
	
	function setModeProgress() : Void { doMode = doModeProgress; }
	
	function doModeProgress( pTime : Float) : Void {
		if( curRate < toRate){
			curRate += Math.min( toRate - curRate, MAX_POINTS_PER_FRAME);
		}else if ( curRate == 1 && isComplete) doLoadFinal();
	}
}