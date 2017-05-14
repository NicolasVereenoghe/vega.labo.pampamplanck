package vega.sprites;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import vega.display.DepthMgr;
import vega.utils.PointIJ;
import vega.utils.RectangleIJ;
import vega.utils.Utils;

/**
 * ...
 * @author nico
 */
class GroundMgr {
	var NB_CELLS_W									: Int												= -1;
	var NB_CELLS_H									: Int												= -1;
	
	var COEF_P										: Float;
	
	var container									: Container;
	
	var _lvlGround									: LvlGroundMgr;
	var spMgr										: MySpriteMgr;
	
	var depthMgr									: DepthMgr											= null;
	
	var sprites										: Map<String,MySprite>;
	
	var curI										: Int												= 0;
	var curJ										: Int												= 0;
	
	var clipRectIn									: Int -> Int -> Int -> Int -> Void;
	var clipRectOut									: Int -> Int -> Int -> Int -> RectangleIJ -> Void;
	
	public var addSpriteCell						: Float -> Float -> Float -> RectangleIJ -> String -> Class<MySprite> -> String -> Point -> Bool -> Float -> MyCell;
	public var remSpriteCell						: MyCell -> Void;
	
	public var getSpriteCell						: MyCell -> PointIJ -> Array<MySprite>;
	
	public function new( pContainer : Container, pLvlGround : LvlGroundMgr, pSpMgr : MySpriteMgr) {
		_lvlGround	= pLvlGround;
		spMgr		= pSpMgr;
		
		if ( _lvlGround.getIS_CYCLE_GROUND()){
			clipRectIn		= clipRectInCycle;
			clipRectOut		= clipRectOutCycle;
			
			addSpriteCell	= addSpriteCellCycle;
			remSpriteCell	= remSpriteCellCycle;
			
			getSpriteCell	= getSpriteCellCycle;
		}else {
			clipRectIn		= clipRectInRegular;
			clipRectOut		= clipRectOutRegular;
			
			addSpriteCell	= addSpriteCellRegular;
			remSpriteCell	= remSpriteCellRegular;
			
			getSpriteCell	= getSpriteCellRegular;
		}
		
		buildContainer( pContainer);
		
		COEF_P		= _lvlGround.getCOEF_PARALLAXE() - 1;
		
		sprites		= new Map<String,MySprite>();
		
		procNbCells();
	}
	
	public function destroy() : Void {
		var lSp	: MySprite;
		
		for ( lSp in sprites) remSpriteDisplay( lSp);
		sprites = null;
		
		freeContainer();
		
		_lvlGround.reset();
		
		_lvlGround	= null;
		spMgr		= null;
	}
	
	public function getLvlGround() : LvlGroundMgr { return _lvlGround; }
	
	public function getSprites() : Map<String,MySprite> { return sprites; }
	
	public function getContainer() : Container { return container; }
	
	public function addSpriteDisplay( pSp : MySprite, pX : Float, pY : Float, pID : String, pDesc : MyCell) : Void {
		pSp.x			= pX;
		pSp.y			= pY;
		pSp.name		= pID;
		
		sprites[ pID]	= pSp;
		
		addSpToContainer( pSp, pDesc.getDHint());
		
		pSp.init( spMgr, pDesc);
	}
	
	public function remSpriteDisplay( pSp : MySprite) : Void {
		remSpFromContainer( pSp);
		
		pSp.destroy();
		
		sprites.remove( pSp.name);
	}
	
	public function setInitView() : Void {
		var lClipR			: Rectangle	= spMgr.getCamera().getClipRect().clone();
		var lDX				: Float		= -spMgr.getCamera().getScreenMidX() * COEF_P;
		var lDY				: Float		= -spMgr.getCamera().getScreenMidY() * COEF_P;
		var lI				: Int;
		var lJ				: Int;
		
		lClipR.x		-= lDX;
		lClipR.y		-= lDY;
		
		container.x		= lDX;
		container.y		= lDY;
		
		curI			= _lvlGround.x2i( lClipR.x);
		curJ			= _lvlGround.y2j( lClipR.y);
		
		clipRectIn( curI, curJ, NB_CELLS_W, NB_CELLS_H);
	}
	
