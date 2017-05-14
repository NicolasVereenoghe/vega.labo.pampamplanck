package vega.sprites;
import pixi.core.math.Point;
import vega.assets.AssetsMgr;
import vega.utils.RectangleIJ;

/**
 * ...
 * @author nico
 */
class MyCell {
	var _i									: Int;
	var _j									: Int;
	var _dx									: Float;
	var _dy									: Float;
	var _scale								: Point;
	var _rot								: Float;
	var _dHint								: Float;
	var _cellOffset							: RectangleIJ;
	var _instanceId							: String;
	var _spId								: String;
	var _spClass							: Class<MySprite>;
	var _lvlGroundMgr						: LvlGroundMgr;
	
	var _sprites							: Array<MySprite>;
	
	public function new( pI : Int, pJ : Int, pDX : Float, pDY : Float, pD : Float, pCellOffset : RectangleIJ, pLvlGroundMgr : LvlGroundMgr, pInstanceId : String = null, pSpId : String = null, pSpClass : Class<MySprite> = null, pScale : Point = null, pRot : Float = 0) {
		_i				= pI;
		_j				= pJ;
		_dx				= pDX;
		_dy				= pDY;
		_dHint			= pD;
		_cellOffset		= pCellOffset;
		_instanceId		= pInstanceId;
		_spId			= pSpId;
		_spClass		= pSpClass != null ? pSpClass : cast Type.resolveClass( AssetsMgr.instance.getAssetDescById( pSpId).getData( "class"));
		
		_lvlGroundMgr	= pLvlGroundMgr;
		_scale			= pScale;
		_rot			= pRot;
		
		_sprites		= new Array<MySprite>();
	}
	
	public function clone() : MyCell {
		var lDesc	: MyCell	= new MyCell(
			_i,
			_j,
			_dx,
			_dy,
			_dHint,
			_cellOffset.clone(),
			_lvlGroundMgr,
			_instanceId,
			_spId,
			_spClass,
			_scale.clone(),
			_rot
		);
		
		return lDesc;
	}
	
	public function instanciate() : MySprite {
		var lSp	: MySprite	= cast( Type.createInstance( _spClass, []), MySprite);
		
		if ( _scale != null) {
			lSp.scale.x	= _scale.x;
			lSp.scale.y	= _scale.y;
		}
		
		lSp.skew.x	= -_rot;
		lSp.skew.y	= _rot;
		
		_sprites.push( lSp);
		
		return lSp;
	}
	
	public function freeInstance( pSp : MySprite) : Void {
		_sprites.remove( pSp);
	}
	
	public function destroy() : Void {
		_cellOffset		= null;
		_spClass		= null;
		_lvlGroundMgr	= null;
		_scale			= null;
		
		_sprites		= null;
	}
	
	public function setI( pI : Int) : Void { _i = pI; }
	public function setJ( pJ : Int) : Void { _j = pJ; }
	public function setDx( pX : Float) : Void { _dx = pX; }
	public function setDy( pY : Float) : Void { _dy = pY; }
	
	public function getCellOffset() : RectangleIJ { return _cellOffset; }
	public function getI() : Int { return _i; }
	public function getJ() : Int { return _j; }
	public function getDx() : Float { return _dx; }
	public function getDy() : Float { return _dy; }
	public function getScale() : Point { return _scale; }
	public function getRot() : Float { return _rot; }
	public function getInstanceId() : String { return _instanceId; }
	public function getLvlGroundMgr() : LvlGroundMgr { return _lvlGroundMgr; }
	public function getDHint() : Float { return _dHint; }
	public function getSpId() : String { return _spId; }
	public function getSpClass() : Class<MySprite> { return _spClass; }
	public function getSprites() : Array<MySprite> { return _sprites; }
}