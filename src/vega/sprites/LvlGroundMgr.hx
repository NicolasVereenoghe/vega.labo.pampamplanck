package vega.sprites;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import vega.utils.PointIJ;
import vega.utils.RectangleIJ;
import vega.utils.Utils;

/**
 * ...
 * @author nico
 */
class LvlGroundMgr {
	var CELL_MAX_SIZE				: Float									= 100;
	var CELL_MIN_SIZE				: Float									= 50;
	
	var _CELLS_PER_W				: Int									= -1;
	var _CELLS_PER_H				: Int									= -1;
	
	var _COEF_PARALLAXE				: Float									= 1;
	
	/** pile de clones de cellule de la map en cours (TODO) */
	var restoreCells				: Array<MyCell>;
	
	/** map de cellules en cours : [ <i modulo: int>][ <j modulo: int>][ <racine id instance: String>] = MyCell */
	var cells						: Map<Int,Map<Int,Map<String,MyCell>>>;
	var ctrCells					: Int									= 0;
	
	var _CELL_W						: Float									= -1;
	var _CELL_H						: Float									= -1;
	
	var GROUND_W					: Float									= -1;
	var GROUND_H					: Float									= -1;
	
	var _id							: String;
	
	var _lvlId						: String;
	
	var _IS_CYCLE_GROUND			: Bool									= false;
	var _IS_DEPTH_GROUND			: Bool									= true;
	
	public function new( pId : String, pLvlId : String, pCoefPara : Float = 1, pCycleCadre : Rectangle = null, pIsDepthG : Bool = true, pForceRegularSize : Float = -1) {
		cells 			= new Map<Int,Map<Int,Map<String,MyCell>>>();
		restoreCells	= new Array<MyCell>();
		
		_COEF_PARALLAXE	= pCoefPara;
		
		_IS_DEPTH_GROUND = pIsDepthG;
		
		if ( pCycleCadre != null){
			_IS_CYCLE_GROUND = true;
			
			GROUND_W			= pCycleCadre.width;
			GROUND_H			= pCycleCadre.height;
			
			_CELLS_PER_W		= Math.floor( GROUND_W / Math.max( CELL_MAX_SIZE * _COEF_PARALLAXE, CELL_MIN_SIZE));
			_CELLS_PER_H		= Math.floor( GROUND_H / Math.max( CELL_MAX_SIZE * _COEF_PARALLAXE, CELL_MIN_SIZE));
			
			_CELL_W				= GROUND_W / _CELLS_PER_W;
			_CELL_H				= GROUND_H / _CELLS_PER_H;
		}else{
			GROUND_W			= GROUND_H = Math.POSITIVE_INFINITY;
			_CELLS_PER_W		= _CELLS_PER_H = Utils.INT_MAX;
			_CELL_W				= _CELL_H = pForceRegularSize > 0 ? pForceRegularSize : Math.max( CELL_MAX_SIZE * _COEF_PARALLAXE, CELL_MIN_SIZE);
		}
		
		_id				= pId;
		_lvlId			= pLvlId;
	}
	
	public function reset() : Void {
		var lMapI	: Map<Int,Map<String,MyCell>>;
		var lMapJ	: Map<String,MyCell>;
		var lCell	: MyCell;
		
		for ( lMapI in cells) {
			for ( lMapJ in lMapI) {
				for ( lCell in lMapJ) remCell( lCell);
			}
		}
		
		cells		= new Map<Int,Map<Int,Map<String,MyCell>>>();
		ctrCells	= 0;
		
		for ( lCell in restoreCells) addCell( lCell.clone());
	}
	
