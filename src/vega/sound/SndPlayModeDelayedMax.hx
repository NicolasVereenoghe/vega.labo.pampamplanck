package vega.sound;

/**
 * ...
 * @author 
 */
class SndPlayModeDelayedMax extends SndPlayMode implements ISndPlayModeDelayed implements ISndPlayModeMax {
	/** temps de lancement en ms différé du son : postérieur à maintenant ( Date.now().getTime()) */
	var _delayedStartTime						: Float							= -1;
	
	/** pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés */
	var _maxSubId								: String								= null;
	
	/** nombre max de sons jouables avant de commencer à stopper les + vieux */
	var _maxNb									: Int									= -1;
	
	/**
	 * @inheritDoc
	 * @param	pDelayedStartTime	temps de lancement en ms différé du son : postérieur à maintenant ( Date.now().getTime())
	 * @param	pMaxSubId			pattern de recherche d'identifiants de sons dont on contrôle le nombre de lancés ; si nombre dépassé, on arrête les plus vieux
	 * @param	pMaxNb				nombre max de sons jouables avant de commencer à stopper les + vieux
	 */
	public function new( pDelayedStartTime : Float, pMaxSubId : String, pMaxNb : Int) {
		super();
		
		_delayedStartTime	= pDelayedStartTime;
		_maxSubId			= pMaxSubId;
		_maxNb				= pMaxNb;
	}
	
	/** @inheritDoc */
	public function getMaxNb() : Int { return _maxNb; }
	
	/** @inheritDoc */
	public function getMaxSubId() : String { return _maxSubId; }
	
	/** @inheritDoc */
	public function getDelayedStartTime() : Float { return _delayedStartTime; }
}