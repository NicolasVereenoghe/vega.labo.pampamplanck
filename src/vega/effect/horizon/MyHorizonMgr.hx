package vega.effect.horizon;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.flump.Movie;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;

/**
 * affichage d'effet de point de fuite avec focale et écran centrée à l'origine (0,0), d'un hozizon nuageux
 * 
 * @author nico
 */
class MyHorizonMgr {
	/** hauteur du centre de l'écran par rapport au plan des nuages */
	var HEIGHT							: Float								= 10000;
	/** distance point focale */
	var FOCAL							: Float								= 300;
	
	/** valeur absolue de décalage en x de focale lors d'un bump à taux plein */
	var BUMP_X							: Float								= 200;
	/** valeur absolue de décalage en y de focale lors d'un bump à taux plein */
	var BUMP_Y							: Float								= 75;
	
	/** valeur d'écart de point de fuite du dernier bump en x */
	var bumpX							: Float								= 0;
	/** valeur d'écart de point de fuite du dernier bump en y */
	var bumpY							: Float								= 0;
	
	/** abscisse initiale du bg */
	var bgX								: Float;
	/** ordonnée initiale du bg */
	var bgY								: Float;
	
	/** angle de focale avec le point de fuite */
	var aFocal							: Float;
	/** hauteur du point focale par rapport au plan des nuages */
	var fHeight							: Float;
	
	/** distance virtuelle entre 2 lignes de motif dans la profondeur */
	var dLine							: Float;
	
	/** instance de conteneur Flump conteneur de la mise en scène d'horizon */
	var model							: Movie;
	
	/** largeur de motif */
	var motifWidth						: Float;
	
	/** identifiant d'asset de motif 1 de nuage */
	var motif1Id						: String;
	
	/** identifiant d'asset de motif 2 de nuage */
	var motif2Id						: String;
	
	/** ordonnée de point de fuite projeté sur le plan écran */
	var _vanishY						: Float;
	/** ordonnée de ligne d'écran où le motif de nuage a un scale de 1 */
	var _baseY							: Float;
	/** ordonnée extrême de ligne d'écran avant */
	var _frontY							: Float;
	/** distance projetée sur plan nuages de cette ligne de scale 1, par rapport à la focale */
	var baseProj						: Float;
	/** scale de la ligne scale 1 d'écran, projeté sur les nuages */
	var baseProjScale					: Float;
	
	/** distance projetée sur plan nuages min à représenter */
	var projMin							: Float;
	/** distance projetée sur plan nuages max à représenter */
	var projMax							: Float;
	
	/** pile de lignes de nuages utilisées pour former notre horizon ; du fond (0) vers l'avant (n-1) */
	var cloudLines						: Array<MyCloudLine>;
	
	/** distance parcourue par la ligne de fond ; distance modulée par la distance entre 2 lignes ; [ 0 .. dLine [ */
	var curDist							: Float;
	/** indice de ligne de fond ; modulé par la période d'animation de motif ; [ 0 .. animPeriod [ */
	var curLineI						: Int;
	/** nombre de cycles de motif par période d'animation (1 .. n) */
	var cyclePerPeriod					: Int;
	/** nombre de lignes à passer pour faire réaliser une période d'animation de motif (1 .. n) */
	var animPeriod						: Int;
	
	/** construction */
	public function new() { }
	
	/**
	 * initialisation de l'horizon à partir d'une instance modèle qu'on va piloter
	 * @param	pModel			conteneur Flump servant d'instance modèle
	 * @param	pCyclePerPeriod	nombre de cycles de motif par période (1 .. n)
	 * @param	nombre de lignes à passer pour faire réaliser une période d'animation de motif (1 .. n)
	 */
	public function initFromFlump( pModel : Movie, pCyclePerPeriod : Int, pAnimPeriod : Int) : Void {
		var lTmp	: DisplayObject;
		var lRect	: Rectangle;
		
		model			= pModel;
		cyclePerPeriod	= pCyclePerPeriod;
		animPeriod		= pAnimPeriod;
		
		lTmp			= getBG();
		bgX				= UtilsFlump.getLayerX( cast lTmp);
		bgY				= UtilsFlump.getLayerY( cast lTmp);
		
		lTmp			= model.getLayer( "motif1");
		lTmp.visible	= false;
		motif1Id		= UtilsFlump.getSymbolId( cast( lTmp, Container).getChildAt( 0));
		
		lTmp			= model.getLayer( "motif2");
		lTmp.visible	= false;
		motif2Id		= UtilsFlump.getSymbolId( cast( lTmp, Container).getChildAt( 0));
		
		lTmp			= model.getLayer( "vanish");
		lTmp.visible	= false;
		_vanishY		= lTmp.y;
		
		// calcul d'init des propriétés découlant de la focale
		aFocal			= Math.atan( -_vanishY / FOCAL);
		fHeight			= FOCAL * Math.sin( aFocal) + HEIGHT;
		
		// calcul du segment de plan de nuages rendu
		lTmp			= model.getLayer( "ratio");
		lTmp.visible	= false;
		lRect			= UtilsPixi.getParentBounds( cast lTmp);
		_frontY			= HEIGHT > 0 ? lRect.y + lRect.height : lRect.y;
		projMin			= getGroundDistFromScreen( _frontY);
		projMax			= getGroundDistFromScreen( HEIGHT > 0 ? lRect.y : lRect.y + lRect.height);
		
		// calcul de paramètres du nuage (largeur / espacement / distance nuage repère / scale nuage repère)
		lTmp			= model.getLayer( "sizer");
		lTmp.visible	= false;
		lRect			= UtilsPixi.getParentBounds( cast lTmp);
		motifWidth		= lRect.width;
		_baseY			= HEIGHT > 0 ? lRect.y + lRect.height : lRect.y;
		baseProj		= getGroundDistFromScreen( _baseY);
		dLine			= Math.abs( getGroundDistFromScreen( HEIGHT > 0 ? lRect.y : lRect.y + lRect.height) - baseProj);
		baseProjScale	= Math.sqrt( fHeight * fHeight + baseProj * baseProj) / Math.sqrt( FOCAL * FOCAL + _baseY * _baseY);
		
		setInitView();
	}
	
