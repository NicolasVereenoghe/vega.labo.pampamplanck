package vega.sound;

/**
 * on lance un son dès qu'un autre s'est arrêté
 * @author	nico
 */
interface ISndPlayModeChained {
	/**
	 * on récupère la pattern de recherche d'identifiants de son à vérifier la fin de lecture avant de lancer notre son
	 * @return	pattern de recherche, ou null pour désigner tous les sons
	 */
	function getChainedSubId() : String;
}