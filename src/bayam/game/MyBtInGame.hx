package bayam.game;

import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.ui.MyButtonFlump;

/**
 * ...
 * @author 
 */
class MyBtInGame extends MyButtonFlump {
	public function new( pCont : Movie, pOnDown : InteractionEvent->Void = null, pOnRelease : InteractionEvent->Void = null, pIsAutoPlay : Bool = false, pIsPreservFrame : Bool = false) {
		super( pCont, pOnDown, pOnRelease, pIsAutoPlay, pIsPreservFrame);
		
		enableState( stateOver);
		stateUp = stateOver;
		stateOver = null;
	}
}