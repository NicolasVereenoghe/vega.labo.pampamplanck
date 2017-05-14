package bayam.game;
import bayam.shell.MyHUD;
import bayam.shell.MyShell;
import flump.library.Layer;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.flump.Movie;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.assets.PatternAsset;
import vega.loader.VegaLoader;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;
import vega.shell.SavedDatas;
import vega.shell.VegaDeactivator;
import vega.sound.SndDesc;
import vega.sound.SndMgr;
import vega.sound.SndPlayModeDelayed;
import vega.sound.SndPlayModeMax;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;

import pixi.core.display.Container;
import vega.shell.GameMgrAssets;
import vega.shell.IGameShell;

/**
 * ...
 * @author nico
 */
class MyGMgr extends GameMgrAssets {
	public static inline var LAYER_RECT_BOUNDS		: String								= "rect"; // TODO : /!\ : vérifier dépendances : sur quels objets l'avoir ?
	
	public static inline var LAYER_SPE_U			: String								= "specialU";
	public static inline var LAYER_BALLE			: String								= "fakeBalle";
	public static inline var LAYER_CRAP				: String								= "crapouille";
	
	public static inline var LAYER_BALANCE_RADIX	: String								= "balance";
	
	var ASSET_TABLEAU_RADIX							: String								= "Tableau";
	
	var LAYER_FIXE_RADIX							: String								= "fixe";
	var LAYER_SPE_RADIX								: String								= "special";
	var LAYER_MOBILE_RADIX							: String								= "mobile";
	
	var LAYER_SUP_SAM								: String								= "samSupport";
	
	var LAYER_SOL									: String								= "MCsol";
	
	var ID_TO_DUREE									: Dynamic								= {
		"1": 10,
		"2": 10,
		"3": 10,
		"4": 10,
		"5": 10,
		"6": 10,
		"7": 10,
		"8": 15,
		"9": 10,
		"10": 14,
		"11": 10,
		"12": 10,
		"13": 15,
		"14": 13,
		"15": 10,
		"16": 15, // /!\ : arbitraire car pas de données à partir d'ici !
		"17": 15,
		"18": 15,
		"19": 15,
		"20": 15,
		"21": 15,
		"22": 15,
		"23": 15,
		"24": 15
	};
	
	var DEMO1_SCRIPT								: Array<Float>							= [ 1, 3, 5, 8, 12, 17];
	var DEMO2_SCRIPT								: Array<Float>							= [ 4, 7, 11];
	
	public var myHUD( get, null)					: MyHUD;
	var _myHUD										: MyHUD									= null;
	function get_myHUD() : MyHUD { return _myHUD; }
	
	var doMode										: Float->Void							= null;
	var isPause										: Bool									= false;
	
	public var tablo( get, null)					: Tablo;
	var _tablo										: Tablo									= null;
	function get_tablo() : Tablo { return _tablo; }
	
	var tableau										: AssetInstance							= null;
	
	var mobiles										: MobileMgr								= null;
	
	var balle										: MyBalle								= null;
	var samsam										: Samsam								= null;
	var crap										: Crapouille							= null;
	
	public function new() { super(); }
	
	override public function getGameId() : String { return "Game" /*+ *//* DEBUG : *//*cast( shell, MyShell).packNum*//*1*/; }
	
	override public function init( pShell : IGameShell, pCont : Container, pSavedDatas : SavedDatas = null) : Void {
		super.init( pShell, pCont, pSavedDatas);
		
		_myHUD = cast shell.enableGameHUD();
		
		if ( VegaDeactivator.isInstance()) VegaDeactivator.getInstance().addListener( onDeactivate);
	}
	
	override public function destroy() : Void {
		if ( VegaDeactivator.isInstance()) VegaDeactivator.getInstance().remListener( onDeactivate);
		
		clear();
		
		gameContainer.removeChild( _tablo);
		_tablo.destroy();
		_tablo = null;
		
		_myHUD = null;
		
		super.destroy();
	}
	
