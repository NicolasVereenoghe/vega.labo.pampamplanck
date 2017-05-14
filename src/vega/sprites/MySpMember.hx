package vega.sprites;

import pixi.core.math.Point;
import vega.sprites.MySpFrame;
import vega.utils.PointIJ;

/**
 * sprite personnage de plate forme 2d, avec collision gauche doite pieds et tête
 * 
 * @author nico
 */
class MySpMember extends MySpFrame {
	/** distance de canne pour tater / repousser les collisions */
	var CANNE							: Float						= .5;//.5;
	/** nombre maximum de collisions sur une résolution */
	var B_MAX							: Int						= 24;//8;
	
	/** valeur max de temporistation de collision de pieds */
	var TEMPO_FEET						: Int						= 1;
	/** chute de réajustement pendant la temporisation de chute */
	var FALL_TEMPO_FEET					: Float						= 2.5;
	
	/** compteur de temporisation de collision aux pieds pour éviter de tomber abruptement lors d'un déplacement hors d'un bord */
	var tempoFeet						: Int						= 0;
	
	/** composante x de vitesse de déplacement par itération */
	var vX								: Float						= 0;
	/** composante y de vitesse de déplacement par itération */
	var vY								: Float						= 0;
	
	/** construction */
	public function new() {
		super();
		
		tempoFeet = TEMPO_FEET;
	}
	
	/** @inheritDoc */
	override function seekBounce() : Void {
		var lRight	: Array<Point>	= getHitRight();
		var lLeft	: Array<Point>	= getHitLeft();
		var lHead	: Array<Point>	= getHitHead();
		var lFeet	: Array<Point>	= getHitFeet();
		
		if ( testBounce( lRight, false)){
			if ( testBounce( lLeft, false)){
				if ( testBounce( lHead, false)){
					if ( ! testBounce( lFeet, true, 0, 0, filterFeet)){
						doBounceHead();
					}// else unresolved
				}else if ( testBounce( lFeet, true, 0, 0, filterFeet)){
					doBounceFeet();
				}// else unresolved
			}else if( testBounce( lHead, false)){
				if ( testBounce( lFeet, true, 0, 0, filterFeet)){
					doBounceRight();
				}else{
					doBounceHead();
					doBounceRight();
				}
			}else if ( testBounce( lFeet, true, 0, 0, filterFeet)){
				doBounceRight();
				doBounceFeet();
			}else{
				doBounceRight();
			}
		}else if ( testBounce( lLeft, false)){
			if ( testBounce( lHead, false)){
				if ( testBounce( lFeet, true, 0, 0, filterFeet)){
					doBounceLeft();
				}else{
					doBounceHead();
					doBounceLeft();
				}
			}else if ( testBounce( lFeet, true, 0, 0, filterFeet)){
				doBounceLeft();
				doBounceFeet();
			}else{
				doBounceLeft();
			}
		}else if ( testBounce( lHead, false)){
			if ( ! testBounce( lFeet, true, 0, 0, filterFeet)){
				doBounceHead();
			}// else unresolved
		}else if ( testBounce( lFeet, true, 0, 0, filterFeet)){
			doBounceFeet();
		}// else none
	}
	
	/**
	 * teste de collision avec la liste de points spécifiée du sprite
	 * @param	pPts	liste de points de contact à tester
	 * @param	pIsFeet	true si points de pieds, false sinon
	 * @param	pDX		x delta de test
	 * @param	pDY		y delta de test
	 * @param	pFilter	méthode filtre qui teste l'instance et renvoie true si l'instance peut être utilisée pour la collision ; laisser null pour aucun filtre
	 * @return	true si collision, false sinon
	 */
	function testBounce( pPts : Array<Point>, pIsFeet : Bool, pDX : Float = 0, pDY : Float = 0, pFilter : MySprite -> Bool = null) : Bool {
		var lPt	: Point;
		
		for ( lPt in pPts){
			if ( testOneBounce( lPt, pIsFeet, pDX, pDY, pFilter)) return true;
		}
		
		return false;
	}
	
