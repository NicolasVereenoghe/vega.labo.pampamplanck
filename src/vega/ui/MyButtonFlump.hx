package vega.ui;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.shell.ApplicationMatchSize;
import vega.shell.GlobalPointer;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author nico
 */
class MyButtonFlump {
	/** nom du symbole d'état "up" dans le conteneur */
	public static inline var NAME_UP			: String					= "up";
	/** nom de symbole d'état "over" dans le conteneur */
	public static inline var NAME_OVER			: String					= "over";
	/** nom de symbole d'état "down" dans le coneneur */
	public static inline var NAME_DOWN			: String					= "down";
	/** nom de symbole d'état "select" dans le conteneur */
	public static inline var NAME_SELECT		: String					= "select";
	/** nom de symbole d'état "selectDown" dans le conteneur */
	public static inline var NAME_SELECT_DOWN	: String					= "selectDown";
	/** nom de symbole d'état "selectOver" dans le conteneur */
	public static inline var NAME_SELECT_OVER	: String					= "selectOver";
	/** nom de symbole d'état "disable" dans le conteneur */
	public static inline var NAME_DISABLE		: String					= "disable";
	
	var stateUp								: DisplayObject;
	var stateOver							: DisplayObject;
	var stateDown							: DisplayObject;
	
	var stateSelect							: DisplayObject;
	var stateSelectOver						: DisplayObject;
	var stateSelectDown						: DisplayObject;
	
	var stateDisable						: DisplayObject;
	
	var curState							: DisplayObject;
	
	var container							: Movie;
	
	var hit									: DisplayObject;
	
	var onDownCB							: Array<InteractionEvent -> Void>	= null;
	var onReleaseCB							: InteractionEvent -> Void			= null;
	
	/** pile de listeners de press (mouse : release, touch : down) */
	var onPressCB							: Array <InteractionEvent -> Void>	= null;
	/** pile de listeners de mouse over */
	var onMouseOverCB						: Array <InteractionEvent -> Void>	= null;
	
	var isDown								: Bool							= false;
	
	/** flag indiquant si un état de bouton est un conteneur, on lance la lecture récursive de son contenu (true) ; false pour ne pas lire dans tous les cas */
	var autoPlay							: Bool							= false;
	/** true pour conserver la frame en cours lors d'une transition d'état, sinon false repartir de dernière frame en cours */
	var isPreservFrame						: Bool							= false;
	
	/** flag indiquant si on est en pause (true) ou pas (false) */
	var isPause								: Bool							= false;
	
	/**
	 * construction
	 * @param	pCont
	 * @param	pOnDown			@deprecated
	 * @param	pOnRelease		@deprecated
	 * @param	pIsAutoPlay
	 * @param	pIsPreservFrame	mettre true pour conserver la frame en cours lors d'une transition d'état, sinon laisser false repartir de dernière frame en cours
	 */
	public function new( pCont : Movie, pOnDown : InteractionEvent -> Void = null, pOnRelease : InteractionEvent -> Void = null, pIsAutoPlay : Bool = false, pIsPreservFrame : Bool = false) {
		container		= pCont;
		onDownCB		= [];
		onReleaseCB		= pOnRelease;
		autoPlay		= pIsAutoPlay;
		isPreservFrame	= pIsPreservFrame;
		
		onPressCB		= [];
		onMouseOverCB	= [];
		
		if ( pOnDown != null) onDownCB.push( pOnDown);
		
		hit				= pCont.getLayer( "hit").getChildAt( 0);
		
		hit.alpha		= 0;
		hit.buttonMode	= true;
		hit.interactive	= true;
		
		hit.on( "mousedown", onDown);
		hit.on( "mouseover", onOver);
		hit.on( "mouseup", onUp);
		hit.on( "mouseout", onOut);
		
		hit.on( "touchstart", onTDown);
		hit.on( "touchmove", onTOver);
		hit.on( "touchend", onTUp);
		hit.on( "touchendoutside", onTUpOut);
		
		stateUp = pCont.getLayer( NAME_UP).getChildAt( 0);
		stateUp.interactive = false;
		stateUp.visible = false;
		
		if ( UtilsFlump.getLayer( NAME_OVER, pCont) != null){
			stateOver = pCont.getLayer( NAME_OVER).getChildAt( 0);
			stateOver.interactive = false;
			stateOver.visible = false;
		}
		
		if ( UtilsFlump.getLayer( NAME_DOWN, pCont) != null){
			stateDown = pCont.getLayer( NAME_DOWN).getChildAt( 0);
			stateDown.interactive = false;
			stateDown.visible = false;
		}
		
		if ( UtilsFlump.getLayer( NAME_SELECT, pCont) != null) {
			stateSelect = pCont.getLayer( NAME_SELECT).getChildAt( 0);
			stateSelect.interactive = false;
			stateSelect.visible = false;
		}
		
		if ( UtilsFlump.getLayer( NAME_SELECT_DOWN, pCont) != null) {
			stateSelectDown = pCont.getLayer( NAME_SELECT_DOWN).getChildAt( 0);
			stateSelectDown.interactive = false;
			stateSelectDown.visible = false;
		}
		
		if ( UtilsFlump.getLayer( NAME_SELECT_OVER, pCont) != null) {
			stateSelectOver = pCont.getLayer( NAME_SELECT_OVER).getChildAt( 0);
			stateSelectOver.interactive = false;
			stateSelectOver.visible = false;
		}
		
		if( UtilsFlump.getLayer( NAME_DISABLE, pCont) != null) {
			stateDisable = pCont.getLayer( NAME_DISABLE).getChildAt( 0);
			stateDisable.interactive = false;
			stateDisable.visible = false;
		}
		
		enableState( stateUp);
	}
	