	public function getCellsAt( pModI : Int, pModJ : Int, pType : Class<MySprite> = null) : Map<String,MyCell> {
		var lRes 	: Map<String,MyCell>;
		var lRes2	: Map<String,MyCell>;
		var lCell	: MyCell;
		
		if ( cells[ pModI] == null) return null;
		else if ( cells[ pModI][ pModJ] == null) return null;
		
		lRes = cells[ pModI][ pModJ];
		
		if ( pType == null || lRes == null) return lRes;
		
		lRes2	= new Map<String,MyCell>();
		for ( lCell in lRes){
			if ( Utils.doesInherit( lCell.getSpClass(), pType)){
				lRes2[ lCell.getInstanceId()] = lCell;
			}
		}
		
		return lRes2;
	}
	
	public function createCell( pDepth : Float, pX : Float, pY : Float, pCellOffset : RectangleIJ, pSpID : String = null, pSpClass : Class<MySprite> = null, pInstanceID : String = null, pScale : Point = null, pIsSave : Bool = false, pRot : Float = 0) : MyCell {
		var lModX	: Float		= x2ModX( pX);
		var lModY	: Float		= y2ModY( pY);
		var lI		: Int		= x2i( lModX);
		var lJ		: Int		= y2j( lModY);
		var lCell	: MyCell	= new MyCell(
			lI,
			lJ,
			lModX - _CELL_W * lI,
			lModY - _CELL_H * lJ,
			pDepth,
			pCellOffset,
			this,
			pInstanceID != null ? pInstanceID : _id + ctrCells,
			pSpID,
			pSpClass,
			pScale,
			pRot
		);
		
		if ( pIsSave) restoreCells.push( lCell.clone());
		
		addCell( lCell);
		
		return lCell;
	}
	
