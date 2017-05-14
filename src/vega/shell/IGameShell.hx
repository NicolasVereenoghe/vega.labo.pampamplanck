package vega.shell;

/**
 * interface de shell de jeu
 * @author nico
 */
interface IGameShell {
	/**
	 * on veut ouvrir une aide
	 * @param	pHelpTag	tag contextuel de l'aide ; null si aucun
	 */
	function onGameHelp( pHelpTag : String = null) : Void;
	
	/**
	 * on signale au shell que le jeu qu'on a initialisé est prêt à être lancé
	 */
	function onGameReady() : Void;
	
	/**
	 * on signale au shell l'avancement de loading/malloc du jeu initialisé
	 * @param	pRate	taux d'avancement [0..1]
	 */
	function onGameProgress( pRate : Float) : Void;
	
	/**
	 * on signale au shell que le jeu en cours est quitté ; on n'est pas arrivé à son terme, c'est un exit prématuré ; le shell va détruire le jeu (IGMgr::destroy)
	 */
	function onGameAborted() : Void;
	
	/**
	 * on signale que le jeu en cours est arrivé à son terme
	 * @param	pScore		descripteur de score marqué pour ce jeu ; null si pas de score défini
	 * @param	pSavedDatas	réf sur les données à sauver du jeu ; si défini, on effectue l'écriture de données de résultat de jeu dans cette instance, et on sauvegarde ; laisser null pour ne rien gérer
	 */
	function onGameover( pScore : MyScore = null, pSavedDatas : SavedDatas = null) : Void;
	
	/**
	 * on récupère la référence sur le jeu en cours
	 * @return	ref sur jeu en cours ou null si aucun
	 */
	function getCurGame() : IGameMgr;
	
	/**
	 * on demande d'activer le HUD d'un jeu ; c'est un instanciateur de HUD
	 * @param	pType	nom identifiant d'un type de HUD ; permet d'avoir des variation de HUD si plusieurs jeux sont gérés ; null pour le type par défaut
	 * @return	le gestionnaire de HUD que l'on vient d'activer
	 */
	function enableGameHUD( pType : String = null) : IMyHUD;
	
	/**
	 * on récupère une ref sur le HUD actif
	 * @return	HUD actif, ou null si aucun en cours
	 */
	function getCurGameHUD() : IMyHUD;
}