package vega.shell;
import js.Browser;

/**
 * ...
 * @author nico
 */
class VegaFramer {
	static var instance					: VegaFramer						= null;
	
	var iterators						: Array<Float -> Void>;
	
	var lastTime						: Float;
	
	var hasRequest						: Bool								= false;
	
	var isPause							: Bool								= false;
	
	var isError							: Bool								= false;
	
	public static function getInstance() : VegaFramer {
		if ( instance == null) instance = new VegaFramer();
		
		return instance;
	}
	
	function new() {
		iterators = new Array<Float -> Void>();
		
		lastTime = Date.now().getTime();
		
		if ( Browser.supported) onFrame( 0);
		else ApplicationMatchSize.instance.traceDebug( "ERROR : VegaFramer::VegaFramer : no browser, no framing ...");
	}
	
	public function isRegistered( pIterator : Float -> Void) : Bool { return iterators.indexOf( pIterator) != -1; }
	
	public function addIterator( pIterator : Float -> Void) : Void { iterators.push( pIterator); }
	
	public function remIterator( pIterator : Float -> Void) : Void { iterators.remove( pIterator); }
	
	public function switchPause( pIsPause : Bool) : Void {
		if ( isPause && ! pIsPause){
			if ( ! hasRequest){
				lastTime = Date.now().getTime();
				requestFrame();
			}
		}
		
		isPause = pIsPause;
	}
	
	function onFrame( pTime : Float) : Void {
		if ( ApplicationMatchSize.instance.debug){
			if ( isError) return;
			
			try{
				doFrame( pTime);
			}catch ( pE : Dynamic) {
				ApplicationMatchSize.instance.traceDebug( "ERROR :" + Std.string( pE).split( "\n")[ 0]);
				trace( pE);
				
				isError = true;
			}
		}else doFrame( pTime);
	}
	
	function doFrame( pTime : Float) : Void {
		var lTime		: Float;
		var lIterator	: Float -> Void;
		var lClone		: Array<Float -> Void>;
		var lDT			: Float;
		var lInter		: Float;
		var lAjust		: Float;
		
		if ( isPause) hasRequest = false;
		else{
			requestFrame();
			
			lTime	= Date.now().getTime();
			lInter	= 1000 / ApplicationMatchSize.instance.fps;
			lDT		= Math.min( lTime - lastTime, 3 * lInter);
			
			if ( lDT >= lInter){
				lAjust = Math.min( lDT - lInter, lInter / 2);
				lDT -= lAjust;
				
				lClone = iterators.copy();
				for ( lIterator in lClone) if ( ( ! isPause) && iterators.indexOf( lIterator) != -1) lIterator( lDT);
				
				lastTime = lTime - lAjust;
			}
		}
	}
	
	function requestFrame() : Void {
		hasRequest = true;
		Browser.window.requestAnimationFrame( onFrame);
	}
}