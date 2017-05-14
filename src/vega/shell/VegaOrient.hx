package vega.shell;
import js.Browser;
import js.html.DeviceMotionEvent;
import js.html.DeviceOrientationEvent;
import pixi.core.math.Point;

/**
 * ...
 * @author ...
 */
class VegaOrient {
	static var instance									: VegaOrient								= null;
	
	var STACK_MAX										: Int										= 4;
	
	var motionOK										: Bool										= false;
	
	var accelStack										: Array<Float>								= null;
	
	var isTmpVal										: Bool										= false;
	var tmpVal											: Float										= 0;
	
	public static function getInstance() : VegaOrient {
		if ( instance == null) instance = new VegaOrient();
		return instance;
	}
	
	function new() { }
	
	public function init() : Void {
		if ( Browser.supported && Browser.window.orientation != null){
			Browser.window.addEventListener( "devicemotion", onDeviceMotion);
			Browser.window.addEventListener( "orientationchange", onOrientChange);
		}else ApplicationMatchSize.instance.traceDebug( "WARNING : VegaOrient::init : unsupported, no orient");
	}
	
	public function flush() : Void { if ( motionOK) accelStack = []; }
	
	public function getInclinaison() : Float {
		var lRes	: Float	= 0;
		var lVal	: Float;
		
		if ( motionOK && accelStack.length > 0) {
			if ( isTmpVal) return tmpVal;
			
			for ( lVal in accelStack) lRes += lVal;
			
			lRes /= accelStack.length;
			
			tmpVal = lRes;
			isTmpVal = true;
		}
		
		return lRes;
	}
	
	function onDeviceMotion( pE : DeviceMotionEvent) : Void {
		if ( ! motionOK){
			if ( pE.accelerationIncludingGravity != null && pE.accelerationIncludingGravity.x != 0 && pE.accelerationIncludingGravity.y != 0 && pE.accelerationIncludingGravity.z != 0){
				accelStack = [];
				motionOK = true;
			}else return;
		}
		
		isTmpVal = false;
		
		accelStack.push( procInclinaison( pE.accelerationIncludingGravity.x, pE.accelerationIncludingGravity.y, pE.accelerationIncludingGravity.z));
		
		if ( accelStack.length > STACK_MAX) accelStack.shift();
	}
	
	function onOrientChange( pE : DeviceOrientationEvent) : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : VegaOrient::onOrientChange : " + Browser.window.orientation);
	}
	
	function procInclinaison( pAccX : Float, pAccY : Float, pAccZ : Float) : Float {
		var lLen	: Float	= Math.sqrt( pAccX * pAccX + pAccY * pAccY + pAccZ * pAccZ);
		
		if ( VegaBrowserDetect.isIOS()){
			pAccX = -pAccX;
			pAccY = -pAccY;
			pAccZ = -pAccZ;
		}
		
		pAccX	= Math.asin( Math.max( -1, Math.min( 1, pAccX / lLen)));
		pAccY	= Math.asin( Math.max( -1, Math.min( 1, pAccY / lLen)));
		pAccZ	= Math.asin( Math.max( -1, Math.min( 1, pAccZ / lLen)));
		
		if ( Browser.window.orientation == 0){
			// portrait
			return pAccX;
		}else if ( Browser.window.orientation == -90){
			// paysage incliné droite
			return pAccY;
		}else if ( Browser.window.orientation == 90){
			// paysage incliné gauche
			return -pAccY;
		}else if ( Browser.window.orientation == 180){
			// portrait reverse
			return -pAccX;
		}else ApplicationMatchSize.instance.traceDebug( "WARNING : VegaOrient::procInclinaison : unrecognized ref orient : " + Browser.window.orientation);
		
		return 0;
	}
}