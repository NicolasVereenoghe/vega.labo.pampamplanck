package vega.loader;

/**
 * @author nico
 */
interface IVegaLoaderListener {
	function onLoadProgress( pLoader : VegaLoader) : Void;
	
	function onLoadComplete( pLoader : VegaLoader) : Void;
	
	function onCurrentFileLoaded( pLoader : VegaLoader) : Void;
	
	function onLoadError( pLoader : VegaLoader) : Void;
}