package vega.shell;
import js.Browser;

/**
 * lib de détection de la plate-forme d'éxécution
 * 
 * @author	nico
 */
class VegaBrowserDetect {
	public static function isIOS() : Bool {
		var lField	: String;
		
		if ( Browser.supported){
			lField = Browser.navigator.userAgent.toLowerCase();
			
			return lField.indexOf( "ipad") != -1 || lField.indexOf( "ipod") != -1 || lField.indexOf( "iphone") != -1;
		}else{
			ApplicationMatchSize.instance.traceDebug( "WARNING : VegaBrowserDetect::isIOS : no browser, unable to detect");
			
			return false;
		}
	}
}