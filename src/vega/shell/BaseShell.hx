package vega.shell;
import haxe.Json;
import pixi.core.display.Container;
import vega.assets.AssetsMgr;
import vega.assets.NotifyMallocAssets;
import vega.assets.PatternAsset;
import vega.loader.VegaLoader;
import vega.loader.VegaLoaderListener;
import vega.loader.VegaLoaderMgr;
import vega.loader.file.MyFile;
import vega.local.LocalMgr;
import vega.screen.MyScreen;
import vega.screen.MyScreenInitLoad;
import vega.screen.MyScreenLoad;
import vega.screen.MyScreenMain;
import vega.screen.MyScreenPreload;
import vega.screen.MyScreenSplash;

/**
 * ...
 * @author nico
 */
class BaseShell implements IShell {
	var _assetsFile								: MyFile;
	var _localFile								: MyFile;
	var _fonts									: Dynamic;
	
	var _container								: Container;
	var _containerScr							: Container;
	
	var curScreen								: MyScreen;
	var isCurScreenReady						: Bool					= true;
	var prevScreen								: MyScreen;
	
	var isLocked								: Bool					= false;
	
	var isAssetsMainReady						: Bool					= false;
	
	public function new() { }
	
	public function init( pCont : Container, pFileAssets : MyFile, pFileLocal : MyFile, pFonts : Dynamic) : Void {
		_container		= pCont;
		
		_assetsFile		= pFileAssets;
		_localFile		= pFileLocal;
		_fonts			= pFonts;
		
		_containerScr	= cast _container.addChild( new Container());
		
		initPreLoad();
		
		VegaFramer.getInstance().addIterator( doFrame);
	}
	
	public function onScreenReady( pScreen : MyScreen) : Void {
		isCurScreenReady = true;
		
		switchLock( false);
		
		if ( prevScreen == null){
			pScreen.start();
			
			if ( Std.is( pScreen, MyScreenInitLoad) && isAssetsMainReady) cast( pScreen, MyScreenInitLoad).onLoadComplete();
		}
	}
	
	public function onScreenClose( pScreen : MyScreen, pNext : MyScreen = null) : Void {
		if ( Std.is( pScreen, MyScreenPreload)){
			pNext = getScreenSplash();
			
			onShellReadyMini();
		}else if ( Std.is( pScreen, MyScreenSplash)){
			pNext = getScreenInitLoad();
		}
		
		prevScreen = pScreen;
		
		switchLock( true);
		
		setCurScreen( pNext);
		
		if ( Std.is( pScreen, MyScreenInitLoad)){
			onShellReadyMain();
		}
	}
	
	public function onScreenEnd( pScreen : MyScreen) : Void {
		prevScreen = null;
		
		pScreen.destroy();
		
		if ( isCurScreenReady && curScreen != null){
			curScreen.start();
			
			if ( Std.is( curScreen, MyScreenInitLoad) && isAssetsMainReady) cast( curScreen, MyScreenInitLoad).onLoadComplete();
		}
		
		switchLock( false);
	}
	
	public function switchLock( pIsLock : Bool) : Void {
		if ( pIsLock){
			ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::switchLock : interactiveChildren : " + _container.interactiveChildren + " -> " + ( ! pIsLock));
			
			isLocked = true;
			
			_container.interactiveChildren = false;
		}else if ( prevScreen == null && curScreen == null || prevScreen == null && isCurScreenReady){
			ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::switchLock : interactiveChildren : " + _container.interactiveChildren + " -> " + ( ! pIsLock));
			
			isLocked = false;
			
			_container.interactiveChildren = true;
		}
	}
	
	/** @inheritDoc */
	public function getSavedDatas( pId : String, pForce : Bool = false) : SavedDatas { ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::getSavedDatas : " + pId); return null; }
	
	/** @inheritDoc */
	public function setSavedDatas( pId : String, pDatas : SavedDatas) : Void { ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::setSavedDatas : " + pId); }
	
	function doFrame( pTime : Float) : Void {
		if ( prevScreen != null) prevScreen.doFrame( pTime);
		if ( curScreen != null) curScreen.doFrame( pTime);
	}
	
	function onShellReadyMini() : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::onShellReadyMini");
		
		loadAssetsMain();
	}
	
	function onShellReadyMain() : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : BaseShell::onShellReadyMain");
		
		setCurScreen( getScreenMain());
		
		ApplicationMatchSize.instance.antiFlicker();
	}
	
	function setCurScreen( pScreen : MyScreen) : Void {
		curScreen			= pScreen;
		isCurScreenReady	= false;
		
		if ( curScreen != null) {
			switchLock( true);
			
			curScreen.initScreen( this, addScreenDisplay( curScreen));
		}
	}
	
	function addScreenDisplay( pScreen : MyScreen) : Container { return cast _containerScr.addChildAt( new Container(), 0); }
	