	/**
	 * teste de collision sur 1 seul point de contact
	 * @param	pPt		points de contact à tester
	 * @param	pIsFeet	true si points de pied, false sinon
	 * @param	pDX		x delta de test
	 * @param	pDY		y delta de test
	 * @param	pFilter	méthode filtre qui teste l'instance et renvoie true si l'instance peut être utilisée pour la collision ; laisser null pour aucun filtre
	 * @return	true si collision, false sinon
	 */
	function testOneBounce( pPt : Point, pIsFeet : Bool, pDX : Float = 0, pDY : Float = 0, pFilter : MySprite -> Bool = null) : Bool {
		var lLvl	: LvlGroundMgr			= getBounceLvlGround();
		var lCoordR	: Point					= new Point( x + pPt.x + pDX, y + pPt.y + pDY);
		var lIJ		: PointIJ				= new PointIJ( lLvl.x2i( lCoordR.x), lLvl.y2j( lCoordR.y));
		var lCells	: Map<String,MyCell>	= lLvl.getCellsAt( lLvl.x2ModI( lCoordR.x), lLvl.y2ModJ( lCoordR.y));
		var lCell	: MyCell;
		var lSps	: Array<MySprite>;
		var lSp		: MySprite;
		
		if( lCells != null){
			for ( lCell in lCells) {
				lSps	= mgr.getSpriteCell( lCell, lIJ);
				
				for ( lSp in lSps){
					if ( lSp != this && ( pFilter == null || pFilter( lSp))){
						if( lSp.doBounce( this, lCoordR, pIsFeet)) return true;
					}
				}
			}
		}
		
		return false;
	}
	
	/**
	 * récupère une liste de points de contacts à droite
	 * @return	liste de coordonnées, delta de position x y du sprite
	 */
	function getHitRight() : Array<Point> { return null; }
	
	/**
	 * récupère une liste de points de contacts à gauche
	 * @return	liste de coordonnées, delta de position x y du sprite
	 */
	function getHitLeft() : Array<Point> { return null; }
	
	/**
	 * récupère une liste de points de contacts de la tête
	 * @return	liste de coordonnées, delta de position x y du sprite
	 */
	function getHitHead() : Array<Point> { return null; }
	
	/**
	 * récupère une liste de points de contacts des pieds
	 * @return	liste de coordonnées, delta de position x y du sprite
	 */
	function getHitFeet() : Array<Point> { return null; }
	
	/**
	 * temporisation de chute d'une plateforme
	 * @return	true si chute, false sinon
	 */
	function doTempoFeet() : Bool {
		if ( ! testBounce( getHitFeet(), true, 0, CANNE)){
			if ( tempoFeet-- <= 0){
				tempoFeet = TEMPO_FEET;
				
				return true;
			}else{
				y += FALL_TEMPO_FEET;
				
				return false;
			}
		}
		
		return false;
	}
	
	/**
	 * filtre de test de collision avec les pieds
	 * @param	pSp	sprite testé
	 * @return	true si le test est effectué, false si collisions ignorées
	 */
	function filterFeet( pSp : MySprite) : Bool { return true; }
	
	/**
	 * résolution de collision depuis la tête
	 */
	function doBounceHead() : Void {
		var lPts	: Array<Point>	= getHitHead();
		var lCtr	: Int			= B_MAX;
		
		if ( vY < 0) vY = 0;
		
		do{
			y	+= CANNE;
		}while ( lCtr-- > 0 && testBounce( lPts, false));
	}
	
	/**
	 * résolution de collision depuis les pieds
	 */
	function doBounceFeet() : Void {
		var lPts	: Array<Point>	= getHitFeet();
		var lCtr	: Int			= B_MAX;
		
		if( testBounce( lPts, true, 0, 0, filterFeet)){
			if ( vY > 0) vY = 0;
			
			tempoFeet	= TEMPO_FEET;
			
			do{
				y	-= CANNE;
			}while ( lCtr-- > 0 && testBounce( lPts, true, 0, 0, filterFeet));
		}
	}
	
	/**
	 * résolution de collision depuis la droite
	 */
	function doBounceRight() : Void {
		var lPts	: Array<Point>	= getHitRight();
		var lCtr	: Int			= B_MAX;
		
		if ( vX > 0) vX = 0;
		
		do{
			x	-= CANNE;
		}while ( lCtr-- > 0 && testBounce( lPts, false));
	}
	
	/**
	 * résolution de collision depuis la gauche
	 */
	function doBounceLeft() : Void {
		var lPts	: Array<Point>	= getHitLeft();
		var lCtr	: Int			= B_MAX;
		
		if ( vX < 0) vX = 0;
		
		do{
			x	+= CANNE;
		}while ( lCtr-- > 0 && testBounce( lPts, false));
	}
}