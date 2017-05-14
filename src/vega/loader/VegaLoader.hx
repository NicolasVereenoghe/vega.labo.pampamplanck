package vega.loader;
import haxe.Constraints.Function;
import vega.loader.file.LoadingFile;
import vega.loader.file.LoadingFileDisplay;
import vega.loader.file.LoadingFileFlump;
import vega.loader.file.LoadingFileFont;
import vega.loader.file.LoadingFileHowl;
import vega.loader.file.LoadingFileTxt;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;
import vega.sound.SndDesc;

/**
 * ...
 * @author nico
 */
class VegaLoader {
	var fileLoads									: Array<LoadingFile>;
	
	var listener									: IVegaLoaderListener;
	
	var currentLoadedFileI							: Int;
	
	public function new() {
		fileLoads			= new Array();
		currentLoadedFileI	= 0;
	}
	
	public function destroy() {
		var lI		: Int;
		
		if ( fileLoads != null) {
			
			lI = currentLoadedFileI;
			while ( lI < fileLoads.length){
				fileLoads[ lI++].free();
			}
		}
		
		fileLoads	= null;
		listener	= null;
	}
	
	public function addFlumpFile( pFile : MyFile) : Void { fileLoads.push( new LoadingFileFlump( pFile)); }
	
	public function addDisplayFile ( pFile : MyFile) : Void { fileLoads.push( new LoadingFileDisplay( pFile)); }
	
	public function addTxtFile( pFile : MyFile) : Void { fileLoads.push( new LoadingFileTxt( pFile)); }
	
	public function addFontFile( pFontId : String, pFontCss : MyFile) : Void { fileLoads.push( new LoadingFileFont( pFontId, pFontCss)); }
	
	public function addHowlFile( pSndDesc : SndDesc) : Void { fileLoads.push( new LoadingFileHowl( pSndDesc)); }
	
	public function load( pListener : IVegaLoaderListener) : Void {
		listener = pListener;
		
		currentLoadedFileI	= -1;
		
		loadNext();
	}
	
	public function getProgressRate() : Float { return currentLoadedFileI / fileLoads.length; }
	
	public function onCurFileLoaded( pDoRegister : Bool = true) : Void {
		var lLoadedFile	: LoadingFile	= fileLoads[ currentLoadedFileI];
		
		ApplicationMatchSize.instance.traceDebug( "INFO : VegaLoader::onCurFileLoaded : " + lLoadedFile.getId());
		
		if( pDoRegister) VegaLoaderMgr.getInstance().regLoadedFile( lLoadedFile);
		
		notifyLoadCurrentFileComplete();
		
		loadNext();
	}
	
	function loadNext() : Void {
		var lCurLoad	: LoadingFile;
		
		if( fileLoads != null){
			currentLoadedFileI++;
			
			if( currentLoadedFileI < fileLoads.length){
				lCurLoad = fileLoads[ currentLoadedFileI];
				
				if( VegaLoaderMgr.getInstance().isAlreadyLoaded( lCurLoad.getId())){
					ApplicationMatchSize.instance.traceDebug( "WARNING : VegaLoader::loadNext : " + lCurLoad.getId() + " : already loaded, next" );
					
					notifyLoadCurrentFileComplete();
					
					loadNext();
				}else{
					ApplicationMatchSize.instance.traceDebug( "INFO : VegaLoader::loadNext : " + lCurLoad.getId());
					
					lCurLoad.load( this);
				}
			}else finalizeLoading();
		}
	}
	
	function notifyLoadCurrentFileComplete() : Void { listener.onCurrentFileLoaded( this); }
	
	function notifyLoadComplete() : Void { listener.onLoadComplete( this); }
	
	function finalizeLoading() : Void {
		notifyLoadComplete();
		
		destroy();
	}
}