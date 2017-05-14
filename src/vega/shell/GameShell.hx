package vega.shell;
import vega.loader.file.MyFile;
import pixi.core.display.Container;
import vega.shell.IGameMgr;

/**
 * implémentation commune d'un shell de jeu
 * @author nico
 */
class GameShell extends BaseShell implements IGameShell {
	/** conteneur de jeu */
	var gameContainer							: Container;
	
	/** réf sur le jeu en cours d'éxé, ou null si aucun */
	var curGame									: IGameMgr				= null;
	
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function init( pCont : Container, pFileAssets : MyFile, pFileLocal : MyFile, pFonts : Dynamic) : Void {
		gameContainer	= cast pCont.addChild( new Container());
		
		super.init( pCont, pFileAssets, pFileLocal, pFonts);
	}
	
	/** @inheritDoc */
	public function onGameHelp( pHelpTag : String = null) : Void { ApplicationMatchSize.instance.traceDebug( "INFO : GameShell::onGameHelp : " + pHelpTag); }
	
	/** @inheritDoc */
	public function onGameReady() : Void { startGame(); }
	
	/** @inheritDoc */
	public function onGameProgress( pRate : Float) : Void { ApplicationMatchSize.instance.traceDebug( "INFO : GameShell::onGameProgress : " + pRate); }
	
	/** @inheritDoc */
	public function onGameAborted() : Void { killGame(); }
	
	/** @inheritDoc */
	public function onGameover(  pScore : MyScore = null, pSavedDatas : SavedDatas = null) : Void { onGameAborted(); }
	
	/** @inheritDoc */
	public function getCurGame() : IGameMgr { return curGame; }
	
	/** @inheritDoc */
	public function enableGameHUD( pType : String = null) : IMyHUD {
		ApplicationMatchSize.instance.traceDebug( "INFO : GameShell::enableGameHUD : " + pType);
		
		return null;
	}
	
	/** @inheritDoc */
	public function getCurGameHUD() : IMyHUD { return null; }
	
	/**
	 * on retourne les données sauvegardées pour le jeu en cours ; il doit y avoir une instance de jeu en cours
	 * @return	données sauvées du jeu en cours ; null si non trouvées
	 */
	function getCurGameSavedDatas() : SavedDatas { return getSavedDatas( curGame.getGameId()); }
	
	/**
	 * on retourne l'instance de jeu à lancer en fonction l'identifiant de jeu défini lors de la construction de la coque minimale (voir ::gameId)
	 * @return	instance de jeu à lancer ; null si aucune instance trouvée
	 */
	function getGameInstance() : IGameMgr { return curGame; }
	
	/**
	 * on lance le jeu désigné par ::gameId
	 */
	function launchGame() : Void {
		curGame = getGameInstance();
		curGame.init( this, gameContainer, getCurGameSavedDatas());
	}
	
	/**
	 * on fait le start du jeu en cours
	 */
	function startGame() : Void { curGame.start(); }
	
	/**
	 * on libère la mémoire d'un jeu
	 */
	function killGame() : Void {
		curGame.destroy();
		curGame = null;
	}
	
	/** @inheritDoc */
	override function doFrame( pTime : Float) : Void {
		super.doFrame( pTime);
		
		if ( curGame != null) curGame.doFrame( pTime);
	}
}