	public function destroy() : Void {
		if ( curState != null && autoPlay && Std.is( curState, Container)) UtilsFlump.recursiveGotoAndStop( cast curState, 0);
		
		hit.off( "mousedown", onDown);
		hit.off( "touchstart", onTDown);
		hit.off( "mouseover", onOver);
		hit.off( "touchmove", onTOver);
		hit.off( "mouseup", onUp);
		hit.off( "touchend", onTUp);
		hit.off( "touchendoutside", onTUpOut);
		hit.off( "mouseout", onOut);
		
		hit.buttonMode		= false;
		hit.interactive		= false;
		
		container.visible	= true;
		
		if ( stateUp != null){
			stateUp.visible = true;
			stateUp = null;
		}
		
		if ( stateOver != null){
			stateOver.visible = true;
			stateOver = null;
		}
		
		if ( stateDown != null){
			stateDown.visible = true;
			stateDown = null;
		}
		
		if ( stateSelect != null){
			stateSelect.visible = true;
			stateSelect = null;
		}
		
		if ( stateSelectOver != null){
			stateSelectOver.visible = true;
			stateSelectOver = null;
		}
		
		if ( stateSelectDown != null){
			stateSelectDown.visible = true;
			stateSelectDown = null;
		}
		
		curState			= null;
		hit					= null;
		onPressCB			= null;
		onMouseOverCB		= null;
		onDownCB			= null;
		onReleaseCB			= null;
		container			= null;
	}
	
	/**
	 * ajout d'un listener de donw sur bouton
	 * @param	pListener	écouteur
	 */
	public function addDownListener( pListener : InteractionEvent -> Void) : Void { onDownCB.push( pListener); }
	
	/**
	 * ajout d'un é"couteur de press (mouse : release, touch : down)
	 * @param	pListener	écouteur de press
	 */
	public function addPressListener( pListener : InteractionEvent -> Void) : Void { onPressCB.push( pListener); }
	
	/**
	 * ajout d'un listener demouse over
	 * @param	pListener	écouteur de mouse over
	 */
	public function addMouseOverListener( pListener : InteractionEvent -> Void): Void { onMouseOverCB.push( pListener); }
	
	/**
	 * récupère le conteneur modèle du bouton
	 * @return	conteneur modèle du bouton
	 */
	public function getModel() : Movie { return container; }
	
	/**
	 * on récupère l'état graphique actuel du bouton
	 * @return	réf sur le graphisme d'état courant du bouton
	 */
	public function getCurState() : DisplayObject { return curState; }
	
	/**
	 * on active / désactive le bouton
	 * @param	pIsEnable	true pour activer, false pour désactiver
	 */
	public function switchEnable( pIsEnable : Bool) : Void {
		hit.buttonMode	= pIsEnable;
		hit.interactive	= pIsEnable;
		
		if ( pIsEnable){
			if ( stateDisable != null && curState == stateDisable) enableState( stateUp);
		}else{
			if ( stateDisable != null) enableState( stateDisable);
		}
	}
	
	/**
	 * on bascule l'état animé du bouton
	 * @param	pIsAnim	true pour lancer l'anim, false pour la stoper en frame 0
	 */
	public function switchAnim( pIsAnim : Bool) : Void {
		if ( pIsAnim){
			if ( ! autoPlay){
				autoPlay = true;
				
				if( ( ! isPause) && curState != null && Std.is( curState, Container)) UtilsFlump.recursivePlay( cast curState);
			}
		}else{
			if ( autoPlay){
				autoPlay = false;
				
				if( ( ! isPause) && curState != null && Std.is( curState, Container)) UtilsFlump.recursiveGotoAndStop( cast curState, 0);
			}
		}
	}
	
	/**
	 * on bascule la pause
	 * @param	pIsPause	true pour passer en pause, false pour en sortir
	 */
	public function switchPause( pIsPause : Bool) : Void {
		if( autoPlay){
			if ( pIsPause){
				if ( ! isPause){
					if( curState != null && Std.is( curState, Container)) UtilsFlump.recursiveStop( cast curState);
				}
			}else{
				if ( isPause){
					if( curState != null && Std.is( curState, Container)) UtilsFlump.recursivePlay( cast curState);
				}
			}
		}
		
		isPause = pIsPause;
	}
	