	/**
	 * on vérifie si une cellule est dans la zone d'affichage
	 * @param	pCell	cellule de sprite de ce plan d'affichage
	 * @return	true si cellule dans zone, false sinon
	 */
	public function isCellInClip( pCell : MyCell) : Bool {
		var lClipR			: Rectangle		= spMgr.getCamera().getClipRect().clone();
		var lDX				: Float			= -spMgr.getCamera().getScreenMidX() * COEF_P;
		var lDY				: Float			= -spMgr.getCamera().getScreenMidY() * COEF_P;
		var lINew			: Int			= _lvlGround.x2i( lClipR.x - lDX);
		var lJNew			: Int			= _lvlGround.y2j( lClipR.y - lDY);
		var lClipRIJ		: RectangleIJ	= new RectangleIJ( lINew, lJNew, NB_CELLS_W - 1, NB_CELLS_H - 1);
		var lCellClipRIJ	: RectangleIJ;
		var lOffsets		: RectangleIJ;
		var lOffset			: PointIJ;
		var lGroundOffset	: PointIJ;
		var lIO				: Int;
		var lJO				: Int;
		
		if ( _lvlGround.getIS_CYCLE_GROUND()){
			lOffsets		= _lvlGround.getCellGroundOffsetsFrom( pCell.getI(), pCell.getJ(), pCell);
			lGroundOffset	= _lvlGround.getGroundOffset( lINew, lJNew);
			
			lIO = lOffsets.getLeft();
			while ( lIO <= lOffsets.getRight()) {
				lJO = lOffsets.getTop();
				while ( lJO <= lOffsets.getBottom()) {
					lCellClipRIJ	= pCell.getCellOffset().clone();
					lOffset			= new PointIJ( lIO + lGroundOffset.i, lJO + lGroundOffset.j);
					
					lCellClipRIJ.offset( lOffset.i * _lvlGround.getCELLS_PER_W() + pCell.getI(), lOffset.j * _lvlGround.getCELLS_PER_H() + pCell.getJ());
					
					if ( ! ( lClipRIJ.getLeft() > lCellClipRIJ.getRight() || lClipRIJ.getRight() < lCellClipRIJ.getLeft() || lClipRIJ.getTop() > lCellClipRIJ.getBottom() || lClipRIJ.getBottom() < lCellClipRIJ.getTop())) return true;
					
					lJO++;
				}
				
				lIO++;
				
			}
			
			return false;
		}else{
			lCellClipRIJ = pCell.getCellOffset().clone();
			lCellClipRIJ.offset( pCell.getI(), pCell.getJ());
			
			return ! ( lClipRIJ.getLeft() > lCellClipRIJ.getRight() || lClipRIJ.getRight() < lCellClipRIJ.getLeft() || lClipRIJ.getTop() > lCellClipRIJ.getBottom() || lClipRIJ.getBottom() < lCellClipRIJ.getTop());
		}
	}
	
	/**
	 * on fait glisser le clipping vers la nouvelle position de caméra
	 */
	public function slideToCamera() : Void {
		var lClipR			: Rectangle		= spMgr.getCamera().getClipRect().clone();
		var lDX				: Float			= -spMgr.getCamera().getScreenMidX() * COEF_P;
		var lDY				: Float			= -spMgr.getCamera().getScreenMidY() * COEF_P;
		var lOldNbCellsW	: Int			= NB_CELLS_W;
		var lOldNbCellsH	: Int			= NB_CELLS_H;
		var lClipRIJ		: RectangleIJ;
		var lINew			: Int;
		var lJNew			: Int;
		var lDI				: Int;
		var lDJ				: Int;
		
		procNbCells();
		
		lClipR.x		-= lDX;
		lClipR.y		-= lDY;
		
		container.x		= lDX;
		container.y		= lDY;
		
		lINew			= _lvlGround.x2i( lClipR.x);
		lJNew			= _lvlGround.y2j( lClipR.y);
		lClipRIJ		= new RectangleIJ( lINew, lJNew, NB_CELLS_W - 1, NB_CELLS_H - 1);
		
		lDI = lINew - curI;
		if ( lDI > 0) {
			clipRectOut( curI, curJ, Utils.minInt(  lDI, lOldNbCellsW), lOldNbCellsH, lClipRIJ);
		}else if ( lDI < 0) {
			clipRectIn( lINew, lJNew, Utils.minInt( -lDI, NB_CELLS_W), NB_CELLS_H);
		}
		
		lDI = ( lINew + NB_CELLS_W) - ( curI + lOldNbCellsW);
		if ( lDI > 0){
			clipRectIn( Utils.maxInt( curI + lOldNbCellsW, lINew), lJNew, Utils.minInt( lDI, NB_CELLS_W), NB_CELLS_H);
		}else if ( lDI < 0){
			clipRectOut( Utils.maxInt( curI, lINew + NB_CELLS_W), curJ, Utils.minInt( -lDI, lOldNbCellsW), lOldNbCellsH, lClipRIJ);
		}
		
		if ( lINew < curI + lOldNbCellsW && curI < lINew + NB_CELLS_W){
			lDI = Utils.minInt( curI + lOldNbCellsW, lINew + NB_CELLS_W) - Utils.maxInt( curI, lINew);
			
			lDJ = lJNew - curJ;
			if ( lDJ > 0) {
				clipRectOut( Utils.maxInt( curI, lINew), curJ, lDI, Utils.minInt( lDJ, lOldNbCellsH), lClipRIJ);
			}else if ( lDJ < 0) {
				clipRectIn( Utils.maxInt( curI, lINew), lJNew, lDI, Utils.minInt( -lDJ, NB_CELLS_H));
			}
			
			lDJ = ( lJNew + NB_CELLS_H) - ( curJ + lOldNbCellsH);
			if ( lDJ > 0) {
				clipRectIn( Utils.maxInt( curI, lINew), Utils.maxInt( curJ + lOldNbCellsH, lJNew), lDI, Utils.minInt( lDJ, NB_CELLS_H));
			}else if ( lDJ < 0) {
				clipRectOut( Utils.maxInt( curI, lINew), Utils.maxInt( lJNew + NB_CELLS_H, curJ), lDI, Utils.minInt( -lDJ, lOldNbCellsH), lClipRIJ);
			}
		}
		
		curI			= lINew;
		curJ			= lJNew;
	}
	
