package vega.effect.wavegrid;
import pixi.core.math.Point;

/**
 * champ linéaire de vagues
 * 
 * @author nico
 */
class MyWaveFieldLinear extends MyWaveField {
	/** délai de fade en nombre d'itérations */
	var DELAY_FADE						: Int						= 45;
	
	/** x vecteur unitaire directeur vagues */
	var cos								: Float;
	/** y vecteur unitaire directeur vagues */
	var sin								: Float;
	
	/** compteur d'état */
	var ctrState						: Int;
	
	/**
	 * construction
	 * @param	pX			abscisse source du signal
	 * @param	pY			ordonnée source du signal
	 * @param	pDelay		délai de persisptence une fois apparu en nombre d'itérations ; 0 : on lance transition disparition de suite ; -1 : indéfini
	 * @param	pCoef		coefficient global appliqué à l'amplitude des vague ; 1 : identité
	 * @param	pCos		x vecteur unitaire directeur vagues
	 * @param	pSin		y vecteur unitaire directeur vagues
	 * @param	pTrans		true pour jouer transition d'apparition, false pour apparaître sans transition
	 */
	public function new( pX : Float, pY : Float, pDelay : Int, pCoef : Float, pCos : Float, pSin : Float, pTrans : Bool) {
		super( pX, pY, pDelay, pCoef);
		
		cos	= pCos;
		sin = pSin;
		
		if ( pTrans) setModeAppear();
		else setModeRun();
	}
	
	/**
	 * on récupère l'orientation du vent
	 * @return	orientation en rad
	 */
	public function getOrient() : Float { return Math.atan2( sin, cos); }
	
	/**
	 * on passe en mode apparition
	 */
	function setModeAppear() : Void {
		ctrState = 0;
		doMode = doModeAppear;
		doUpdate = doUpdateAppear;
	}
	
	/**
	 * mise à jour de vague en mode apparition
	 * @param	pVect	vecteur où accumuler la vague du champ
	 * @param	pX		abscisse dans le champ
	 * @param	pY		ordonnée dans le champ
	 */
	function doUpdateAppear( pVect : Point, pX : Float, pY : Float) : Void {
		var lDist	: Float	= ( pX - sourceX) * cos + ( pY - sourceY) * sin;
		var lWave	: Float	= coefGlobal * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD) * ( ctrState / DELAY_FADE);
		
		pVect.x	+= lWave * cos;
		pVect.y	+= lWave * sin;
	}
	
	/**
	 * on itére en mode apparition
	 * @param	pDT	delta t en ms
	 * @return	false pour signaler la fin du champ, true pour continuer
	 */
	function doModeAppear( pDT : Float) : Bool {
		curWaveStep = ( curWaveStep + SPEED) % PERIOD;
		
		if ( ++ctrState >= DELAY_FADE) setModeRun();
		
		return true;
	}
	
	/**
	 * on passe en mode cycle normal stable
	 */
	function setModeRun() : Void {
		doMode = doModeRun;
		doUpdate = doUpdateRun;
	}
	
	/**
	 * mise à jour de vague en mode cycle normal
	 * @param	pVect	vecteur où accumuler la vague du champ
	 * @param	pX		abscisse dans le champ
	 * @param	pY		ordonnée dans le champ
	 */
	function doUpdateRun( pVect : Point, pX : Float, pY : Float) : Void {
		var lDist	: Float	= ( pX - sourceX) * cos + ( pY - sourceY) * sin;
		var lWave	: Float	= coefGlobal * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD);
		
		pVect.x	+= lWave * cos;
		pVect.y	+= lWave * sin;
	}
	
	/**
	 * on itére en mode cycle normal stable
	 * @param	pDT	delta t en ms
	 * @return	false pour signaler la fin du champ, true pour continuer
	 */
	function doModeRun( pDT : Float) : Bool {
		curWaveStep = ( curWaveStep + SPEED) % PERIOD;
		
		if ( delayStable > 0) delayStable--;
		else if ( delayStable == 0){
			if ( ! isUpkeep) setModeDisappear();
			else isUpkeep = false;
		}
		
		return true;
	}
	
	/**
	 * on passe en mode disparition
	 */
	function setModeDisappear() : Void {
		ctrState = 0;
		doMode = doModeDisappear;
		doUpdate = doUpdateDisappear;
	}
	
	/**
	 * mise à jour de vague en mode disparition
	 * @param	pVect	vecteur où accumuler la vague du champ
	 * @param	pX		abscisse dans le champ
	 * @param	pY		ordonnée dans le champ
	 */
	function doUpdateDisappear( pVect : Point, pX : Float, pY : Float) : Void {
		var lDist	: Float	= ( pX - sourceX) * cos + ( pY - sourceY) * sin;
		var lWave	: Float	= coefGlobal * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD) * ( 1 - ctrState / DELAY_FADE);
		
		pVect.x	+= lWave * cos;
		pVect.y	+= lWave * sin;
	}
	
	/**
	 * on itère en mode disparition
	 * @param	pDT	delta t en ms
	 * @return	false pour signaler la fin du champ, true pour continuer
	 */
	function doModeDisappear( pDT : Float) : Bool {
		curWaveStep = ( curWaveStep + SPEED) % PERIOD;
		
		if ( ++ctrState >= DELAY_FADE) return false;
		else return true;
	}
}