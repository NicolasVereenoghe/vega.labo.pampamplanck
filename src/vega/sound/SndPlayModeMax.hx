package vega.sound;

/**
 * mode de lecture avec contrôle du nombre d'instances lancées ; on arrête les plus vieilles si le nombre max est dépassé
 * @author	nico
 */
class SndPlayModeMax extends SndPlayMode implements ISndPlayModeMax {
	/** pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés */
	var _subId									: String								= null;
	
	/** nombre max de sons jouables avant de commencer à stopper les + vieux */
	var _max									: Int									= -1;
	
	/**
	 * @inheritDoc
	 * @param		pSubId	pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés ; si nombre dépassé, on arrête les plus vieux
	 * @param		pMax	nombre max de sons jouables avant de commencer à stopper les + vieux
	 */
	public function new( pSubId : String, pMax : Int) {
		super();
		
		_subId	= pSubId;
		_max	= pMax;
	}
	
	/** @inheritDoc */
	public function getMaxSubId() : String { return _subId; }
	
	/** @inheritDoc */
	public function getMaxNb() : Int { return _max; }
}