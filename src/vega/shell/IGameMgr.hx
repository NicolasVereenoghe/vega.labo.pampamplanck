package vega.shell;
import pixi.core.display.Container;

/**
 * @author nico
 */
interface IGameMgr {
	public function init( pShell : IGameShell, pCont : Container, pSavedDatas : SavedDatas = null) : Void;
	
	/**
	 * on reset le jeu pour pouvoir y jouer à nouveau depuis le début ; à la suite du reset, le jeu est remis à l'état initial en pause et attend un ::startGame pour redémarrer
	 * @param	pSavedDatas		laisser null pour un reset par défaut, spécifier des données de jeu sauvées pour reset depuis un point de sauvegarde
	 */
	public function reset( pSavedDatas : SavedDatas = null) : Void;
	
	/**
	 * on récupère le score de jeu
	 * @return	descripteur de score du jeu, ou null si non défini
	 */
	function getScore() : MyScore;
	
	/**
	 * on récupère les données de jeu à sauver
	 * @return	données de jeu à sauver ; c'est une réf partagée, on peut écrire des données dedans ; ou null si rien à sauver (ou si on veut gérer la sauvegarde en interne)
	 */
	function getDatas() : SavedDatas;
	
	public function destroy() : Void;
	
	public function start() : Void;
	
	public function doFrame( pTime : Float) : Void;
	
	public function getGameId() : String;
	
	public function switchPause( pIsPause : Bool) : Void;
}