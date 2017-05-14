package vega.sound;

/**
 * mode de lecture en différé
 * @author	nico
 */
interface ISndPlayModeDelayed {
	/**
	 * on récupère le moment où le son doit se lancer (en ms, par rapport à Date.now().getTime())
	 * @return	moment en ms
	 */
	function getDelayedStartTime() : Float;
}