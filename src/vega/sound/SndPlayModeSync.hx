package vega.sound;

/**
 * ...
 * @author ...
 */
class SndPlayModeSync extends SndPlayMode implements ISndPlayModeSync {
	/** temps de lancement théorique du son : antérieur à maintenant */
	var syncStartTime						: Float							= -1;
	
	/**
	 * construction mode de lecture synchonisée à un moment de lancement antérieur
	 * @param	pTime	moment de lancement antérieur à synchroniser
	 */
	public function new( pTime : Float) {
		super();
		
		syncStartTime = pTime;
	}
	
	/** @inheritDoc */
	public function getSyncStartedAtTime() : Float { return syncStartTime; }
}