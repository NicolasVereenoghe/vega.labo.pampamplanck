package vega.loader;
import vega.loader.file.LoadingFile;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class VegaLoaderMgr {
	static var instance						: VegaLoaderMgr				= null;
	
	var loadedFiles							: Map<String,LoadingFile>;
	
	public static function getInstance() : VegaLoaderMgr {
		if( instance == null) instance = new VegaLoaderMgr();
		
		return instance;
	}
	
	public function new() {
		loadedFiles = new Map<String,LoadingFile>();
	}
	
	public function getLoadingFile( pFileId : String) : LoadingFile {
		if( isAlreadyLoaded( pFileId)) return loadedFiles[ pFileId];
		else return null;
	}
	
	public function isAlreadyLoaded( pFileId : String) : Bool { return ( loadedFiles[ pFileId] != null); }
	
	public function regLoadedFile( pLoadedFile : LoadingFile) : Void {
		if( loadedFiles.exists( pLoadedFile.getId())) ApplicationMatchSize.instance.traceDebug( "WARNING : VegaLoaderMgr::regLoadedFile : file already exists " + pLoadedFile.getId() + ", ignore");
		else loadedFiles[ pLoadedFile.getId()] = pLoadedFile;
	}
	
	/**
	 * libère la mémoire allouée à un fichier chargé
	 * @param	pFile	descripteur de fichier
	 */
	public function freeLoadedFileMem( pFile : MyFile) : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : VegaLoaderMgr::freeLoadedFileMem : " + pFile.getId());
		
		loadedFiles[ pFile.getId()].free();
		loadedFiles.remove( pFile.getId());
		
		//MySystem.gc();
	}
}