	/**
	 * on effectue le calcul du gabarit des nombres de cellules nécessaires pour englober l'écran
	 */
	function procNbCells() : Void {
		NB_CELLS_W	= Math.floor( spMgr.getCamera().getSCREEN_W() / _lvlGround.getCELL_W()) + 2;
		NB_CELLS_H	= Math.floor( spMgr.getCamera().getSCREEN_H() / _lvlGround.getCELL_H()) + 2;
	}
	
	function buildContainer( pContainer : Container) : Void {
		container	= pContainer;
		
		if( _lvlGround.getIS_DEPTH_GROUND()) depthMgr = new DepthMgr( container);
	}
	
	function freeContainer() : Void {
		container.parent.removeChild( container);
		container.destroy();
		container = null;
		
		depthMgr = null;
	}
	
	public function addSpToContainer( pSp : MySprite, pDHint : Float) : Void {
		container.addChild( pSp);
		
		if( depthMgr != null) depthMgr.setDepth( pSp, pSp.getSpDHint( this, pDHint));
	}
	
	public function remSpFromContainer( pSp : MySprite) : Void {
		if( depthMgr != null) depthMgr.freeDepth( pSp);
		
		container.removeChild( pSp);
	}
	
	function getSpriteCellRegular( pDesc : MyCell, pIJ : PointIJ = null) : Array<MySprite> {
		if ( sprites.exists( pDesc.getInstanceId())) return [ sprites[ pDesc.getInstanceId()]];
		else return [];
	}
	
	function getSpriteCellCycle( pDesc : MyCell, pIJ : PointIJ = null) : Array<MySprite> {
		var lOffsets		: RectangleIJ		= _lvlGround.getCellGroundOffsetsFrom( _lvlGround.i2ModI( pIJ.i), _lvlGround.j2ModJ( pIJ.j), pDesc);
		var lGroundOffset	: PointIJ			= _lvlGround.getGroundOffset( pIJ.i, pIJ.j);
		var lRes			: Array<MySprite>	= new Array<MySprite>();
		var lI				: Int;
		var lJ				: Int;
		var lName			: String;
		
		lI = lOffsets.getLeft();
		while ( lI <= lOffsets.getRight()) {
			lJ = lOffsets.getTop();
			while ( lJ <= lOffsets.getBottom()) {
				lName	= getInstanceQualifiedGroundName( pDesc, lGroundOffset.add( new PointIJ( lI, lJ)));
				
				if ( sprites.exists( lName)) lRes.push( sprites[ lName]);
				
				lJ++;
			}
			
			lI++;
		}
		
		return lRes;
	}
	
