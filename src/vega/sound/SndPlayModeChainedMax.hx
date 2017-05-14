package vega.sound;

/**
 * lancement chainé et contrôle max d'instances
 * @author	nico
 */
class SndPlayModeChainedMax extends SndPlayMode implements ISndPlayModeChained implements ISndPlayModeMax {
	/** pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés */
	var _maxSubId								: String								= null;
	
	/** nombre max de sons jouables avant de commencer à stopper les + vieux */
	var _maxNb									: Int									= -1;
	
	/** pattern de recherche d'identifiants de son à vérifier la fin de lecture avant de lancer notre son ; laisser null pour tout vérifier */
	var _chainedSubId							: String							= null;
	
	/**
	 * @inheritDoc
	 * @param	pChainedSubId	pattern de recherche d'identifiants de son à vérifier la fin de lecture avant de lancer notre son ; laisser null pour tout vérifier
	 * @param	pMaxSubId		pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés ; si nombre dépassé, on arrête les plus vieux
	 * @param	pMaxNb			nombre max de sons jouables avant de commencer à stopper les + vieux
	 */
	public function new( pChainedSubId : String, pMaxSubId : String, pMaxNb : Int) {
		super();
		
		_maxNb			= pMaxNb;
		_maxSubId		= pMaxSubId;
		_chainedSubId	= pChainedSubId;
	}
	
	/** @inheritDoc */
	public function getMaxNb() : Int { return _maxNb; }
	
	/** @inheritDoc */
	public function getMaxSubId() : String { return _maxSubId; }
	
	/** @inheritDoc */
	public function getChainedSubId() : String { return _chainedSubId; }
}