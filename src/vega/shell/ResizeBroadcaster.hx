package vega.shell;

/**
 * ...
 * @author nico
 */
class ResizeBroadcaster {
	var listeners						: Array<Void -> Void>;
	
	static var instance					: ResizeBroadcaster					= null;
	
	public static function getInstance() : ResizeBroadcaster {
		if ( instance == null) instance = new ResizeBroadcaster();
		
		return instance;
	}
	
	function new() { listeners = new Array<Void -> Void>(); }
	
	public function addListener( pListener : Void -> Void) : Void { listeners.push( pListener); }
	
	public function remListener( pListener : Void -> Void) : Void { listeners.remove( pListener); }
	
	public function broadcastResize() : Void {
		var lListener	: Void -> Void;
		
		for ( lListener in listeners) lListener();
	}
}