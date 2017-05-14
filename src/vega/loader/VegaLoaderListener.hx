package vega.loader;
import haxe.Constraints.Function;
import vega.loader.VegaLoader;

/**
 * ...
 * @author nico
 */
class VegaLoaderListener implements IVegaLoaderListener {
	var _onLoadComplete								: VegaLoader -> Void;
	var _onLoadProgress								: VegaLoader -> Void;
	var _onCurrentFileLoaded						: VegaLoader -> Void;
	var _onLoadError								: VegaLoader -> Void;
	
	public function new( pOnLoadComplete : VegaLoader -> Void, pOnLoadProgress : VegaLoader -> Void = null, pOnCurrentFileLoaded : VegaLoader -> Void = null, pOnLoadError : VegaLoader -> Void = null) {
		_onLoadComplete			= pOnLoadComplete;
		_onLoadProgress			= pOnLoadProgress;
		_onCurrentFileLoaded	= pOnCurrentFileLoaded;
		_onLoadError			= pOnLoadError;
	}
	
	public function onLoadProgress( pLoader : VegaLoader) : Void { if ( _onLoadProgress != null) _onLoadProgress( pLoader); }
	
	public function onLoadComplete( pLoader : VegaLoader) : Void {
		if ( _onLoadComplete != null) {
			_onLoadComplete( pLoader);
			
			_onLoadComplete			= null;
			_onLoadProgress			= null;
			_onCurrentFileLoaded	= null;
			_onLoadError			= null;
		}
	}
	
	public function onCurrentFileLoaded( pLoader : VegaLoader) : Void { if ( _onCurrentFileLoaded != null) _onCurrentFileLoaded( pLoader); }
	
	public function onLoadError( pLoader : VegaLoader) : Void { if ( _onLoadError != null) _onLoadError( pLoader); }
}