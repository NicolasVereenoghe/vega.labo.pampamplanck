package vega.sprites;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.math.Point;
import vega.sprites.MyCell;
import vega.sprites.MySpriteMgr;
import vega.utils.PointIJ;
import haxe.extern.EitherType;

/**
 * sprite avec itération de frame
 * @author nico
 */
class MySpFrame extends MySprite {
	/** flag indiquant si le sprite est toujours interactif (true) ou pas (suite à un retrait programmé du jeu, au séquence animée non interactive) */
	var isInteractive						: Bool							= true;
	
	public function new() { super(); }
	
	/**
	 * méthode d"itération à la frame
	 * @param	pDT	dt en ms
	 */
	public function doFrame( pDT : Float) : Void {
		if ( isInteractive) seekInteraction();
		
		if ( isInteractive && _desc != null) _desc.getLvlGroundMgr().updateCellXY( _desc, x, y);
	}
	
	/** @inheritDoc */
	override public function init( pMgr : MySpriteMgr, pDesc : MyCell = null) : Void {
		super.init( pMgr, pDesc);
		
		regSpFrame();
	}
	
	/** @inheritDoc */
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		isInteractive = false;
		
		remSpFrame();
		
		super.destroy();
	}
	
	/**
	 * on recherche et résoud des interactions avec des voisins du plan
	 */
	function seekInteraction() : Void {
		seekEffect();
		
		if ( isInteractive) seekBounce();
	}
	
	/**
	 * on retourne le descripteur de plan où rechercher à résoudre les effets
	 * @return	descripteur de plan, null si non défini
	 */
	function getEffectLvlGround() : LvlGroundMgr {
		if ( _desc != null) return _desc.getLvlGroundMgr();
		else return null;
	}
	
	/**
	 * on retourne le descripteur de plan où rechercher à résoudre les collisions
	 * @return	descripteur de plan, null si non défini
	 */
	function getBounceLvlGround() : LvlGroundMgr {
		if ( _desc != null) return _desc.getLvlGroundMgr();
		else return null;
	}
	
	/**
	 * on recherche et résoud les effets avec les voisins du plan
	 */
	function seekEffect() : Void {
		var lLvl	: LvlGroundMgr			= getEffectLvlGround();
		var lXY		: Point					= getGrav();
		var lIJ		: PointIJ				= new PointIJ( lLvl.x2i( x), lLvl.y2j( y));
		var lCells	: Map<String,MyCell>	= lLvl.getCellsAt( lLvl.x2ModI( x), lLvl.y2ModJ( y));
		var lCell	: MyCell;
		var lSps	: Array<MySprite>;
		var lSp		: MySprite;
		
		if( lCells != null){
			for ( lCell in lCells) {
				lSps	= mgr.getSpriteCell( lCell, lIJ);
				
				for ( lSp in lSps){
					if ( lSp != this) onEffect( lSp, lXY);
					
					if ( ! isInteractive) return;
				}
			}
		}
	}
	
	/**
	 * on a trouvé ce sprite près du notre, on veut tester et résoudre les effets à partir de notre coordonnée de touche sur notre voisin
	 * @param	pSp	sprite voisin
	 * @param	pXY	notre coordonnée de test sur le voisin
	 * @return	true si interaction résolue, false sinon
	 */
	function onEffect( pSp : MySprite, pXY : Point) : Bool { return pSp.doEffect( this, pXY); }
	
	/**
	 * on récupère la coordonnée de jeu qui représente le centre de gravité du sprite
	 * @return	cenrte de gravité en coordonnée de jeu
	 */
	function getGrav() : Point { return new Point( x, y); }
	
	/**
	 * on recherche et résoud les collisions avec les voisins du plan
	 */
	function seekBounce() : Void { }
	
	/**
	 * on effectue l'enregistrement de framing
	 */
	function regSpFrame() : Void { mgr.regSpFrame( this); }
	
	/**
	 * on retire du framing
	 */
	function remSpFrame() : Void { mgr.remSpFrame( this); }
}