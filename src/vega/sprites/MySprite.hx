package vega.sprites;

import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.flump.Movie;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;
import haxe.extern.EitherType;

/**
 * ...
 * @author nico
 */
class MySprite extends Container {
	public static inline var LAYER_CLIP		: String				= "mcClip";
	public static inline var LAYER_HIT		: String				= "mcHit";
	
	var mgr									: MySpriteMgr;
	var _desc								: MyCell;
	
	var assetSp								: AssetInstance;
	
	public function new() {
		super();
	}
	
	/**
	 * initialisation ; on construit le rendu initial
	 * @param	pMgr	gestionnaire de sprite responsable de cette instance
	 * @param	pDesc	cellule descripteur de ce sprite
	 */
	public function init( pMgr : MySpriteMgr, pDesc : MyCell = null) : Void {
		mgr		= pMgr;
		_desc	= pDesc;
		
		initAssetSp();
	}
	
	/**
	 * destruction d'instance de sprite
	 */
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		freeAssetSp();
		
		if ( _desc != null) {
			_desc.freeInstance( this);
			_desc = null;
		}
		
		mgr = null;
		
		super.destroy();
	}
	
	/**
	 * on bascule la pause
	 * @param	true pour passer en pause, false pour reprendre lecture
	 */
	public function switchPause( pIsPause : Bool) : Void { }
	
	/**
	 * on vérifie si on peut cliper le sprite, et donc si il peut virer de l'affichage car hors écran
	 * @return	true si peut être clipé, false si verrouillé à l'affichage
	 */
	public function isClipable() : Bool { return true; }
	
	/**
	 * un autre sprite demande de résoudre un effet d'interaction
	 * @param	pSp		sprite à l'origine de la demande d'effet
	 * @param	pXY		coordonnées de scène de jeu du contact de l'interaction ; null si pas défini
	 * @return	true si l'effet est résolu, false si non résolu et pourrait faire l'objet d'autres appels à d'autres coordonnées pour voir si ça le résoud
	 */
	public function doEffect( pSp : MySprite, pXY : Point = null) : Bool { return true; }
	
	/**
	 * un autre sprite demande de tester une collision avec un point de contact
	 * @param	pSp		sprite qui demande le test
	 * @param	pXY		coordonnées de scène du point de contact du test
	 * @param	pIsFeet	true si point de contact de pied
	 * @return	true si collision, false sinon
	 */
	public function doBounce( pSp : MySprite, pXY : Point = null, pIsFeet : Bool = true) : Bool { return false; }
	
	public function getSpDHint( pGrndMgr : GroundMgr, pDHint : Float) : Float { return pDHint; }
	public function getDesc() : MyCell { return _desc; }
	public function getMgr() : MySpriteMgr { return mgr; }
	
	function initAssetSp() : Void {
		if ( _desc != null) assetSp = cast addChild( AssetsMgr.instance.getAssetInstance( _desc.getSpId()));
	}
	
	function freeAssetSp() : Void {
		if ( assetSp == null) return;
		
		if ( assetSp.parent != null) assetSp.parent.removeChild( assetSp);
		
		assetSp.free();
		assetSp = null;
	}
	
	/**
	 * récupère zone de hit dans repère du plan ; méthode utilitaire simpliste par défaut
	 * @deprecated	utilisé pour les murs / pf, mais suppose des collisions que sur un rectangle, trop limitant, pas générique
	 * @return		rectangle de hit
	 */
	function getHitRect() : Rectangle {
		var lCont	: Movie	= cast assetSp.getContent();
		var lTmp	: Container;
		var lRect	: Rectangle;
		
		if ( UtilsFlump.getLayerWithPrefixInMovie( MySprite.LAYER_HIT, lCont) != null){
			lRect = UtilsPixi.getParentBounds( lCont.getLayer( MySprite.LAYER_HIT));
		}else if ( UtilsFlump.getLayerWithPrefixInMovie( MySprite.LAYER_CLIP, lCont) != null){
			lRect = UtilsPixi.getParentBounds( lCont.getLayer( MySprite.LAYER_CLIP));
		}else{
			lRect = getBounds();
		}
		
		return UtilsPixi.getParentBounds( this, lRect);
	}
}