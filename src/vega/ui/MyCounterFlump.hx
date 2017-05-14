package vega.ui;
import pixi.core.display.Container;
import pixi.flump.Movie;
import vega.utils.UtilsFlump;

/**
 * compteur de score à placement fixe, modèle flump ; frames 0..9 <=> chiffres 0..9 ; frame 10 <=> emplacement chiffre vide
 * 
 * @author nico
 */
class MyCounterFlump {
	/** racine des nom des modèles d"assets de chiffre du conteneur */
	var DIGIT_RADIX					: String		= "digit";
	
	/** liste de timelines de chiffre générés à partir des modèles parsés ; indexés par degré croissant (0 <=> unités, 1 <=> dixaines, 2 <=> centaines, ...) */
	var digits						: Array<Movie>	= null;
	
	/** valeur du compteur */
	var value						: Int			= -1;
	
	/**
	 * construction du compteur : on parse le conteneur pour trouver des assets de chiffres
	 * @param	pContainer	conteneur flump des assets du compteur utilisé pour afficher le rendu du compteur
	 * @param	pValue		valeur initiale du compteur
	 */
	public function new( pContainer : Movie, pValue : Int = 0) {
		var lCtr	: Int		= 1;
		var lCont	: Container	= UtilsFlump.getLayer( DIGIT_RADIX + lCtr, pContainer);
		
		digits	= new Array<Movie>();
		
		while ( lCont != null){
			digits.push( cast lCont.getChildAt( 0));
			
			lCont = UtilsFlump.getLayer( DIGIT_RADIX + ++lCtr, pContainer);
		}
		
		setValue( pValue);
	}
	
	/**
	 * on set la valeur du compteur
	 * @param	pVal	valeur du compteur
	 */
	public function setValue( pVal : Int) : Void {
		var lVal	: String;
		var lI		: Int;
		
		if ( pVal != value) {
			lVal	= Std.string( pVal);
			
			lI = 0;
			while ( lI < digits.length) {
				if ( lVal.length > lI) {
					digits[ lI].gotoAndStop( Std.parseInt( lVal.charAt( lVal.length - 1 - lI)));
				}else {
					digits[ lI].gotoAndStop( 10);
				}
				
				lI++;
			}
			
			value	= pVal;
		}
	}
	
	/**
	 * on récupère la valeur du compteur
	 * @return	valeur numérique du compteur
	 */
	public function getValue() : Int { return value; }
	
	/**
	 * destruction
	 */
	public function destroy() : Void { digits = null; }
}