	/** destruction */
	public function destroy() : Void {
		var lI	: Int;
		
		lI = 0;
		while ( lI < cloudLines.length){
			model.removeChild( cloudLines[ lI]);
			cloudLines[ lI].destroy();
			
			lI++;
		}
		cloudLines = null;
		
		model = null;
	}
	
	/**
	 * on récupère les coordonées du point de fuite en tenant compte du dernier bump
	 * @param	pXRate	taux d'influence du bump x sur le point de fuite
	 * @param	pYRate	taux d'influence du bump y sur le point de fuite
	 * @return coord de point de fuite dans repère d'horizon
	 */
	public function getVanish( pXRate : Float = 1, pYRate : Float = 1) : Point { return new Point( pXRate * bumpX, _vanishY + pYRate * bumpY); }
	
	/**
	 * on récupère la largeur du motif
	 * @return	largeur de motif
	 */
	public function getMotifW() : Float { return motifWidth; }
	
	/**
	 * on récupère l'id d'asset du motif 1
	 * @return	id d'asset
	 */
	public function getMotif1Id() : String { return motif1Id; }
	
	/**
	 * on récupère l'id d'asset du motif 2
	 * @return	id d'asset
	 */
	public function getMotif2Id() : String { return motif2Id; }
	
	/**
	 * on récupère la période du cycle d'anim
	 * @return	période, nb d'étapes de lignes pour faire une anim complète
	 */
	public function getPeriod() : Int { return animPeriod; }
	
	/**
	 * on récupère le nombre de cycles d'anim par période
	 * @return	nombre de cycle d'anims
	 */
	public function getNbCycle() : Int { return cyclePerPeriod; }
	
	/**
	 * on récupère le bump en x à taux plein
	 * @return	décalage en x de point focal à taux plein, valeur absolue
	 */
	public function getBUMP_X() : Float { return BUMP_X; }
	
	/**
	 * mise à jour de la vue, on fait avancer l'horizon
	 * @param	pRate	pourcentage d'écart entre 2 lignes parcouru
	 */
	public function updateView( pRate : Float) : Void {
		var lDDist	: Float			= pRate	* dLine;
		var lDStep	: Int			= Math.floor( ( curDist + lDDist) / dLine);
		var lI		: Int			= 0;
		var lLine	: MyCloudLine;
		var lY		: Float;
		var lDist	: Float;
		var lS		: Float;
		
		curDist		= ( ( ( curDist + lDDist) % dLine) + dLine) % dLine;
		curLineI	= ( ( ( curLineI + lDStep) % animPeriod) + animPeriod) % animPeriod;
		
		while ( lI < cloudLines.length){
			lLine			= cloudLines[ lI];
			lDist			= projMax - curDist - lI * dLine;
			lY				= getScreenYDistFromGroundDist( lDist);
			lLine.y			= lY;
			lLine.x			= 0;
			lS				= getScreenScale( lDist, lY);
			lLine.scale.x	= lS;
			lLine.scale.y	= lS;
			
			lLine.updateAnim( ( ( ( curLineI - lI) % animPeriod) + animPeriod) % animPeriod);
			
			lI++;
		}
		
		UtilsFlump.updateLayerInstanceRelativePos( getBG(), bgX, bgY);
		bumpX = 0;
		bumpY = 0;
	}
	
