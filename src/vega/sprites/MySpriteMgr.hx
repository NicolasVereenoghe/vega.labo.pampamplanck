package vega.sprites;
import pixi.core.display.Container;
import pixi.core.math.Point;
import vega.camera.MyCamera;
import vega.shell.IGameMgr;
import vega.utils.PointIJ;
import vega.utils.RectangleIJ;

/**
 * ...
 * @author nico
 */
class MySpriteMgr {
	var container								: Container;
	
	var grounds									: Map<String,GroundMgr>;
	
	/** map de tous les sprites indexés par noms d'instance */
	var sprites									: Array<MySprite>;
	/** map des sprites avec itération de frame indexés par noms d'instance */
	var spFrames								: Array<MySpFrame>;
	
	var _gMgr									: IGameMgr;
	
	var _camera									: MyCamera;
	
	/** compteur de temps écoulé en itérations de frames, en ms */
	var _ctrTime								: Float							= 0;
	/** ccompteur d'itéartions effectuées */
	var _ctrFrame								: Int							= 0;
	
	var _lvlId									: String;
	
	public function new( pLvlId : String = null) {
		if ( pLvlId != null && pLvlId != "") _lvlId = pLvlId;
	}
	
	public function getLvlId() : String { return _lvlId; }
	public function getCamera() : MyCamera { return _camera; }
	public function getGMgr() : IGameMgr { return _gMgr; }
	
	public function init( pCont : Container, pGMgr : IGameMgr, pCamera : MyCamera) : Void {
		container	= pCont;
		_gMgr		= pGMgr;
		_camera		= pCamera;
		sprites		= new Array<MySprite>();
		spFrames	= new Array<MySpFrame>();
		grounds		= new Map<String,GroundMgr>();
		
		initGrounds();
		
		initContainers();
	}
	
	public function setInitView() : Void {
		var lGround	: GroundMgr;
		
		container.x			= _camera.getX();
		container.y			= _camera.getY();
		
		for( lGround in grounds) lGround.setInitView();
	}
	
	public function destroy() : Void {
		var lSps	: Array<MySprite>;
		var lSp		: MySprite;
		
		freeGrounds();
		
		lSps = sprites.copy();
		for ( lSp in lSps) remSpriteDisplay( lSp);
		
		freeContainers();
		
		spFrames = null;
		grounds = null;
		sprites = null;
		container = null;
		_camera = null;
		_gMgr = null;
	}
	
	public function getGround( pId : String) : GroundMgr { return grounds[ pId]; }
	
	/**
	 * on retourne la liste de sprites que l'on retrouve à une coordonnée dans un certain plan d'affichage
	 * @param	pGroundId		identifiant de plan de level où rechercher les sprites
	 * @param	pX				abscisse de recherche dans le plan
	 * @param	pY				ordonnée de recherche dans le plan
	 * @return	liste de sprites trouvés
	 */
	public function getSpritesAt( pGroundId : String, pX : Float, pY : Float) : Array<MySprite> {
		var lGround	: GroundMgr				= getGround( pGroundId);
		var lLvlG	: LvlGroundMgr			= lGround.getLvlGround();
		var lIMod	: Int					= lLvlG.x2ModI( pX);
		var lJMod	: Int					= lLvlG.y2ModJ( pY);
		var lIJ		: PointIJ				= new PointIJ( lLvlG.x2i( pX), lLvlG.y2j( pY));
		var lCells	: Map<String,MyCell>	= lLvlG.getCellsAt( lIMod, lJMod);
		var lSps	: Array<MySprite>		= [];
		var lCell	: MyCell;
		
		if ( lCells != null) for ( lCell in lCells) Reflect.callMethod( lSps, lSps.push, lGround.getSpriteCell( lCell, lIJ));
		//if( lCells != null) for ( lCell in lCells) lSps = lSps.concat( lGround.getSpriteCell( lCell, lIJ));
		
		return lSps;
	}
	
	/**
	 * on ajoute un sprite au level en lui créant une cellule de description dans un plan de level
	 * @param	pGroundId		identifiant de plan de level où ajouter le nouveau sprite
	 * @param	pDepth			profondeur du sprite
	 * @param	pX				abscisse du sprite
	 * @param	pY				ordonnée du sprite
	 * @param	pCellOffset		rectangle d'offsets d'indices du sprite
	 * @param	pSpID			identifiant de sprite ; laisser null si non défini, /!\ on doit du coup forcément définir la classe
	 * @param	pSpClass		sous-classe de MySprite qui gère ce sprite ; laisser null pour aller chercher la classe dans le descripteur d'asset désigné par pSpID
	 * @param	pInstanceID		identifiant d'instance de sprite ; null pour avoir un nom automatique
	 * @param	pScale			composantes x y du scale à appliquer au sprite, null si aucun
	 * @param	pForceDisplay	true pour forcer l'affichage du sprite sans test de clipping ; false pour afficher uniquement si test de clipping ok
	 * @param	pRot			orientation en rad
	 * @return	la cellule de sprite créée
	 */
	public function addSpriteCell( pGroundId : String, pDepth : Float, pX : Float, pY : Float, pCellOffset : RectangleIJ, pSpID : String = null, pSpClass : Class<MySprite> = null, pInstanceID : String = null, pScale : Point = null, pForceDisplay : Bool = false, pRot : Float = 0) : MyCell {
		return grounds[ pGroundId].addSpriteCell( pDepth, pX, pY, pCellOffset, pSpID, pSpClass, pInstanceID, pScale, pForceDisplay, pRot);
	}
	
