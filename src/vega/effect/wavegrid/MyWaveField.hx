package vega.effect.wavegrid;
import pixi.core.math.Point;

/**
 * descripteur de champ de vagues
 * 
 * @author nico
 */
class MyWaveField {
	/** période de vague en pixels */
	var PERIOD							: Float								= 180;
	
	/** avancée du cycle de vagues par itération */
	var SPEED							: Float								= -9;
	
	/** délai de persisptence une fois apparu en nombre d'itérations ; 0 : on lance transition disparition de suite ; -1 : indéfini */
	var delayStable						: Int;
	
	/** coefficient global appliqué à l'amplitude des vague ; 1 : identité */
	var coefGlobal						: Float;
	
	/** mode d'itération */
	var doMode						: Float -> Bool;
	/** méthode de calcul d'effet de vague */
	var doUpdate					: Point -> Float -> Float -> Void;
	
	/** abscisse source du signal */
	var sourceX							: Float;
	/** ordonnée source du signal */
	var sourceY							: Float;
	
	/** étape d'avancement du signal de vagues en distance relative */
	var curWaveStep						: Float;
	
	/** flag indiquant si le champ est maintenu (true) ou pas (false) */
	var isUpkeep						: Bool								= false;
	
	/**
	 * construction
	 * @param	pX			abscisse source du signal
	 * @param	pY			ordonnée source du signal
	 * @param	pDelay		délai de persisptence une fois apparu en nombre d'itérations ; 0 : on lance transition disparition de suite ; -1 : indéfini
	 * @param	pCoef		coefficient global appliqué à l'amplitude des vague ; 1 : identité
	 */
	public function new( pX : Float, pY : Float, pDelay : Int, pCoef : Float) {
		sourceX		= pX;
		sourceY		= pY;
		delayStable	= pDelay;
		coefGlobal	= pCoef;
		curWaveStep	= -PERIOD / 2;
	}
	
	/** destruction */
	public function destroy() : Void { }
	
	/**
	 * on maintient le champ, pour éviter qu'il ne disparaisse
	 */
	public function upkeep() : Void { isUpkeep = true; }
	
	/**
	 * on ajoute le vecteur vague de ce champ au vecteur passé
	 * @param	pVect	vecteur où accumuler la vague du champ
	 * @param	pX		abscisse dans le champ
	 * @param	pY		ordonnée dans le champ
	 */
	public function updateVectAt( pVect : Point, pX : Float, pY : Float) : Void {
		if ( doUpdate != null) doUpdate( pVect, pX, pY);
	}
	
	/**
	 * itération
	 * @param	pDT	delta t en ms
	 * @return	true si le champ subsiste, false si il doit être détruit
	 */
	public function doFrame( pDT : Float) : Bool {
		if ( doMode != null) return doMode( pDT);
		else return false;
	}
}