	override public function reset( pSavedDatas : SavedDatas = null) : Void {
		balle.reset();
		samsam.reset();
		crap.reset();
		mobiles.reset();
		_tablo.reset();
	}
	
	override public function switchPause( pIsPause : Bool) : Void {
		if ( isPause != pIsPause){
			if( ( ! VegaDeactivator.isInstance()) || VegaDeactivator.getInstance().isActive) doPause( pIsPause);
			
			isPause = pIsPause;
		}
	}
	
	override public function doFrame( pDt : Float) : Void { if ( ( ! isPause) && doMode != null && ( ( ! VegaDeactivator.isInstance()) || VegaDeactivator.getInstance().isActive)) doMode( pDt); }
	
	public function clear() : Void {
		var lChild	: DisplayObject;
		
		if ( getSolContainer().children.length > 1){
			lChild = getSolContainer().getChildAt( 1);
			
			getSolContainer().removeChild( lChild);
			lChild.destroy();
		}
		
		if ( crap != null){
			crap.destroy();
			crap = null;
		}
		
		if ( samsam != null){
			samsam.destroy();
			samsam = null;
		}
		
		if ( balle != null){
			balle.destroy();
			balle = null;
		}
		
		if ( mobiles != null){
			mobiles.destroy();
			mobiles = null;
		}
		
		if ( tableau != null){
			gameContainer.removeChild( tableau);
			tableau.free();
			tableau = null;
		}
		
		_tablo.clear();
		
		doMode = null;
	}
	
	public function onBalleTimeout() : Void {
		if ( balle.isSleeping()) return;
		
		balle.setSleeping();
		
		crap.lanceAnimEchec();
		
		trace( "onBalleTimeout");
	}
	
	public function onBalleStoped() : Void {
		if ( balle.isSleeping()) return;
		
		balle.setSleeping();
		
		crap.lanceAnimEchec();
		
		trace( "onBalleStoped");
	}
	
	public function onBalleOut() : Void {
		if ( balle.isSleeping()) return;
		
		balle.setSleeping();
		
		crap.lanceAnimEchec( true);
		
		trace( "onBalleOut");
	}
	
	public function onBalleHitCrap() : Void {
		if ( balle.isSleeping()) return;
		
		balle.askSleeping();
		
		crap.lanceAnimReussite();
		
		trace( "onBalleHitCrap");
	}
	
	public function onWin() : Void { shell.onGameover(); }
	
	public function getLvlBalleTimeout() : Float { return ID_TO_DUREE[ getLvlId()] * 1000; }
	
	public function getLvlId() : Int { return Std.parseInt( tableau.getDesc().id.substr( ASSET_TABLEAU_RADIX.length)); }
	
	public function setLvlId( pId : Int) : Void {
		var lLayers	: Array<Layer>;
		var lLayer	: Layer;
		
		mobiles = new MobileMgr();
		mobiles.init( this);
		
		tableau = cast gameContainer.addChild( AssetsMgr.instance.getAssetInstance( ASSET_TABLEAU_RADIX + pId));
		tableau.position.copy( getTableauXY());
		tableau.scale.x	= tableau.scale.y = getTableauScale();
		
		balle = new MyBalle( this, getBalleLayer());
		
		samsam = new Samsam( this, getSamsamLayer(), getBalleLayer().x > getSamsamLayer().x);
		
		getSolContainer().addChild( _myHUD.instanciateSolAsset());
		
		crap = new Crapouille( this, getCrapLayer());
		
		lLayers = UtilsFlump.getLayers( getTableau());
		for ( lLayer in lLayers){
			if ( lLayer.name.indexOf( LAYER_FIXE_RADIX) != -1){
				_tablo.createBoite( getTableau().getLayer( lLayer.name), false);
			}else if ( lLayer.name.indexOf( LAYER_SPE_RADIX) != -1){
				_tablo.createSpecial( getTableau().getLayer( lLayer.name));
			}else if ( lLayer.name.indexOf( LAYER_BALANCE_RADIX) != -1){
				_tablo.createBalance( getTableau().getLayer( lLayer.name));
			}else if ( lLayer.name.indexOf( LAYER_MOBILE_RADIX) != -1 || lLayer.name == LAYER_SPE_U){
				mobiles.add( getTableau().getLayer( lLayer.name));
			}
		}
		
		_tablo.setSupportSam( getTableau().getLayer( LAYER_SUP_SAM));
		
		setModeGame();
	}
	
