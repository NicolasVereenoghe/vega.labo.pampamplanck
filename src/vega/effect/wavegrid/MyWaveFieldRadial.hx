package vega.effect.wavegrid;
import pixi.core.math.Point;

/**
 * champ radial de vagues
 * 
 * @author nico
 */
class MyWaveFieldRadial extends MyWaveField {
	/** distance max d'effet de l'onde radiale */
	var DIST_MAX						: Float						= 540;
	
	/** délai de disparition en nombre d'itérations */
	var DELAY_DISAPPEAR					: Int						= 45;
	
	/** coef max appliqué à l'onde d'apparition */
	var COEF_APPEAR						: Float						= 1.5;
	
	/** compteur d'état */
	var ctrState						: Int;
	/** compteur de distance */
	var ctrDist							: Float;
	
	/**
	 * construction
	 * @param	pX			abscisse source du signal
	 * @param	pY			ordonnée source du signal
	 * @param	pTrans		true pour jouer transition d'apparition, false pour apparaître sans transition
	 * @param	pDelay		délai de persisptence une fois apparu en nombre d'itérations ; 0 : on lance transition disparition de suite ; -1 : indéfini
	 * @param	pCoef		coefficient global appliqué à l'amplitude des vague ; 1 : identité
	 */
	public function new( pX : Float, pY : Float, pTrans : Bool, pDelay : Int, pCoef : Float) {
		super( pX, pY, pDelay, pCoef);
		
		if ( pTrans) setModeAppear();
		else setModeRun();
	}
	
	/**
	 * on passe en mode apparition
	 */
	function setModeAppear() : Void {
		ctrDist = 0;
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
		var lDX		: Float	= pX - sourceX;
		var lDY		: Float	= pY - sourceY;
		var lDist	: Float	= lDX * lDX + lDY * lDY;
		var lWave	: Float;
		
		if ( lDist <= ctrDist * ctrDist){
			if ( lDist > 0){
				lDist	= Math.sqrt( lDist);
				
				lDX		/= lDist;
				lDY		/= lDist;
				
				lWave	= coefGlobal * ( 1 - lDist / ctrDist) * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD) * ( 1 + ( COEF_APPEAR - 1) * lDist / ctrDist);
				pVect.x	+= lWave * lDX;
				pVect.y	+= lWave * lDY;
			}
		}
	}
	
	/**
	 * on itére en mode apparition
	 * @param	pDT	delta t en ms
	 * @return	false pour signaler la fin du champ, true pour continuer
	 */
	function doModeAppear( pDT : Float) : Bool {
		curWaveStep = ( curWaveStep + SPEED) % PERIOD;
		
		ctrDist += Math.abs( SPEED);
		
		if ( ctrDist >= DIST_MAX - PERIOD * .25) setModeRun();
		
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
		var lDX		: Float	= pX - sourceX;
		var lDY		: Float	= pY - sourceY;
		var lDist	: Float	= lDX * lDX + lDY * lDY;
		var lWave	: Float;
		
		if( lDist <= DIST_MAX * DIST_MAX){
			if ( lDist > 0){
				lDist	= Math.sqrt( lDist);
				
				lDX		/= lDist;
				lDY		/= lDist;
			 	
				lWave	= coefGlobal * ( 1 - lDist / DIST_MAX) * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD);
				pVect.x	+= lWave * lDX;
				pVect.y	+= lWave * lDY;
			}
		}
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
		var lDX		: Float	= pX - sourceX;
		var lDY		: Float	= pY - sourceY;
		var lDist	: Float	= lDX * lDX + lDY * lDY;
		var lWave	: Float;
		
		if( lDist <= DIST_MAX * DIST_MAX){
			if ( lDist > 0){
				lDist	= Math.sqrt( lDist);
				
				lDX		/= lDist;
				lDY		/= lDist;
			 	
				lWave	= coefGlobal * ( 1 - lDist / DIST_MAX) * ( 1 - ctrState / DELAY_DISAPPEAR) * Math.sin( 2 * Math.PI * ( curWaveStep + lDist) / PERIOD);
				pVect.x	+= lWave * lDX;
				pVect.y	+= lWave * lDY;
			}
		}
	}
	
	/**
	 * on itère en mode disparition
	 * @param	pDT	delta t en ms
	 * @return	false pour signaler la fin du champ, true pour continuer
	 */
	function doModeDisappear( pDT : Float) : Bool {
		curWaveStep = ( curWaveStep + SPEED) % PERIOD;
		
		if ( ++ctrState >= DELAY_DISAPPEAR) return false;
		else return true;
	}
}