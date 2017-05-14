package vega.effect.wavegrid;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.flump.Movie;
import vega.assets.AssetInstance;

/**
 * une case de grille de vagues
 * 
 * @author nico
 */
class MyWaveCell {
	/** asset de case de vague avec 4 carrés des coins "tl", "tr", "br", "bl" */
	var asset					: AssetInstance;
	/** la surface pilotée par la case en mouvement de vague */
	var surface					: Container;
	
	/** rayon max de vague */
	var rayMax					: Float;
	/** côté de motif */
	var side					: Float;
	
	/** construction */
	public function new() { }
	
	/**
	 * initialisation
	 * @param	pAsset		instance d'asset de case de vague avec 4 carrés des coins "tl", "tr", "br", "bl"
	 * @param	pSurface	surface pilotée par la case en mouvement de vague
	 * @param	pSize		côté du motif
	 * @param	pRay		rayon max de vague
	 * @param	pVect		vecteur de vague initiale
	 */
	public function init( pAsset : AssetInstance, pSurface : Container, pSize : Float, pRay : Float, pVect : Point) : Void {
		asset	= pAsset;
		surface	= pSurface;
		side	= pSize;
		rayMax	= pRay;
		
		updateWave( pVect);
	}
	
	/** destruction */
	public function destroy() : Void {
		asset.parent.removeChild( asset);
		asset.free();
		asset = null;
		
		surface.parent.removeChild( surface);
		surface.destroy();
		surface = null;
	}
	
	/**
	 * itération de frame
	 * @param	pDT		delta t en ms
	 * @param	pVect	vecteur de vague à rendre
	 */
	public function doFrame( pDT : Float, pVect : Point) : Void {
		updateWave( pVect);
	}
	
	/**
	 * on récupère l'abscisse de case
	 * @return	abscisse de case
	 */
	public function getX() : Float { return asset.x; }
	
	/**
	 * on récupère l'abscisse de case
	 * @return	abscisse de case
	 */
	public function getY() : Float { return asset.y; }
	
	/**
	 * on récupère la surface
	 * @return	surface conteneur
	 */
	public function getSurface() : Container { return surface; }
	
	/**
	 * on met à jour le rendu de vague à partir d'un vecteur vague
	 * @param	pVect	vecteur vague
	 */
	function updateWave( pVect : Point) : Void {
		var lD2		: Float			= pVect.x * pVect.x + pVect.y * pVect.y;
		var lRatio	: Float			= rayMax / ( side / 2);
		var lMc		: Movie	= cast asset.getContent();
		var lDisp	: DisplayObject;
		var lSX		: Float;
		var lSY		: Float;
		
		if ( lD2 > 1){
			lD2		= Math.sqrt( lD2);
			
			pVect.x	/= lD2;
			pVect.y	/= lD2;
		}
		
		lSX				= lRatio * pVect.x;
		lSY				= lRatio * pVect.y;
		
		surface.x		= getX() + pVect.x * rayMax;
		surface.y		= getY() + pVect.y * rayMax;
		
		lDisp			= lMc.getLayer( "tl").getChildAt( 0);
		lDisp.scale.x	= 1 + lSX;
		lDisp.scale.y	= 1 + lSY;
		
		lDisp			= lMc.getLayer( "tr").getChildAt( 0);
		lDisp.scale.x	= 1 - lSX;
		lDisp.scale.y	= 1 + lSY;
		
		lDisp			= lMc.getLayer( "br").getChildAt( 0);
		lDisp.scale.x	= 1 - lSX;
		lDisp.scale.y	= 1 - lSY;
		
		lDisp			= lMc.getLayer( "bl").getChildAt( 0);
		lDisp.scale.x	= 1 + lSX;
		lDisp.scale.y	= 1 - lSY;
	}
}