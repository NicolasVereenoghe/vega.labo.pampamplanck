package vega.loader.file;
import haxe.Timer;
import pixi.loaders.Loader;
import vega.loader.VegaLoader;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class LoadingFile {
	static var VERSION_PARAM				: String		= "v";
	
	/** nombre max de reloads avant de laisser tomber */
	var RELOAD_MAX							: Int			= 20;
	/** délai max d'attente en ms avant relance du loading échoué  */
	var RELOAD_DELAY_MAX					: Int			= 3000;
	
	/** compteur de tentatives de loading */
	var ctrReload							: Int			= 0;
	
	var _file								: MyFile;
	var vegaLoader							: VegaLoader;
	
	var loader								: Loader;
	
	public function new( pFile : MyFile) {
		_file = pFile;
		
		buildLoader();
	}
	
	public function free() : Void {
		if ( vegaLoader != null) removeLoaderListener();
		
		vegaLoader	= null;
		_file		= null;
		
		freeLoader();
	}
	
	public function getId() : String { return _file.getId(); }
	
	public function load( pLoader : VegaLoader) {
		vegaLoader		= pLoader;
		
		doLoad();
	}
	
	public function getLoadedContent( pId : String = null) : Dynamic {
		if ( loader != null && ! loader.loading && loader.progress > 0){
			return Reflect.getProperty( loader.resources, _file.getId()).data;
		}else return null;
	}
	
	public function isIMG() : Bool { return Reflect.getProperty( loader.resources, _file.getId()).isImage; }
	
	public function isJson() : Bool { return Reflect.getProperty( loader.resources, _file.getId()).isJson != false; }
	
	public function getUrl() : String { return Reflect.getProperty( loader.resources, _file.getId()).url; }
	
	function buildLoader() : Void {
		loader	= new Loader();
		loader.add( _file.getId(), getUrlRequest());
		loader.on( "error", onError);
		loader.on( "complete", onLoadComplete);
	}
	
	function freeLoader() : Void {
		if( loader != null){
			loader.reset();
			
			loader = null;
		}
	}
	
	function doLoad() : Void { loader.load(); }
	
	function removeLoaderListener() : Void {
		loader.removeAllListeners();
	}
	
	function onError() : Void {
		ApplicationMatchSize.instance.traceDebug( "ERROR : LoadingFile::onError : " + _file.getId() + " ( " + ctrReload + ")"/*") : " + Reflect.getProperty( loader.resources, _file.getId()).error*/);
		
		if( ctrReload++ < RELOAD_MAX){
			loader.reset();
			loader.add( _file.getId(), getUrlRequest( true));
			
			Timer.delay( doLoad, RELOAD_DELAY_MAX * Math.round( Math.pow( ctrReload / RELOAD_MAX, 2)));
		}else ApplicationMatchSize.instance.reload();
	}
	
	function onLoadComplete() : Void {
		if ( Reflect.getProperty( loader.resources, _file.getId()).error == null){
			ApplicationMatchSize.instance.traceDebug( "INFO : LoadingFile::onLoadComplete : " + _file.getId());
			trace( Reflect.getProperty( loader.resources, _file.getId()));
			
			removeLoaderListener();
			
			vegaLoader.onCurFileLoaded();
			
			vegaLoader = null;
		}else onError();
	}
	
	function getUrlRequest( pForceNoCache : Bool = false) : String {
		var lName		: String	= _file.getName();
		var lPath		: String	= _file.getPath() != null ? _file.getPath() : "";
		var lUrl		: String;
		
		if( lName.indexOf( "://") != -1) lUrl = lName;
		else lUrl = lPath + lName;
		
		lUrl = addVersionToUrl( lUrl, getVersionUrl( _file, pForceNoCache));
		
		return lUrl;
	}
	
	public static function getVersionUrl( pFile : MyFile, pForceNoCache : Bool = false) : String {
		var lVer	: String	= pFile.getVersion();
		
		if ( lVer != null || pForceNoCache){
			if ( lVer != MyFile.NO_VERSION || pForceNoCache){
				if ( lVer == MyFile.VERSION_NO_CACHE || pForceNoCache) return Std.string( Date.now().getTime());
				else return lVer;
			}
		}
		
		return "";
	}
	
	public static function addVersionToUrl( pUrl : String, pVersion : String) : String {
		if( pVersion != null && pVersion != ""){
			if( pUrl.indexOf( "?") != -1) return pUrl + "&" + VERSION_PARAM + "=" + pVersion;
			else return pUrl + "?" + VERSION_PARAM + "=" + pVersion;
		}
		
		return pUrl;
	}
}