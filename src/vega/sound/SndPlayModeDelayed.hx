package vega.sound;

/**
 * ...
 * @author nico
 */
class SndPlayModeDelayed extends SndPlayMode implements ISndPlayModeDelayed {
	/** temps de lancement en ms différé du son : postérieur à maintenant ( Date.now().getTime()) */
	var _delayedStartTime						: Float							= -1;
	
	/**
	 * @inheritDoc
	 * @param	pDelayedStartTime	temps de lancement en ms différé du son : postérieur à maintenant ( Date.now().getTime())
	 */
	public function new( pDelayedStartTime : Float) {
		super();
		
		_delayedStartTime	= pDelayedStartTime;
	}
	
	/** @inheritDoc */
	public function getDelayedStartTime() : Float { return _delayedStartTime; }
}