	/**
	 * on déselectionne le bouton en le refaisant passer au state "up" par défaut
	 */
	public function unselect() : Void { if ( stateUp != null) enableState( stateUp); }
	
	/**
	 * on force la sélection du bouton, on suppose que le bouton possède l'état "select"
	 */
	public function select() : Void { if ( stateSelect != null) enableState( stateSelect); }
	
	public function reset() : Void {
		enableState( stateUp);
	}
	
	public function hide() : Void {
		reset();
		container.visible = false;
	}
	
	public function show() : Void {
		reset();
		container.visible = true;
	}
	
	public function enableState( pState : DisplayObject) : Bool {
		var lFr	: Int	= 0;
		
		if( pState != curState){
			if ( curState != null) {
				if ( isPreservFrame && Std.is( curState, Movie)) lFr = cast( curState, Movie).currentFrame;
				
				if ( autoPlay && Std.is( curState, Container)) UtilsFlump.recursiveGotoAndStop( cast curState, 0);
				
				curState.visible	= false;
			}
			
			curState = pState;
			
			if ( curState != null) {
				curState.visible	= true;
				
				if ( isPreservFrame && Std.is( curState, Movie)) UtilsFlump.recursiveGotoAndStop( cast curState, lFr);
				
				if ( ( ! isPause) && autoPlay && Std.is( curState, Container)) UtilsFlump.recursivePlay( cast curState);
			}
			
			return true;
		}else return false;
	}
	
	/**
	 * on vérifie si on est à l'état "select" ou l'un de ses sous-états ("selectOver" ou "selectDown") ; ne teste que le en cours ponctuel
	 * @return	true si à l'état "select", false sinon
	 */
	function isSelect() : Bool { return curState != null && ( curState == stateSelect || curState == stateSelectDown || curState == stateSelectOver); }
	
	function onTOver( pE : InteractionEvent) : Void {
		if ( isSelect()) {
			if ( stateSelectOver != null && isOver()) enableState( stateSelectOver);
			else enableState( stateSelect);
		}else {
			if ( stateOver != null && isOver()) enableState( stateOver);
			else enableState( stateUp);
		}
	}
	
	function onOver( pE : InteractionEvent) : Void {
		if ( isSelect()) {
			if ( stateSelectOver != null) enableState( stateSelectOver);
			else enableState( stateSelect);
		}else{
			if ( stateOver != null) enableState( stateOver);
			else enableState( stateUp);
		}
		
		callListeners( onMouseOverCB, pE);
	}
	
	function onTUp( pE : InteractionEvent) : Void {
		onTUpOut( pE);
		
		if ( onReleaseCB != null) onReleaseCB( pE);
	}
	
	function onTUpOut( pE : InteractionEvent) : Void {
		isDown = false;
		
		if ( isSelect()) enableState( stateSelect);
		else enableState( stateUp);
	}
	
	function onUp( pE : InteractionEvent) : Void {
		isDown = false;
		
		if ( isSelect()) {
			if ( stateSelectOver != null && isOver()) enableState( stateSelectOver);
			else enableState( stateSelect);
		}else {
			if ( stateOver != null && isOver()) enableState( stateOver);
			else enableState( stateUp);
		}
		
		if ( onReleaseCB != null) onReleaseCB( pE);
		callListeners( onPressCB, pE);
	}
	
	function onTDown( pE : InteractionEvent) : Void { onDown( pE, false); }
	
	function onDown( pE : InteractionEvent, pIsMouse : Bool = true) : Void {
		isDown = true;
		
		if( GlobalPointer.isOK()) GlobalPointer.instance.forceCaptureDown( pE, pIsMouse);
		
		if ( isSelect()) {
			if ( stateSelectDown != null) enableState( stateSelectDown);
			else if ( stateSelectOver != null) enableState( stateSelectOver);
			else enableState( stateSelect);
		}else{
			if ( stateDown != null) enableState( stateDown);
			else if ( stateOver != null) enableState( stateOver);
			else enableState( stateUp);
		}
		
		callListeners( onDownCB, pE);
		if ( ! pIsMouse) callListeners( onPressCB, pE);
		
		//pE.stopPropagation();
	}
	
	function onOut( pE : InteractionEvent) : Void {
		isDown = false;
		
		if ( isSelect()) enableState( stateSelect);
		else enableState( stateUp);
	}
	
	function isOver() : Bool { return ( ! isDown) && ( ( ! GlobalPointer.isOK()) || GlobalPointer.instance.getTouchOverRect( UtilsPixi.getContentBounds( hit)).length > 0); }
	
	/**
	 * appel d'une pile de listeners
	 * @param	pListeners	pile de listeners à appeler
	 * @param	pE			event d'interaction à transmettre
	 */
	function callListeners( pListeners : Array<InteractionEvent->Void>, pE : InteractionEvent) : Void {
		var lListener	: InteractionEvent->Void;
		
		if ( pListeners != null) for ( lListener in pListeners) lListener( pE);
	}
}