	function addSpriteCellRegular( pDepth : Float, pX : Float, pY : Float, pCellOffset : RectangleIJ, pSpID : String = null, pSpClass : Class<MySprite> = null, pInstanceID : String = null, pScale : Point = null, pForceDisplay : Bool = false, pRot : Float = 0) : MyCell {
		var lCell			: MyCell		= _lvlGround.createCell( pDepth, pX, pY, pCellOffset, pSpID, pSpClass, pInstanceID, pScale, false, pRot);
		var lCellClipRIJ	: RectangleIJ	= lCell.getCellOffset().clone();
		var lClipRIJ		: RectangleIJ	= new RectangleIJ( curI, curJ, NB_CELLS_W - 1, NB_CELLS_H - 1);
		var lI				: Int			= _lvlGround.x2i( pX);
		var lJ				: Int			= _lvlGround.y2j( pY);
		
		lCellClipRIJ.offset( lI, lJ);
		
		if ( pForceDisplay || lClipRIJ.getLeft() <= lCellClipRIJ.getRight() && lClipRIJ.getRight() >= lCellClipRIJ.getLeft() && lClipRIJ.getTop() <= lCellClipRIJ.getBottom() && lClipRIJ.getBottom() >= lCellClipRIJ.getTop()) {
			spMgr.addSpriteDisplay(
				lCell.instanciate(),
				pX,
				pY,
				lCell.getInstanceId(),
				lCell
			);
		}
		
		return lCell;
	}
	
	function addSpriteCellCycle( pDepth : Float, pX : Float, pY : Float, pCellOffset : RectangleIJ, pSpID : String = null, pSpClass : Class<MySprite> = null, pInstanceID : String = null, pScale : Point = null, pForceDisplay : Bool = false, pRot : Float = 0) : MyCell {
		var lCell			: MyCell		= _lvlGround.createCell( pDepth, pX, pY, pCellOffset, pSpID, pSpClass, pInstanceID, pScale, false, pRot);
		var lOffsets		: RectangleIJ	= getCellCameraOffsets( lCell);
		var lGroundOffset	: PointIJ;
		var lOffset			: PointIJ;
		var lI				: Int;
		var lJ				: Int;
		
		if ( lOffsets != null) {
			lGroundOffset	= _lvlGround.getGroundOffset( curI, curJ);
			
			lI = lOffsets.getLeft();
			while ( lI <= lOffsets.getRight()) {
				lJ = lOffsets.getTop();
				while ( lJ <= lOffsets.getBottom()) {
					lOffset	= lGroundOffset.add( new PointIJ( lI, lJ));
					
					spMgr.addSpriteDisplay(
						lCell.instanciate(),
						( lOffset.i * _lvlGround.getCELLS_PER_W() + lCell.getI()) * _lvlGround.getCELL_W() + lCell.getDx(),
						( lOffset.j * _lvlGround.getCELLS_PER_H() + lCell.getJ()) * _lvlGround.getCELL_H() + lCell.getDy(),
						getInstanceQualifiedGroundName( lCell, lOffset),
						lCell
					);
					
					lJ++;
				}
				
				lI++;
			}
		}
		
		return lCell;
	}
	
	function remSpriteCellRegular( pDesc : MyCell) : Void {
		if ( sprites.exists( pDesc.getInstanceId())) spMgr.remSpriteDisplay( sprites[ pDesc.getInstanceId()]);
		
		_lvlGround.remCell( pDesc);
	}
	
	function remSpriteCellCycle( pDesc : MyCell) : Void {
		var lOffsets		: RectangleIJ		= getCellCameraOffsets( pDesc);
		var lGroundOffset	: PointIJ;
		var lI				: Int;
		var lJ				: Int;
		
		if ( lOffsets != null) {
			lGroundOffset	= _lvlGround.getGroundOffset( curI, curJ);
			
			lI = lOffsets.getLeft();
			while ( lI <= lOffsets.getRight()) {
				lJ = lOffsets.getTop();
				while ( lJ <= lOffsets.getBottom()) {
					spMgr.remSpriteDisplay( sprites[ getInstanceQualifiedGroundName( pDesc, lGroundOffset.add( new PointIJ( lI, lJ)))]);
					
					lJ++;
				}
				
				lI++;
			}
		}
		
		_lvlGround.remCell( pDesc);
	}
	