	public function beginShoot() : Void {
		balle.lock();
		samsam.lock();
		mobiles.lock();
		
		samsam.beginShoot();
	}
	
	public function doShoot( pIsRight : Bool) : Void { balle.doShoot( pIsRight); }
	
	public function testWorldWithMobileRect( pZone : DisplayObject) : Bool {
		var lLayers	: Array<Layer>	= UtilsFlump.getLayers( getTableau());
		var lLayer	: Layer;
		var lZone	: DisplayObject;
		
		for ( lLayer in lLayers){
			if ( lLayer.name.indexOf( LAYER_FIXE_RADIX) != -1){
				lZone = cast( getTableau().getLayer( lLayer.name).getChildAt( 0), Movie).getLayer( LAYER_RECT_BOUNDS);
				
				if ( UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds())) return true;
			}
		}
		
		lZone = cast( getTableau().getLayer( LAYER_SUP_SAM).getChildAt( 0), Movie).getLayer( LAYER_RECT_BOUNDS);
		if ( UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds())) return true;
		
		lZone = getTableau().getLayer( LAYER_SOL);
		if ( UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds())) return true;
		
		lZone = cast( getBalleLayer().getChildAt( 0), Movie).getLayer( LAYER_RECT_BOUNDS);
		if ( UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds())) return true;
		
		lZone = samsam.getHitBoxZone();
		if ( UtilsPixi.intersects( UtilsPixi.toLocalRect( pZone, lZone), lZone.getLocalBounds())) return true;
		
		return false;
	}
	
	public function getTableauScale() : Float { return ApplicationMatchSize.instance.getScreenRectExt().height / Tablo.HEIGHT_FULL; }
	
	function onDeactivate( pIsDeactivate : Bool) : Void { if ( ! isPause) doPause( pIsDeactivate); }
	
	function doPause( pIsPause : Bool) : Void {
		if ( samsam != null) samsam.switchPause( pIsPause);
		if ( crap != null) crap.switchPause( pIsPause);
	}
	
	override function getGamePatternAsset() : Array<PatternAsset> {
		var lRes	: Array<PatternAsset>	= super.getGamePatternAsset();
		
		lRes.push( new PatternAsset( "characters", PatternAsset.FIND_ON_GROUP, PatternAsset.MATCH_ALL));
		
		return lRes;
	}
	
	override function onGameReady() : Void {
		_tablo = cast gameContainer.addChild( new Tablo( this));
		
		super.onGameReady();
	}
	
	function getTableauXY() : Point { return new Point( ApplicationMatchSize.instance.getScreenRectMin().x, ApplicationMatchSize.instance.getScreenRectExt().y); }
	
	function getTableau() : Movie { return cast tableau.getContent(); }
	function getCrapLayer() : Container { return getTableau().getLayer( LAYER_CRAP); }
	function getBalleLayer() : Container { return getTableau().getLayer( LAYER_BALLE); }
	function getSamsamLayer() : Container { return getTableau().getLayer( "fakeSam"); }
	function getHintLayer() : Container { return getTableau().getLayer( "hint"); }
	
	function getSolContainer() : Container { return cast getTableau().getLayer( LAYER_SOL).getChildAt( 0); }
	
	function setModeGame() : Void {
		doMode = doModeGame;
	}
	
	function doModeGame( pDt : Float) : Void {
		mobiles.doFrame( pDt);
		samsam.doFrame( pDt);
		crap.doFrame( pDt);
		balle.doFrame( pDt);
		_tablo.doFrame( pDt);
		_myHUD.doFrame( pDt);
	}
}