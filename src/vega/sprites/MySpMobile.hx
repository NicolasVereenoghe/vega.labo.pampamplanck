package vega.sprites;
import pixi.core.math.Point;
import vega.sprites.MyCell;
import vega.sprites.MySpriteMgr;

/**
 * un mobile physique
 * 
 * @author	nico
 */
class MySpMobile extends MySpFrame {
	/** norme de gravité */
	var _GRAV									: Float							= 10;
	/** vecteur de gravité */
	var GRAV( get, null)						: Point;
	/** masse du mobile */
	var MASSE									: Float							= 1;
	/** facteur de friction */
	var FROT									: Float							= .1;
	/** vitesse max */
	var SPEED_MAX								: Float							= 15;
	/** coef de réflexion de vitesse sur collision (0 => pas de rebond, 1 => réflexion sans amorti avec rebond) */
	var SPEED_BOUNCE_REFLECT_COEF				: Float							= 0;
	
	/** vitesse */
	var speed									: Point							= null;
	/** accumulation de forces en x */
	var accFX									: Float							= 0;
	/** accumulation de forces en y */
	var accFY									: Float							= 0;
	
	public function new() { super(); }
	
	override public function init( pMgr : MySpriteMgr, pDesc : MyCell = null) : Void {
		super.init( pMgr, pDesc);
		
		initMobile();
	}
	
	override public function doFrame( pDT : Float) : Void {
		doPhys();
		
		super.doFrame( pDT);
	}
	
	/**
	 * calcul de vecteur gravité
	 * @return	vecteur gravité
	 */
	function get_GRAV() : Point { return new Point( 0, _GRAV); }
	
	/**
	 * initisation des propriétés physiques du mobile
	 */
	function initMobile() : Void {
		speed	= new Point( 0, 0);
	}
	
	/**
	 * on résoud la physique du mobile
	 */
	function doPhys() : Void {
		var lLen	: Float;
		
		speed.x	+= GRAV.x + ( accFX - speed.x * FROT) / MASSE;
		speed.y	+= GRAV.y + ( accFY - speed.y * FROT) / MASSE;
		
		lLen = speed.x * speed.x + speed.y * speed.y;
		if ( lLen > SPEED_MAX * SPEED_MAX){
			lLen	= Math.sqrt( lLen);
			
			speed.x	*= SPEED_MAX / lLen;
			speed.y	*= SPEED_MAX / lLen;
		}
		
		accFX	= 0;
		accFY	= 0;
		
		x		+= speed.x;	
		y		+= speed.y;
	}
	
	/**
	 * on résoud la réaction à une collision
	 * @param	pCos	composante x unitaire du vecteur de sortie de collision
	 * @param	pSin	composante y unitaire du vecteur de sortie de collision
	 */
	function onBounce( pCos : Float, pSin : Float) : Void {
		var lScalar	: Float	= pCos * speed.x + pSin * speed.y;
		
		if ( lScalar < 0){
			speed.x	-= lScalar * pCos * ( 1 + SPEED_BOUNCE_REFLECT_COEF);
			speed.y	-= lScalar * pSin * ( 1 + SPEED_BOUNCE_REFLECT_COEF);
		}
	}
}