	function clipRectOutRegular( pI : Int, pJ : Int, pW : Int, pH : Int, pClipRIJ : RectangleIJ) : Void {
		var lDone			: Map<String,Bool>		= new Map<String,Bool>();
		var lIMax			: Int					= pI + pW;
		var lJMax			: Int					= pJ + pH;
		var lI				: Int					= pI;
		var lJ				: Int;
		var lDescs			: Map<String,MyCell>;
		var lDesc			: MyCell;
		var lCellClipRIJ	: RectangleIJ;
		var lSp				: MySprite;
		
		while ( lI < lIMax) {
			lJ = pJ;
			while ( lJ < lJMax) {
				lDescs	= _lvlGround.getCellsAt( lI, lJ);
				
				if( lDescs != null){
					for ( lDesc in lDescs) {
						if ( ! lDone.exists( lDesc.getInstanceId())) {
							lDone[ lDesc.getInstanceId()] = true;
							lSp = sprites[ lDesc.getInstanceId()];
							
							if ( lSp != null && lSp.isClipable()) {
								lCellClipRIJ	= lDesc.getCellOffset().clone();
								lCellClipRIJ.offset( lDesc.getI(), lDesc.getJ());
								
								if( pClipRIJ.getLeft() > lCellClipRIJ.getRight() || pClipRIJ.getRight() < lCellClipRIJ.getLeft() || pClipRIJ.getTop() > lCellClipRIJ.getBottom() || pClipRIJ.getBottom() < lCellClipRIJ.getTop()){
									spMgr.remSpriteDisplay( lSp);
								}
							}
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function clipRectOutCycle( pI : Int, pJ : Int, pW : Int, pH : Int, pClipRIJ : RectangleIJ) : Void {
		var lDone			: Map<String,Bool>		= new Map<String,Bool>();
		var lIMax			: Int					= pI + pW;
		var lJMax			: Int					= pJ + pH;
		var lI				: Int					= pI;
		var lJ				: Int;
		var lIMod			: Int;
		var lJMod			: Int;
		var lDescs			: Map<String,MyCell>;
		var lGroundOffset	: PointIJ;
		var lOffset			: PointIJ;
		var lDesc			: MyCell;
		var lName			: String;
		var lCellClipRIJ	: RectangleIJ;
		var lOffsets		: RectangleIJ;
		var lIO				: Int;
		var lJO				: Int;
		var lSp				: MySprite;
		
		while ( lI < lIMax) {
			lIMod	= _lvlGround.i2ModI( lI);
			
			lJ = pJ;
			while (  lJ < lJMax) {
				lJMod			= _lvlGround.j2ModJ( lJ);
				lDescs			= _lvlGround.getCellsAt( lIMod, lJMod);
				lGroundOffset	= _lvlGround.getGroundOffset( lI, lJ);
				
				if( lDescs != null){
					for ( lDesc in lDescs) {
						lOffsets	= _lvlGround.getCellGroundOffsetsFrom( lIMod, lJMod, lDesc);
						
						lIO = lOffsets.getLeft();
						while ( lIO <= lOffsets.getRight()) {
							lJO = lOffsets.getTop();
							while ( lJO <= lOffsets.getBottom()) {
								lOffset	= new PointIJ( lIO + lGroundOffset.i, lJO + lGroundOffset.j);
								lName	= getInstanceQualifiedGroundName( lDesc, lOffset);
								
								if ( ! lDone.exists( lName)) {
									lDone[ lName] = true;
									lSp = sprites[ lName];
									
									if ( lSp != null && lSp.isClipable()) {
										lCellClipRIJ	= lDesc.getCellOffset().clone();
										lCellClipRIJ.offset( lOffset.i * _lvlGround.getCELLS_PER_W() + lDesc.getI(), lOffset.j * _lvlGround.getCELLS_PER_H() + lDesc.getJ());
										
										if ( pClipRIJ.getLeft() > lCellClipRIJ.getRight() || pClipRIJ.getRight() < lCellClipRIJ.getLeft() || pClipRIJ.getTop() > lCellClipRIJ.getBottom() || pClipRIJ.getBottom() < lCellClipRIJ.getTop()) {
											spMgr.remSpriteDisplay( lSp);
										}
									}
								}
								
								lJO++;
							}
							
							lIO++;
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function clipRectInRegular( pI : Int, pJ : Int, pW : Int, pH : Int) : Void {
		var lIMax			: Int					= pI + pW;
		var lJMax			: Int					= pJ + pH;
		var lI				: Int					= pI;
		var lJ				: Int;
		var lDescs			: Map<String,MyCell>;
		var lDesc			: MyCell;
		
		while ( lI < lIMax) {
			lJ = pJ;
			while ( lJ < lJMax) {
				lDescs	= _lvlGround.getCellsAt( lI, lJ);
				
				if( lDescs != null){
					for ( lDesc in lDescs) {
						if ( ! sprites.exists( lDesc.getInstanceId())) {
							spMgr.addSpriteDisplay(
								lDesc.instanciate(),
								lDesc.getI() * _lvlGround.getCELL_W() + lDesc.getDx(),
								lDesc.getJ() * _lvlGround.getCELL_H() + lDesc.getDy(),
								lDesc.getInstanceId(),
								lDesc
							);
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function clipRectInCycle( pI : Int, pJ : Int, pW : Int, pH : Int) : Void {
		var lIMax			: Int			= pI + pW;
		var lJMax			: Int			= pJ + pH;
		var lI				: Int			= pI;
		var lJ				: Int;
		var lIMod			: Int;
		var lJMod			: Int;
		var lDescs			: Map<String,MyCell>;
		var lGroundOffset	: PointIJ;
		var lOffset			: PointIJ;
		var lDesc			: MyCell;
		var lName			: String;
		var lOffsets		: RectangleIJ;
		var lIO				: Int;
		var lJO				: Int;
		
		while ( lI < lIMax) {
			lIMod	= _lvlGround.i2ModI( lI);
			
			lJ = pJ;
			while ( lJ < lJMax) {
				lJMod			= _lvlGround.j2ModJ( lJ);
				lDescs			= _lvlGround.getCellsAt( lIMod, lJMod);
				lGroundOffset	= _lvlGround.getGroundOffset( lI, lJ);
				
				if( lDescs != null){
					for ( lDesc in lDescs) {
						lOffsets	= _lvlGround.getCellGroundOffsetsFrom( lIMod, lJMod, lDesc);
						
						lIO = lOffsets.getLeft();
						while ( lIO <= lOffsets.getRight()) {
							lJO = lOffsets.getTop();
							while ( lJO <= lOffsets.getBottom()) {
								lOffset	= new PointIJ( lIO + lGroundOffset.i, lJO + lGroundOffset.j);
								lName	= getInstanceQualifiedGroundName( lDesc, lOffset);
								
								if ( ! sprites.exists( lName)) {
									spMgr.addSpriteDisplay(
										lDesc.instanciate(),
										( lOffset.i * _lvlGround.getCELLS_PER_W() + lDesc.getI()) * _lvlGround.getCELL_W() + lDesc.getDx(),
										( lOffset.j * _lvlGround.getCELLS_PER_H() + lDesc.getJ()) * _lvlGround.getCELL_H() + lDesc.getDy(),
										lName,
										lDesc
									);
								}
								
								lJO++;
							}
							
							lIO++;
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function getCellCameraOffsets( pCell : MyCell) : RectangleIJ {
		var lOffset	: RectangleIJ	= pCell.getCellOffset();
		var lModI	: Int			= _lvlGround.i2ModI( curI);
		var lModJ	: Int			= _lvlGround.j2ModJ( curJ);
		var lLeft	: Int			= Math.ceil( ( lModI - ( pCell.getI() + lOffset.getRight())) / _lvlGround.getCELLS_PER_W());
		var lTop	: Int			= Math.ceil( ( lModJ - ( pCell.getJ() + lOffset.getBottom())) / _lvlGround.getCELLS_PER_H());
		var lRight	: Int			= Math.floor( ( _lvlGround.i2ModI( lModI + NB_CELLS_W - 1) - ( pCell.getI() + lOffset.getLeft())) / _lvlGround.getCELLS_PER_W()) + Math.floor( ( lModI + NB_CELLS_W - 1) / _lvlGround.getCELLS_PER_W());
		var lBot	: Int			= Math.floor( ( _lvlGround.j2ModJ( lModJ + NB_CELLS_H - 1) - ( pCell.getJ() + lOffset.getTop())) / _lvlGround.getCELLS_PER_H()) + Math.floor( ( lModJ + NB_CELLS_H - 1) / _lvlGround.getCELLS_PER_H());
		
		if ( lLeft > lRight || lTop > lBot) return null;
		else return new RectangleIJ( lLeft, lTop, lRight - lLeft, lBot - lTop);
	}
	
	function getInstanceQualifiedGroundName( pCell : MyCell, pGroundOffset : PointIJ) : String { return "_" + pGroundOffset.i + "_" + pGroundOffset.j + pCell.getInstanceId(); }
}