	/**
	 * on effectue un bump sur le rendu actuel : modifcation par courbure du point de fuite, bricolage pas optimisé mais efficace
	 * @param	pXRate	taux de bump en x (<0 vers la gauche, >0 vers la droite)
	 * @param	pYRate	taux de bump en y (<0 vers le haut, >0 vers le bas)
	 */
	public function bumpView( pXRate : Float, pYRate : Float) : Void {
		var lDFocal	: Float;
		var lLine	: MyCloudLine;
		
		if ( pXRate != 0){
			lDFocal = pXRate * BUMP_X;
			
			for ( lLine in cloudLines){
				lLine.x = curveBumpX( ( lLine.y - _frontY) / ( _vanishY - _frontY)) * lDFocal;
			}
			
			UtilsFlump.setLayerX( getBG(), bgX + lDFocal);
			bumpX = lDFocal;
		}
		
		if ( pYRate != 0){
			lDFocal = pYRate * BUMP_Y;
			
			for ( lLine in cloudLines){
				//lLine.y += ( ( _frontY + curveBumpY( ( lLine.y - _frontY) / ( _vanishY - _frontY)) * ( _vanishY + lDFocal - _frontY)) - lLine.y) * Math.abs( pYRate);;
				lLine.y	= _frontY + curveBumpY( ( lLine.y - _frontY) / ( _vanishY - _frontY), pYRate) * ( _vanishY + lDFocal - _frontY);
			}
			
			UtilsFlump.setLayerY( getBG(), bgY + lDFocal);
			bumpY = lDFocal;
		}
	}
	
	/**
	 * modification d'un taux de progression de 1 sur [ 0 .. 1] en une progression courbée pour incurver la fuite en y
	 * @param	pRate	taux de progression sur [ 0 .. 1]
	 * @param	pRatio	pourcentage de courbure dans le résultat final ; si < 0 courbure haute, si > 0 courbure basse
	 * @return	progression courbée
	 */
	function curveBumpY( pRate : Float, pRatio : Float) : Float {
		if ( pRatio > 0){
			return Math.pow( pRate, 1 / 1.3) * pRatio + pRate * ( 1 - pRatio);
		}else if ( pRatio < 0){
			return pRate * ( 1 + pRatio) - Math.pow( pRate, 1 / 1.3) * pRatio;
		}else return pRate;
	}
	
	/**
	 * modification d'un taux de progression de 1 sur [ 0 .. 1] en une progression courbée pour incurver la fuite en x
	 * @param	pRate	taux de progression sur [ 0 .. 1]
	 * @return	progression courbée
	 */
	function curveBumpX( pRate : Float) : Float { return pRate * pRate; }
	
	/**
	 * on construit la vue initiale
	 */
	function setInitView() : Void {
		var lNbLines	: Int			= Math.floor( ( projMax - projMin) / dLine) + 1;
		var lLine		: MyCloudLine;
		var lY			: Float;
		var lDist		: Float;
		var lS			: Float;
		
		curDist		= 0;
		
		cloudLines	= new Array<MyCloudLine>();
		curLineI	= ( lNbLines - 1) % animPeriod;
		
		while ( cloudLines.length < lNbLines) {
			lLine			= cast model.addChild( new MyCloudLine());
			lDist			= projMax - cloudLines.length * dLine;
			lY				= getScreenYDistFromGroundDist( lDist);
			lLine.y			= lY;
			lS				= getScreenScale( lDist, lY);
			lLine.scale.x	= lS;
			lLine.scale.y	= lS;
			
			lLine.init( this, ( ( ( curLineI - cloudLines.length) % animPeriod) + animPeriod) % animPeriod);
			
			cloudLines.push( lLine);
		}
	}
	
	/**
	 * on calcule la distance projetée sur plan des nuages par rapport au point focale, d'un item à partir de sa distance sur l'écran par rapport au centre
	 * @param	pScreenYDist	distance algébrique sur l'axe y par rapport au centre d'écran
	 * @return	distance algébrique sur le plan des nuages par rapport à la focale
	 */
	function getGroundDistFromScreen( pScreenYDist : Float) : Float {
		return fHeight * Math.tan( Math.PI / 2 - aFocal - Math.atan( pScreenYDist / FOCAL));
	}
	
	/**
	 * on calcule la distance au centre de l'écran, projetée sur l'écran, à partir d'une distance sur l'axe du plan des nuages
	 * @param	pGroundDist		distance sur le plan des nuages
	 * @return	distance algébrique sur l'écran, par rapport à son centre
	 */
	function getScreenYDistFromGroundDist( pGroundDist : Float) : Float {
		return FOCAL * Math.tan( Math.PI / 2 - aFocal - Math.atan( pGroundDist / fHeight));
	}
	
	/**
	 * on calcule le scale écran d'une ligne étant donnée sa distance sur le plan nuages et sa distance au centre de l'écran précalculée
	 * @param	pGroundDist		distance sur le plan des nuages
	 * @param	pScreenYDist	distance sur l'axe y par rapport au centre d'écran
	 * @return	scale écran
	 */
	function getScreenScale( pGroundDist : Float, pScreenYDist : Float) : Float {
		return baseProjScale * Math.sqrt( FOCAL * FOCAL + pScreenYDist * pScreenYDist) / Math.sqrt( fHeight * fHeight + pGroundDist * pGroundDist);
	}
	
	/**
	 * on récupère sur réf sur le layer de bg du modèle
	 * @return	instance de layer
	 */
	function getBG() : Container { return model.getLayer( "bg"); }
}