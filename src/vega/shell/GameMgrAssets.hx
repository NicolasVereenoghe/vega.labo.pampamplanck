package vega.shell;
import pixi.core.display.Container;
import vega.assets.AssetsMgr;
import vega.assets.NotifyMallocAssets;
import vega.assets.PatternAsset;
import vega.loader.VegaLoader;
import vega.loader.VegaLoaderListener;
import vega.shell.IGameShell;

/**
 * ...
 * @author nico
 */
class GameMgrAssets implements IGameMgr {
	/** racine de nom de groupe d'assets du jeu */
	var GAME_GROUP_ASSET_RADIX		: String						= "game";
	
	/** réf sur le conteneur des éléments de jeu */
	var gameContainer				: Container;
	
	/** réf sur le shell responsable de ce jeu */
	var shell						: IGameShell;
	
	public function new() { }
	
	/** @inheritDoc */
	public function init( pShell : IGameShell, pCont : Container, pSavedDatas : SavedDatas = null) : Void {
		shell			= pShell;
		gameContainer	= pCont;
		
		loadAssets();
	}
	
	/** @inheritDoc */
	public function reset( pSavedDatas : SavedDatas = null) : Void { ApplicationMatchSize.instance.traceDebug( "WARNING : GameMgrAssets::reset : méthode abstraite, doit être redéfinie"); }
	
	/** @inheritDoc */
	public function destroy() : Void {
		AssetsMgr.instance.freeAssets( getGamePatternAsset());
		AssetsMgr.instance.unloadAssets( null, getGamePatternAsset());
		
		shell = null;
		gameContainer = null;
	}
	
	/** @inheritDoc */
	public function start() : Void { ApplicationMatchSize.instance.traceDebug( "WARNING : GameMgrAssets::start : méthode abstraite, doit être redéfinie"); }
	
	/** @inheritDoc */
	public function doFrame( pTime : Float) : Void { }
	
	/** @inheritDoc */
	public function getGameId() : String {
		ApplicationMatchSize.instance.traceDebug( "ERROR : GameMgrAssets::getGameId : méthode abstraite, doit être redéfinie");
		
		return null;
	}
	
	/** @inheritDoc */
	public function switchPause( pIsPause : Bool) : Void { ApplicationMatchSize.instance.traceDebug( "WARNING : GameMgrAssets::switchPause : méthode abstraite, doit être redéfinie : " + pIsPause); }
	
	/** @inheritDoc */
	public function getScore() : MyScore {
		ApplicationMatchSize.instance.traceDebug( "WARNING : GameMgrAssets::getScore : pas de définition");
		
		return null;
	}
	
	/** @inheritDoc */
	public function getDatas() : SavedDatas {
		ApplicationMatchSize.instance.traceDebug( "WARNING : GameMgrAssets::getDatas : pas de définition");
		
		return null;
	}
	
	/**
	 * on retourne une liste de patterns d'assets utilisés par le jeu en cours
	 * @return	liste de patterns d'assets (PatternAsset)
	 */
	function getGamePatternAsset() : Array<PatternAsset> { return [ new PatternAsset( GAME_GROUP_ASSET_RADIX + getGameId(), PatternAsset.FIND_ON_GROUP, PatternAsset.MATCH_ALL)];}
	
	/**
	 * on est notifié que le jeu est prêt à être lancé
	 */
	function onGameReady() : Void { shell.onGameReady();}
	
	/**
	 * on lance le chargement d'assets du jeu
	 * @param	pLoader	instance de loader à utiliser, ou laisser null pour partir d'une nouvelle instance
	 */
	function loadAssets( pLoader : VegaLoader = null) : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : GameMgrAsset::loadAssets");
		
		if ( pLoader == null) pLoader = new VegaLoader();
		
		AssetsMgr.instance.loadAssets(
			pLoader,
			getGamePatternAsset()
		).load( new VegaLoaderListener( onAssetsLoaded, null, onAssetsLoadProgress));
	}
	
	/**
	 * on est notifié de la progression du chargement
	 * @param	pLoader	loader en cours de progression
	 */
	function onAssetsLoadProgress( pLoader : VegaLoader) : Void { shell.onGameProgress( pLoader.getProgressRate() * .5); }
	
	/**
	 * on est notifié de la fin de chargement des assets du jeu ; on lance leur allocation
	 * @param	pLoader	instance de loader qui a charsgé les assets
	 */
	function onAssetsLoaded( pLoader : VegaLoader) : Void {
		AssetsMgr.instance.mallocAssets(
			new NotifyMallocAssets( onMallocEnd, onAssetsMallocProgress),
			getGamePatternAsset()
		);
	}
	
	/**
	 * on est notifié de la progression de l'allocation mémorie
	 * @param	pCur	nombre d'assets alloués
	 * @param	pTotal	nombre total à allouer
	 */
	function onAssetsMallocProgress( pCur : Int, pTotal : Int) : Void { shell.onGameProgress( .5 + .5 * pCur / pTotal); }
	
	/**
	 * on est notifié de la fin d'allocation des assets du jeu
	 */
	function onMallocEnd() : Void { onGameReady(); }
}