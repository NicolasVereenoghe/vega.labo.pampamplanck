package vega.paddle;
import js.Browser;
import js.html.EventTarget;
import js.html.KeyboardEvent;
import vega.shell.ApplicationMatchSize;
import vega.utils.PointIJ;

/**
 * paddle directionnel avec les flèches du clavier
 * 
 * @author nico
 */
class MyKeyPaddle implements IDirectionPaddle {
	/** liste de key codes de DOWN */
	var DOWN_KEYS					: Array<Int>		= [ 40, 83];
	/** liste de key codes de UP */
	var UP_KEYS						: Array<Int>		= [ 38, 90, 87];
	/** liste de key codes de RIGHT */
	var RIGHT_KEYS					: Array<Int>		= [ 39, 68];
	/** liste de key codes de LEFT */
	var LEFT_KEYS					: Array<Int>		= [ 37, 81, 65];
	/** liste de key codes de ACTION */
	var ACTION_KEYS					: Array<Int>		= [ 32, 13];
	
	/** map de d'activation indexées par id de key ; true pour activé, false pour désactivé */
	var actives						: Map<Int,Bool>;
	
	/** vecteurs verrous des axes horizontaux (i) et verticaux (j) */
	var locks						: PointIJ;
	/** directions des axes horizontaux (i) et verticaux (j) */
	var curDir						: PointIJ;
	
	/** flag indiquant si le touche action est appuyée (true) ou pas (false) */
	var _isAction					: Bool				= false;
	/**  flag indiquant si l'action est verrouillée (true), ou pas (false) */
	var lockAction					: Bool				= false;
	
	/** propriété getter de ::_isAction */
	public var isAction(get, null)	: Bool;
	
	/** construction */
	public function new() {
		actives		= new Map<Int,Bool>();
		locks		= new PointIJ();
		curDir		= new PointIJ();
		
		Browser.document.addEventListener( "keydown", onKeyDown);
		Browser.document.addEventListener( "keyup", onKeyUp);
	}
	
	/** @inheritDoc */
	public function getCurDir() : PointIJ { return curDir; }
	
	/** @inheritDoc */
	public function lockDir( pLock : PointIJ) : Void {
		if ( pLock.i != 0 && curDir.i == pLock.i){
			locks.i = pLock.i;
			
			curDir.i = 0;
		}
		
		if ( pLock.j != 0 && curDir.j == pLock.j){
			locks.j = pLock.j;
			
			curDir.j = 0;
		}
	}
	
	/**
	 * on verrouille les touches action
	 */
	public function lockA() : Void { lockAction = true; }
	
	/** @inheritDoc */
	public function doFrame( pDT : Float) : Void {
		var lIsLeft		: Bool	= false;
		var lIsRight	: Bool	= false;
		var lIsDown		: Bool	= false;
		var lIsUp		: Bool	= false;
		var lId			: Int;
		
		for ( lId in LEFT_KEYS){
			if ( actives.exists( lId) && actives[ lId]){
				lIsLeft = true;
				break;
			}
		}
		
		for ( lId in RIGHT_KEYS){
			if ( actives.exists( lId) && actives[ lId]){
				lIsRight = true;
				break;
			}
		}
		
		for ( lId in DOWN_KEYS){
			if ( actives.exists( lId) && actives[ lId]){
				lIsDown = true;
				break;
			}
		}
		
		for ( lId in UP_KEYS){
			if ( actives.exists( lId) && actives[ lId]){
				lIsUp = true;
				break;
			}
		}
		
		_isAction = false;
		for ( lId in ACTION_KEYS){
			if ( actives.exists( lId) && actives[ lId]){
				_isAction = true;
				break;
			}
		}
		
		if ( lockAction){
			if ( _isAction) _isAction = false;
			else lockAction = false;
		}
		
		if ( lIsLeft && lIsRight || ! ( lIsRight || lIsLeft)){
			locks.i = 0;
			curDir.i = 0;
		}else if ( lIsLeft){
			if ( locks.i == -1){
				curDir.i = 0;
			}else{
				locks.i = 0;
				curDir.i = -1;
			}
		}else{
			if ( locks.i == 1){
				curDir.i = 0;
			}else{
				locks.i = 0;
				curDir.i = 1;
			}
		}
		
		if ( lIsUp && lIsDown || ! ( lIsUp || lIsDown)){
			locks.j = 0;
			curDir.j = 0;
		}else if ( lIsUp){
			if ( locks.j == -1){
				curDir.j = 0;
			}else{
				locks.j = 0;
				curDir.j = -1;
			}
		}else{
			if ( locks.j == 1){
				curDir.j = 0;
			}else{
				locks.j = 0;
				curDir.j = 1;
			}
		}
	}
	
	/** @inheritDoc */
	public function destroy() : Void {
		Browser.document.removeEventListener( "keydown", onKeyDown);
		Browser.document.removeEventListener( "keyup", onKeyUp);
		
		locks = null;
		actives = null;
	}
	
	function get_isAction() : Bool { return _isAction; }
	
	function onKeyDown( pE : KeyboardEvent) : Void {
		//trace( "down " + pE.keyCode);
		actives[ pE.keyCode] = true;
		
		if ( pE.keyCode == 37 || pE.keyCode == 38 || pE.keyCode == 39 || pE.keyCode == 40 || pE.keyCode == 32) pE.preventDefault();
	}
	
	function onKeyUp( pE : KeyboardEvent) : Void {
		//trace( "up " + pE.keyCode);
		actives[ pE.keyCode] = false;
	}
}