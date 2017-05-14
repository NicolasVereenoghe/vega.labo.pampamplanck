package vega.sound;

/**
 * mode de lecture pour rattraper un temps de synchro (démarrer en marche)
 * @author	nico
 */
interface ISndPlayModeSync {
	function getSyncStartedAtTime() : Float;
}