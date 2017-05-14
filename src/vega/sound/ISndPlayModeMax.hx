package vega.sound;

/**
 * mode de lecture avec contrôle du nombre d'instances lancées ; on arrête les plus vieilles si le nombre max est dépassé
 * @author	nico
 */
interface ISndPlayModeMax {
	/**
	 * nombre max de sons jouables avant de commencer à stopper les + vieux
	 * @return	nb max
	 */
	function getMaxNb() : Int;
	
	/**
	 * pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés
	 * @return	pattern de recherche ou null pour tout désigner
	 */
	function getMaxSubId() : String;
}