	public function addCell( pCell : MyCell, pIsNew : Bool = true) : Void {
		var lOffset	: RectangleIJ	= pCell.getCellOffset();
		var lMaxI	: Int			= lOffset.getRight() + pCell.getI();
		var lMaxJ	: Int			= lOffset.getBottom() + pCell.getJ();
		var lModI	: Int;
		var lModJ	: Int;
		var lI		: Int;
		var lJ		: Int;
		
		if( pIsNew) ctrCells++;
		
		lI = lOffset.getLeft() + pCell.getI();
		while( lI <= lMaxI){
			lModI	= i2ModI( lI);
			
			if ( ! cells.exists( lModI)) cells[ lModI] = new Map<Int,Map<String,MyCell>>();
			
			lJ = lOffset.getTop() + pCell.getJ();
			while( lJ <= lMaxJ){
				lModJ	= j2ModJ( lJ);
				
				if ( ! cells[ lModI].exists( lModJ)) cells[ lModI][ lModJ] = new Map<String,MyCell>();
				
				cells[ lModI][ lModJ][ pCell.getInstanceId()] = pCell;
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	public function remCell( pCell : MyCell, pDestroy : Bool = true) : Void {
		var lOffset	: RectangleIJ	= pCell.getCellOffset();
		var lMaxI	: Int			= lOffset.getRight() + pCell.getI();
		var lMaxJ	: Int			= lOffset.getBottom() + pCell.getJ();
		var lModI	: Int;
		var lModJ	: Int;
		var lI		: Int;
		var lJ		: Int;
		
		lI = lOffset.getLeft() + pCell.getI();
		while ( lI <= lMaxI) {
			lModI	= i2ModI( lI);
			
			lJ = lOffset.getTop() + pCell.getJ();
			while ( lJ <= lMaxJ) {
				lModJ	= j2ModJ( lJ);
				
				cells[ lModI][ lModJ].remove( pCell.getInstanceId());
				
				lJ++;
			}
			
			lI++;
		}
		
		if( pDestroy) pCell.destroy();
	}
	
	/**
	 * on notifie qu'une cellule peut avoir changé de position, on effectue les mises à jour nécessaires au référencement dans le plan et le descripteur de cellule
	 * @param	pDesc	descripteur de cellule de sprite
	 * @param	pX		nouvelle abscisse de plan
	 * @param	pY		nouvelle ordonnée de plan
	 */
	public function updateCellXY( pDesc : MyCell, pX : Float, pY : Float) : Void {
		var lOldI	: Int		= pDesc.getI();
		var lOldJ	: Int		= pDesc.getJ();
		var lModX	: Float		= x2ModX( pX);
		var lModY	: Float		= y2ModY( pY);
		var lI		: Int		= x2i( lModX);
		var lJ		: Int		= y2j( lModY);
		
		if ( lOldI != lI || lOldJ != lJ){
			remCell( pDesc, false);
			
			pDesc.setI( lI);
			pDesc.setJ( lJ);
			
			addCell( pDesc, false);
		}
		
		pDesc.setDx( lModX - _CELL_W * lI);
		pDesc.setDy( lModY - _CELL_H * lJ);
	}
	
	public function getGroundOffset( pI : Int, pJ : Int) : PointIJ {
		if ( _IS_CYCLE_GROUND) return new PointIJ( Math.floor( pI / _CELLS_PER_W), Math.floor( pJ / _CELLS_PER_H));
		else return new PointIJ();
	}
	
	public function getCellGroundOffsetsFrom( pModI : Int, pModJ : Int, pCell : MyCell) : RectangleIJ {
		var lOffset	: RectangleIJ	= pCell.getCellOffset();
		var lLeft	: Int			= Math.ceil( ( pModI - ( pCell.getI() + lOffset.getRight())) / _CELLS_PER_W);
		var lTop	: Int			= Math.ceil( ( pModJ - ( pCell.getJ() + lOffset.getBottom())) / _CELLS_PER_H);
		var lRight	: Int			= Math.floor( ( pModI - ( pCell.getI() + lOffset.getLeft())) / _CELLS_PER_W);
		var lBot	: Int			= Math.floor( ( pModJ - ( pCell.getJ() + lOffset.getTop())) / _CELLS_PER_H);
		
		if ( lLeft > lRight || lTop > lBot) return null;
		else return new RectangleIJ( lLeft, lTop, lRight - lLeft, lBot - lTop);
	}
	
	public function getId() : String { return _id; }
	public function getLvlId() : String { return _lvlId; }
	public function getCELL_W() : Float { return _CELL_W; }
	public function getCELL_H() : Float { return _CELL_H; }
	public function getCELLS_PER_W() : Int { return _CELLS_PER_W; }
	public function getCELLS_PER_H() : Int { return _CELLS_PER_H; }
	public function getCOEF_PARALLAXE() : Float { return _COEF_PARALLAXE; }
	public function getIS_CYCLE_GROUND() : Bool { return _IS_CYCLE_GROUND; }
	public function getIS_DEPTH_GROUND() : Bool { return _IS_DEPTH_GROUND; }
	
	public function x2i( pX : Float) : Int { return Math.floor( pX / _CELL_W); }
	public function y2j( pY : Float) : Int { return Math.floor( pY / _CELL_H); }
	
	public function x2ModI( pX : Float) : Int {
		if ( _IS_CYCLE_GROUND) return i2ModI( x2i( pX));
		else return x2i( pX);
	}
	
	public function y2ModJ( pY : Float) : Int {
		if ( _IS_CYCLE_GROUND) return j2ModJ( y2j( pY));
		else return y2j( pY);
	}
	
	public function i2ModI( pI : Int) : Int {
		if ( _IS_CYCLE_GROUND) return ( ( pI % _CELLS_PER_W) + _CELLS_PER_W) % _CELLS_PER_W;
		else return pI;
	}
	
	public function j2ModJ( pJ : Int) : Int {
		if ( _IS_CYCLE_GROUND) return ( ( pJ % _CELLS_PER_H) + _CELLS_PER_H) % _CELLS_PER_H;
		else return pJ;
	}
	
	function x2ModX( pX : Float) : Float {
		if ( _IS_CYCLE_GROUND) return ( ( pX % ( GROUND_W)) + GROUND_W) % GROUND_W;
		else return pX;
	}
	
	function y2ModY( pY : Float) : Float {
		if ( _IS_CYCLE_GROUND) return ( ( pY % ( GROUND_H)) + GROUND_H) % GROUND_H;
		else return pY;
	}
}