	function initPreLoad( pLoader : VegaLoader = null) : Void {
		var lId		: String;
		
		if ( pLoader == null) pLoader = new VegaLoader();
		
		setCurScreen( getScreenPreload());
		
		pLoader.addTxtFile( _localFile);
		pLoader.addTxtFile( _assetsFile);
		
		for ( lId in Reflect.fields( _fonts)) pLoader.addFontFile( lId, cast( Reflect.getProperty( _fonts, lId), MyFile));
		
		pLoader.load( new VegaLoaderListener( onPreLoadComplete, null, onPreLoadProgess));
	}
	
	function onPreLoadProgess( pLoader : VegaLoader) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( pLoader.getProgressRate() * .5); }
	
	function onPreLoadComplete( pLoader : VegaLoader) : Void {
		instanciateLocalMgr();
		
		instanciateAssetsMgr();
		
		onAssetDescBuilt();
		
		loadAssetsMini();
	}
	
	/**
	 * création du singleton du gestionnaire de localisation
	 */
	function instanciateLocalMgr() : Void { new LocalMgr( VegaLoaderMgr.getInstance().getLoadingFile( _localFile.getId()).getLoadedContent()); }
	
	/**
	 * création du singleton de gestion d'assets
	 */
	function instanciateAssetsMgr() : Void {
		new AssetsMgr();
		
		AssetsMgr.instance.init( VegaLoaderMgr.getInstance().getLoadingFile( _assetsFile.getId()).getLoadedContent());
	}
	
	/**
	 * on est notifié que la description des assets a bien été construite
	 */
	function onAssetDescBuilt() : Void { ApplicationMatchSize.instance.traceDebug( "INFO : ShellDefaultRender::onAssetDescBuilt"); }
	
	function loadAssetsMini( pLoader : VegaLoader = null) : Void {
		if ( pLoader == null) pLoader = new VegaLoader();
		
		AssetsMgr.instance.loadAssets(
			pLoader,
			getAssetsMiniPatterns()
		).load( new VegaLoaderListener( onAssetsMiniLoaded, null, onAssetsMiniProgress));
	}
	
	function onAssetsMiniProgress( pLoader : VegaLoader) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( .5 + pLoader.getProgressRate() * .25); }
	
	function onAssetsMiniLoaded( pLoader : VegaLoader) : Void {
		AssetsMgr.instance.mallocAssets(
			new NotifyMallocAssets( onMallocMiniEnd, onMallocMiniProgress),
			getAssetsMiniPatterns()
		);
	}
	
	function onMallocMiniProgress( pCur : Int, pTotal : Int) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( .75 + ( pCur / pTotal) * .25); }
	
	function onMallocMiniEnd() : Void { cast( curScreen, MyScreenPreload).onLoadComplete(); }
	
	function loadAssetsMain( pLoader : VegaLoader = null) : Void {
		if ( pLoader == null) pLoader = new VegaLoader();
		
		AssetsMgr.instance.loadAssets(
			pLoader,
			getAssetsMainPatterns()
		).load( new VegaLoaderListener( onAssetsMainLoaded, null, onAssetsMainProgress));
	}
	
	function onAssetsMainProgress( pLoader : VegaLoader) : Void { if ( Std.is( curScreen, MyScreenInitLoad) && ! isLocked) cast( curScreen, MyScreenInitLoad).onLoadProgress( pLoader.getProgressRate() * .5); }
	
	function onAssetsMainLoaded( pLoader : VegaLoader) : Void {
		AssetsMgr.instance.mallocAssets(
			new NotifyMallocAssets( onMallocMainEnd, onMallocMainProgress),
			getAssetsMainPatterns()
		);
	}
	
	function onMallocMainProgress( pCur : Int, pTotal : Int) : Void { if( Std.is( curScreen, MyScreenInitLoad) && ! isLocked) cast( curScreen, MyScreenInitLoad).onLoadProgress( .5 + ( pCur / pTotal) * .5); }
	
	function onMallocMainEnd() : Void {
		isAssetsMainReady = true;
		
		if ( Std.is( curScreen, MyScreenInitLoad) && ! isLocked){
			cast( curScreen, MyScreenInitLoad).onLoadComplete();
		}
	}
	
	function getAssetsMiniPatterns() : Array<PatternAsset> { return [ new PatternAsset( "mini", PatternAsset.FIND_ON_GROUP, PatternAsset.MATCH_ALL) ]; }
	function getAssetsMainPatterns() : Array<PatternAsset> { return [ new PatternAsset( "main", PatternAsset.FIND_ON_GROUP, PatternAsset.MATCH_ALL) ]; }
	
	function getScreenPreload() : MyScreenPreload { return new MyScreenPreload(); }
	function getScreenSplash() : MyScreenSplash { return new MyScreenSplash(); }
	function getScreenInitLoad() : MyScreenInitLoad { return new MyScreenInitLoad(); }
	function getScreenMain() : MyScreenMain { return new MyScreenMain(); }
}