	public function remSpriteCell( pDesc : MyCell) : Void {
		grounds[ pDesc.getLvlGroundMgr().getId()].remSpriteCell( pDesc);
	}
	
	public function getSpriteCell( pDesc : MyCell, pIJ : PointIJ = null) : Array<MySprite> {
		return grounds[ pDesc.getLvlGroundMgr().getId()].getSpriteCell( pDesc, pIJ);
	}
	
	/**
	 * on vérifie si une cellule de plan est dans la zone d'affichage
	 * @param	pCell	cellule d'un plan du manager
	 * @return	true si dans l'affichage, false sinon
	 */
	public function isCellInClip( pCell : MyCell) : Bool {
		return grounds[ pCell.getLvlGroundMgr().getId()].isCellInClip( pCell);
	}
	
	/**
	 * on enregistre un sprite à l'itération de frame
	 * @param	pSp	sprite itéré à la frame
	 */
	public function regSpFrame( pSp : MySpFrame) : Void { spFrames.push( pSp); }
	
	/**
	 * on retire un sprite de l'itération de frame
	 * @param	pSp	sprite itéré à la frame
	 */
	public function remSpFrame( pSp : MySpFrame) : Void { spFrames.remove( pSp); }
	
	public function addSpriteDisplay( pSp : MySprite, pX : Float, pY : Float, pID : String = null, pDesc : MyCell = null) : Void {
		if ( pDesc != null && pDesc.getLvlGroundMgr() != null) {
			grounds[ pDesc.getLvlGroundMgr().getId()].addSpriteDisplay( pSp, pX, pY, pID, pDesc);
		}
		
		sprites.push( pSp);
	}
	
	public function remSpriteDisplay( pSp : MySprite) : Void {
		sprites.remove( pSp);
		
		if ( pSp.getDesc() != null && pSp.getDesc().getLvlGroundMgr() != null) {
			grounds[ pSp.getDesc().getLvlGroundMgr().getId()].remSpriteDisplay( pSp);
		}
	}
	
	/**
	 * on récupère le compteur de temps passé
	 * @return	temps passé en ms
	 */
	public function getCtrTime() : Float { return _ctrTime; }
	
	/**
	 * on récupère le nombre d'itérations écoulées
	 * @return	itérations écoulées
	 */
	public function getCtrFrame() : Int { return _ctrFrame; }
	
	/**
	 * on bascule la pause pour notifier tous les sprites
	 * @param	pIsPause	true pour mettre en pause, false pour reprendre la lecture
	 */
	public function switchPause( pIsPause : Bool) : Void {
		var lSp	: MySprite;
		
		for ( lSp in sprites) lSp.switchPause( pIsPause);
	}
	
	/**
	 * on effectue l'itération de frame : déplacement d'affichage suivant la caméra et forward d'itération de frame aux sprites du gestionnaire
	 * @param	pDT	delta t en ms
	 */
	public function doFrame( pDT : Float) : Void {
		var lSps	: Array<MySpFrame>;
		var lSp		: MySpFrame;
		
		_ctrTime += pDT;
		_ctrFrame++;
		
		slideToCamera();
		
		lSps = spFrames.copy();
		for ( lSp in lSps) lSp.doFrame( pDT);
	}
	
	/**
	 * on déplace le conteneur de sprite pour suivre la caméra, et on forward le suivi de caméra aux plans de sprites pour le clipping
	 */
	function slideToCamera() : Void {
		var lG	: GroundMgr;
		
		container.x	= _camera.getX();
		container.y	= _camera.getY();
		
		for ( lG in grounds) lG.slideToCamera();
	}
	
	function freeGrounds() : Void {
		var lG	: GroundMgr;
		
		for ( lG in grounds) lG.destroy();
	}
	
	/**
	 * on construit et initialise tous les plans d'affichage qui constituent ce gestionnaire de sprite du level ::_lvlId
	 */
	function initGrounds() : Void {
		var lI			: Int			= 0;
		var lLvlGround	: LvlGroundMgr;
		
		if ( LvlMgr.getInstance().exists( _lvlId)){
			lLvlGround = LvlMgr.getInstance().getLvlGroundMgr( 0, _lvlId);
			while ( lLvlGround != null) {
				grounds[ lLvlGround.getId()] = addGround( lI, lLvlGround);
				
				lLvlGround = LvlMgr.getInstance().getLvlGroundMgr( ++lI, _lvlId);
			}
		}
	}
	
	/**
	 * on instancie un gestionnaire de plan d'affichage, et ajoute au conteneur d'affichage (::container) le conteneur de ce plan
	 * appelé par ordre de profondeur des plans qui constituent ce gestionnaire de sprites (de derrière à devant)
	 * @param	pI			indice de profondeur du plan d'affichage ( 0 .. n-1)
	 * @param	pLvlGround	gestionnaire de matrice de données du plan d'affichage
	 * @return	instance de plan d'affichage créée
	 */
	function addGround( pI : Int, pLvlGround : LvlGroundMgr) : GroundMgr {
		var lCont	: Container	= cast container.addChild( new Container());
		
		return new GroundMgr( lCont, pLvlGround, this);
	}
	
	function freeContainers() : Void { }
	
	function initContainers() : Void { }
}