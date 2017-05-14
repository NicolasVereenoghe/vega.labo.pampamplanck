package vega.ui;
import pixi.core.display.Container;
import pixi.flump.Movie;
import vega.utils.Utils;
import vega.utils.UtilsFlump;

/**
 * compteur de score justifié (gauche, centré ou droite), construit à partir d'un modèle flump
 * 
 * @author nico
 */
class MyCtrJustifiedFlump {
	public static inline var SIDE_LEFT		: Int						= -1;
	public static inline var SIDE_RIGHT		: Int						= 1;
	public static inline var SIDE_CENTER	: Int						= 0;
	
	var DIGIT_RADIX							: String					= "digit";
	
	var container							: Movie;
	
	var side								: Int;
	
	var nbDigits							: Int;
	
	public function new() { }
	
	public function init( pCont : Movie, pSide : Int) {
		container	= pCont;
		side		= pSide;
		nbDigits	= 0;
		
		while ( getDigitI( nbDigits + 1) != null) nbDigits++;
		
		setVal( 0);
	}
	
	public function destroy() : Void {
		container = null;
	}
	
	public function setVal( pVal : Int) : Void {
		if ( side == SIDE_LEFT) setValLeft( pVal);
		else if ( side == SIDE_RIGHT) setValRight( pVal);
		else setValCenter( pVal);
	}
	
	function setDigitIVal( pI : Int, pUnitVal : Int) : Void {
		var lCont	: Container	= getDigitI( pI);
		
		lCont.visible = true;
		cast( lCont.getChildAt( 0), Movie).gotoAndStop( pUnitVal);
	}
	
	function getDigitI( pI : Int) : Container { return UtilsFlump.getLayer( "digit" + pI, container); }
	
	function setValLeft( pVal : Int) : Void {
		var lStr	: String	= Std.string( pVal);
		var lI		: Int		= 0;
		
		while ( getDigitI( ++lI) != null) {
			if ( lI <= lStr.length) setDigitIVal( nbDigits - Utils.minInt( lStr.length, nbDigits) + lI, Std.parseInt( lStr.charAt( lStr.length - lI)));
			else getDigitI( nbDigits - lI + 1).visible = false;
		}
	}
	
	function setValRight( pVal : Int) : Void {
		var lStr	: String	= Std.string( pVal);
		var lI		: Int		= 0;
		
		while ( getDigitI( ++lI) != null) {
			if ( lI <= lStr.length) setDigitIVal( lI, Std.parseInt( lStr.charAt( lStr.length - lI)));
			else getDigitI( lI).visible = false;
		}
	}
	
	function setValCenter( pVal : Int) : Void {
		var lX		: Float		= 0;
		var lI		: Int		= 0;
		var lDigit	: Container	= getDigitI( nbDigits);
		var lNext	: Container;
		
		setValRight( pVal);
		
		while ( ! lDigit.visible) {
			lNext	= getDigitI( nbDigits - ++lI);
			lX		+= ( lDigit.x - lNext.x) / 2;
			lDigit	= lNext;
		}
		
		container.x = lX;
	}
}