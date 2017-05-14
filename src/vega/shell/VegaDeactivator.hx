package vega.shell;
import js.Browser;
import js.html.VisibilityState;
import vega.sound.SndMgr;

/**
 * ...
 * @author ...
 */
class VegaDeactivator {
	var TIMEOUT_DELAY							: Int									= 120000;//600000;
	
	static var instance							: VegaDeactivator						= null;
	
	var _isActive								: Bool									= true;
	public var isActive( get, null)				: Bool;
	
	//var timeoutId								: Int;
	var timeoutTimeStamp						: Float									= -1;
	
	var listeners								: Array<Bool->Void>						= null;
	
	public static function getInstance( pTimeout : Int = -1) : VegaDeactivator {
		if ( instance == null) instance = new VegaDeactivator( pTimeout);
		
		return instance;
	}
	
	public static function isInstance() : Bool { return instance != null; }
	
	public function addListener( pListener : Bool -> Void) : Void { listeners.push( pListener); }
	public function remListener( pListener : Bool -> Void) : Void { listeners.remove( pListener); }
	
	function new( pTimeout : Int = -1) {
		listeners = [];
		
		if ( pTimeout >= 0) TIMEOUT_DELAY = pTimeout;
		
		if ( Browser.supported){
			// ne marche pas partout (android)
			Browser.window.onfocus	= activate;
			Browser.window.onblur	= deactivate;
			
			Browser.document.addEventListener( "visibilitychange", onVChange);
			
			if ( ( ! isSystemActive()) || ! Browser.document.hasFocus()) deactivate( false);
			
			onFocus();
		} else ApplicationMatchSize.instance.traceDebug( "ERROR : VegaDeactivator::VegaDeactivator : no browser, ignore deactivate ...");
	}
	
	function onVChange() : Void {
		if ( isSystemActive()) activate();
		else deactivate();
	}
	
	function isSystemActive() : Bool { return Browser.document.visibilityState == VisibilityState.VISIBLE; }
	
	function deactivate( pSetTimeout : Bool = true) : Void {
		if ( ! _isActive) return;
		
		ApplicationMatchSize.instance.traceDebug( "INFO : VegaDeactivator::deactivate");
		
		_isActive = false;
		
		VegaFramer.getInstance().switchPause( true);
		
		ApplicationMatchSize.instance.forceFPS( 1);
		ApplicationMatchSize.instance.pauseRendering();
		
		SndMgr.getInstance().switchMute( true);
		
		if( pSetTimeout){
			timeoutTimeStamp	= Date.now().getTime();
			//timeoutId			= Browser.window.setTimeout( onTimeout, TIMEOUT_DELAY);
		}else{
			timeoutTimeStamp	= -1;
		}
		
		ApplicationMatchSize.instance.canvas.addEventListener( "mousedown", onFocus);
		ApplicationMatchSize.instance.canvas.addEventListener( "mousemove", onFocus);
		ApplicationMatchSize.instance.canvas.addEventListener( "touchstart", onFocus);
		ApplicationMatchSize.instance.canvas.addEventListener( "touchmove", onFocus);
		
		callListeners( true);
	}
	
	function activate() : Void {
		if ( _isActive) return;
		
		if ( timeoutTimeStamp >= 0 && Date.now().getTime() - timeoutTimeStamp >= TIMEOUT_DELAY) onTimeout();
		else{		
			ApplicationMatchSize.instance.traceDebug( "INFO : VegaDeactivator::activate");
			
			_isActive = true;
			
			VegaFramer.getInstance().switchPause( false);
			
			ApplicationMatchSize.instance.restaureFPS();
			ApplicationMatchSize.instance.resumeRendering();
			ApplicationMatchSize.instance.refreshRender();
			
			SndMgr.getInstance().switchMute( false);
			
			if ( GlobalPointer.instance != null) GlobalPointer.instance.flush();
			
			VegaOrient.getInstance().flush();
			
			//if ( timeoutTimeStamp >= 0) Browser.window.clearTimeout( timeoutId);
			
			ApplicationMatchSize.instance.canvas.removeEventListener( "mousedown", onFocus);
			ApplicationMatchSize.instance.canvas.removeEventListener( "mousemove", onFocus);
			ApplicationMatchSize.instance.canvas.removeEventListener( "touchstart", onFocus);
			ApplicationMatchSize.instance.canvas.removeEventListener( "touchmove", onFocus);
			
			callListeners( false);
		}
	}
	
	function onTimeout() : Void { ApplicationMatchSize.instance.reload(); }
	
	function onFocus() : Void { Browser.window.focus(); }
	
	function get_isActive() : Bool { return _isActive; }
	
	function callListeners( pIsDeactivate : Bool) : Void {
		var lClone		: Array<Bool->Void>	= listeners.copy();
		var lListener	: Bool->Void;
		
		for ( lListener in lClone) if ( listeners.indexOf( lListener) != -1) lListener( pIsDeactivate);
	}
}