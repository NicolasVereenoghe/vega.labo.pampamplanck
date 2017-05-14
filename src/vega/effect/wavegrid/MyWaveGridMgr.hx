package vega.effect.wavegrid;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.flump.Movie;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.shell.ApplicationMatchSize;
import vega.utils.UtilsFlump;

/**
 * gestionnaire de grille de cases à effet de vague ; chaque case pilote une surface, soit un conteneur qui ondule comme la case
 * 
 * @author nico
 */
class MyWaveGridMgr {
	/** identifiant d'asset de case ; conteneur Flump avec layers "tl", "tr", "br", "bl" */
	var motifId						: String;
	/** côté de motif */
	var motifS						: Float;
	/** rayon max de déformatin du motif */
	var motifRay					: Float;
	
	/** instance de conteneur Flump conteneur de la mise en scène de grille */
	var model						: Movie;
	
	/** grille des gestionnaires de case */
	var cells						: Map<Int,Map<Int,MyWaveCell>>;
	
	/** pile de champs de vagues */
	var waves						: Array<MyWaveField>;
	
	/** zone de cases */
	var zoneGrid					: Container;
	/** zone de surfaces */
	var zoneSurface					: Container;
	
	/** construction */
	public function new() { }
	
	/**
	 * initialisation de grille à partir d'un conteneur Flump
	 * @param	pModel	conteneur Flump avec layers "sizer", "ray" et "motif" centré en plein milieu de l'écran
	 * @param	pFields	liste de champs de vagues initiaux, null si aucun
	 */
	public function initFromFlump( pModel : Movie, pFields : Array<MyWaveField> = null) : Void {
		var lTmp	: DisplayObject;
		
		if ( pFields != null) waves = pFields;
		else waves = new Array<MyWaveField>();
		
		model			= pModel;
		
		lTmp			= model.getLayer( "motif");
		lTmp.visible	= false;
		motifId			= UtilsFlump.getSymbolId( cast( lTmp, Container).getChildAt( 0));
		
		lTmp			= model.getLayer( "sizer");
		lTmp.visible	= false;
		motifS			= cast( lTmp, Container).width;
		
		lTmp			= model.getLayer( "ray");
		lTmp.visible	= false;
		motifRay		= cast( lTmp, Container).width / 2;
		
		setInitView();
	}
	
	/** desctruction */
	public function destroy() : Void {
		var lCol	: Map<Int,MyWaveCell>;
		var lCell	: MyWaveCell;
		var lWave	: MyWaveField;
		
		for ( lWave in waves) lWave.destroy();
		waves = null;
		
		for ( lCol in cells){
			for ( lCell in lCol){
				lCell.destroy();
			}
		}
		cells = null;
		
		model.removeChild( zoneGrid);
		zoneGrid = null;
		
		model.removeChild( zoneSurface);
		zoneSurface = null;
		
		model = null;
	}
	
	/**
	 * on récupère une surface à une coordonnée de grile
	 * @param	pX	abscisse de grille
	 * @param	pY	ordonnée de grille
	 * @return	surface conteneur ou null si hors grille
	 */
	public function getSurfaceAt( pX : Float, pY : Float) : Container {
		var lI	: Int	= Math.ceil( pX / motifS) - 1;
		var lJ	: Int	= Math.ceil( pY / motifS) - 1;
		
		if ( cells.exists( lI) && cells[ lI].exists( lJ)){
			return cells[ lI][ lJ].getSurface();
		}else return null;
	}
	
	
	/**
	 * on ajoute un champ de vagues
	 * @param	pField	champ de vague à ajouter
	 */
	public function addField( pField : MyWaveField) : Void { waves.push( pField); }
	
	/**
	 * itératin de frame
	 * @param	pDT		delta t en ms
	 */
	public function doFrame( pDT : Float) : Void {
		var lCol	: Map<Int,MyWaveCell>;
		var lCell	: MyWaveCell;
		var lWave	: MyWaveField;
		var lVect	: Point;
		var lX		: Float;
		var lY		: Float;
		var lI		: Int;
		
		lI = waves.length - 1;
		while ( lI >= 0){
			lWave = waves[ lI];
			
			if ( ! lWave.doFrame( pDT)){
				lWave.destroy();
				waves.remove( lWave);
			}
			
			lI--;
		}
		
		for ( lCol in cells){
			for ( lCell in lCol){
				lVect	= new Point();
				lX		= lCell.getX();
				lY		= lCell.getY();
				
				for ( lWave in waves){
					lWave.updateVectAt( lVect, lX, lY);
				}
				
				lCell.doFrame( pDT, lVect);
			}
		}
	}
	
	/**
	 * on construit la vue initiale
	 */
	function setInitView() : Void {
		var lRect	: Rectangle				= ApplicationMatchSize.instance.getScreenRectExt();
		var lI		: Int					= Math.floor( lRect.x / motifS);
		var lJMin	: Int					= Math.floor( lRect.y / motifS);
		var lIMax	: Int					= Math.ceil( ( lRect.x + lRect.width) / motifS);
		var lJMax	: Int					= Math.ceil( ( lRect.y + lRect.height) / motifS);
		var lJ		: Int;
		var lCol	: Map<Int,MyWaveCell>;
		var lCell	: MyWaveCell;
		var lAsset	: AssetInstance;
		var lCont	: Container;
		var lX		: Float;
		var lY		: Float;
		var lWave	: MyWaveField;
		var lVect	: Point;
		
		cells		= new Map<Int,Map<Int,MyWaveCell>>();
		
		zoneGrid	= cast model.addChild( new Container());
		zoneSurface	= cast model.addChild( new Container());
		
		while ( lI <= lIMax){
			lCol = new Map<Int,MyWaveCell>();
			cells.set( lI, lCol);
			
			lJ = lJMin;
			while ( lJ <= lJMax) {
				lCell = new MyWaveCell();
				lCol.set( lJ, lCell);
				
				lAsset		= cast zoneGrid.addChild( AssetsMgr.instance.getAssetInstance( motifId));
				lCont		= cast zoneSurface.addChild( new Container());
				lX			= ( lI + .5) * motifS;
				lY			= ( lJ + .5) * motifS;
				lAsset.x	= lX;
				lAsset.y	= lY;
				lCont.x		= lX;
				lCont.y		= lY;
				
				lVect = new Point();
				for ( lWave in waves){
					lWave.updateVectAt( lVect, lX, lY);
				}
				
				lCell.init( lAsset, lCont, motifS, motifRay, lVect);
				
				lJ++;
			}
			
			lI++;
		}
	}
}