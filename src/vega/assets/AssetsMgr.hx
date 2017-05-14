package vega.assets;
import haxe.Json;
import vega.loader.VegaLoader;
import vega.loader.VegaLoaderMgr;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;
import vega.shell.VegaFramer;

/**
 * ...
 * @author nico
 */
class AssetsMgr {
	public static inline var VOID_ASSET				: String						= "asset_vide";
	
	public static var instance						: AssetsMgr;
	
	public var sharedProperties						: AssetsSharedProperties;
	
	var voidAsset									: AssetDescVoid;
	
	var assets										: Map<String,AssetDesc>;
	var vars										: Map<String,AssetVarDesc>		= null;
	var groups										: Map<String,AssetGroupDesc>;
	
	var notifyMallocAssets							: INotifyMallocAssets;
	
	var mallocStack									: Array<AssetDesc>;
	var mallocNbAssets								: Int;
	var mallocLimitTime								: Int							= 500;
	
	public function new() { instance = this; }
	
	public function init( pConfig : Dynamic) : Void {
		assets		= new Map<String,AssetDesc>();
		groups		= new Map<String,AssetGroupDesc>();
		voidAsset	= new AssetDescVoid( null, null, this);
		
		parseGlobal( pConfig.assets);
		parseGroups( pConfig.assets);
		
		voidAsset.malloc();
	}
	
	public function getAssetInstance( pId : String) : AssetInstance {
		if( pId != VOID_ASSET) return assets[ pId].getAssetInstance();
		else return voidAsset.getAssetInstance();
	}
	
	public function getVar( pId : String) : AssetVarDesc { return vars[ pId]; }
	
	/**
	 * ajoute une variable d'assets ; si utilisée pré init, permet d'être pris en compte pour la collection d'assets déduite ; si post, pas d'effet sur la collection
	 * @param	pVar	config de variable : { "id" : <id_variable>, "value" : <valeurs_de_la_variable>}
	 */
	public function addVar( pVar : Dynamic) : Void {
		var lVar	: AssetVarDesc;
		
		if ( vars == null) vars = new Map<String,AssetVarDesc>();
		
		lVar = new AssetVarDesc( pVar);
		
		vars[ lVar.id] = lVar;
	}
	
	/**
	 * on récupère un descripteur d'asset à partir de son id
	 * @param	pId	id d'asset
	 * @return	descripteur d'asset correspondant, ou null si inexistant
	 */
	public function getAssetDescById( pId : String) : AssetDesc {
		if ( assets.exists( pId)) return assets[ pId];
		else return null;
	}
	
	public function loadAssets( pLoader : VegaLoader, pPatterns : Array<PatternAsset> = null) : VegaLoader {
		var lLoadControl	: Map<String,MyFile>	= new Map<String,MyFile>();
		var lI				: Int;
		
		if ( pPatterns != null){
			lI = 0;
			while ( lI < pPatterns.length){
				loadPatternAsset( pLoader, pPatterns[ lI], lLoadControl);
				
				lI++;
			}
		}else loadPatternAsset( pLoader, null, lLoadControl);
		
		return pLoader;
	}
	
	public function mallocAssets( pNotifyMalloc : INotifyMallocAssets, pPatterns : Array<PatternAsset> = null) : Void {
		var lMallocControl	: Map<String,AssetDesc>	= new Map<String,AssetDesc>();
		var lI				: Int;
		var lJ				: Int;
		
		notifyMallocAssets	= pNotifyMalloc;
		mallocStack			= new Array<AssetDesc>();
		
		if ( pPatterns != null){
			lI = 0;
			while ( lI < pPatterns.length){
				mallocPatternAsset( pPatterns[ lI], lMallocControl);
				
				lI++;
			}
		}else mallocPatternAsset( null, lMallocControl);
		
		if( pNotifyMalloc != null){
			mallocNbAssets	= mallocStack.length;
			
			VegaFramer.getInstance().addIterator( doMallocIteration);
		}else{
			while( mallocStack.length > 0){
				if( mallocStack[ 0].malloc()) mallocStack.shift();
			}
			
			mallocStack = null;
		}
	}
	
	/**
	 * on libère la mémoire occupée par les instances d'assets préchargés
	 * 
	 * attention, on suppose que les instances d'assets utilisées ont été libérées et remises en mémoire
	 * 
	 * @param	pPatterns		liste de patterns (PatternAsset) pour désigner un ensemble de patterns à libérer ; pour désigner TOUS les assets, laisser null
	 */
	public function freeAssets( pPatterns : Array<PatternAsset> = null) : Void {
		var lPat	: PatternAsset;
		
		if ( pPatterns != null) {
			for ( lPat in pPatterns) freePatternAsset( lPat);
		}else freePatternAsset( null);
		
		//MySystem.gc();
	}
	
	/**
	 * on décharge les fichiers d'assets
	 * 
	 * attention, on suppose que les assets dont on cherche à décharger les fichiers associés ont été préalablement libérés.
	 * attention, cette méthode ne libère que les fichiers dont on est sûr qu'aucun asset en cours ne dépend : si d'autres assets
	 * que ceux spécifiés en pattern de recherche sont toujours alloués en mémoire, et qu'ils partagent des fichiers de ressources,
	 * alors ces fichiers de ressources communs ne seront pas déchargés.
	 * attention, risque de foirage si il y a des ressources externes à cette instance d'AssetMgr qui dépendent de fichiers qu'on va décharger.
	 * pour résoudre ce soucis de dépendances externes, on peut spécifier une liste de LoadingFile à ignorer.
	 * 
	 * @param	pIgnoreFile	map de LoadingFile à ignorer lors de la décharge de fichiers ; indexée par chaîne identifiante de MyFile (MyFile::id) ; null si pas de liste
	 * @param	pPatterns	liste variable de patterns (PatternAsset) pour désigner un ensemble de patterns à rechercher ; on peut aussi passer des Array de PatternAsset ; pour désigner TOUS les assets, ne rien préciser ici
	 */
	public function unloadAssets( pIgnoreFile : Map<String,MyFile>, pPatterns : Array<PatternAsset>) : Void {
		var lPat	: PatternAsset;
		var lAsset	: AssetDesc;
		var lFile	: MyFile;
		
		if ( pIgnoreFile == null) pIgnoreFile = new Map<String,MyFile>();
		
		for ( lAsset in assets) {
			if ( lAsset.isMalloc()) {
				lFile = lAsset.getFile();
				
				if ( lFile != null) pIgnoreFile[ lFile.getId()] = lFile;
			}
		}
		
		if ( pPatterns != null) {
			for( lPat in pPatterns) unloadPatternAsset( lPat, pIgnoreFile);
		}else unloadPatternAsset( null, pIgnoreFile);
		
		//MySystem.gc();
	}
	
	function doMallocIteration( pTime : Float) : Void {
		var lNotify		: INotifyMallocAssets	= notifyMallocAssets;
		var lStartTime	: Float;
		
		if ( mallocStack != null){
			lStartTime	= Date.now().getTime();
			
			do{
				lNotify.onMallocAssetsProgress( mallocNbAssets - mallocStack.length, mallocNbAssets);
				
				if ( mallocStack.length == 0){
					VegaFramer.getInstance().remIterator( doMallocIteration);
					
					mallocStack			= null;
					notifyMallocAssets	= null;
					lNotify.onMallocAssetsEnd();
					
					break;
				}else{
					if ( mallocStack[ 0].malloc()) mallocStack.shift();
					else break;
				}
			}while( Date.now().getTime() - lStartTime < mallocLimitTime);
		}
	}
	
	public function addGroup( pId : String) : AssetGroupDesc {
		var lGroup : AssetGroupDesc;
		
		if( groups.exists( pId)) return groups[ pId];
		else{
			lGroup			= new AssetGroupDesc();
			lGroup.id		= pId;
			groups[ pId]	= lGroup;
			
			return lGroup;
		}
	}
	
	/**
	 * on ajoute un descripteur d'asset
	 * @param	pADesc	descripteur d'asset à ajouter
	 * @param	pGDesc	descripteur de groupe auquel l'asset appartient, ou null si non spécifié
	 */
	public function addAsset( pADesc : AssetDesc) : Void { assets[ pADesc.id] = pADesc; }
	
	/**
	 * on libère la mémoire occupée par les instances d'assets désignées par un pattern de recherche d'assets
	 * @param	pPattern	pattern de recherche d'assets, ou null pour tout prendre
	 */
	function freePatternAsset( pPattern : PatternAsset) : Void {
		var lAsset	: AssetDesc;
		
		for( lAsset in assets){
			if ( pPattern == null || pPattern.match( lAsset)) {
				lAsset.free();
			}
		}
	}
	
	/**
	 * on décharge les fichiers des assets correspondant au pattern de recherche spécifié, et on libère leur domaine
	 * 
	 * on ne va effectivement décharger que les fichiers des assets rencontrés qui ne sont plus alloués
	 * en mémoire (pas marqués comme "actifs" : voir AssetDesc::isMalloc)
	 * 
	 * @param	pPattern		pattern de recherche d'assets, ou null pour tout prendre
	 * @param	pControlFile	liste d'exclusion ou de fichier déjà traité indexée par id de MyFile (MyFile::id)
	 */
	function unloadPatternAsset( pPattern : PatternAsset, pControlFile : Map<String,MyFile>) : Void {
		var lI		: String;
		var lAsset	: AssetDesc;
		var lFile	: MyFile;
		
		for( lAsset in assets){
			if( ( ! lAsset.isMalloc()) && ( pPattern == null || pPattern.match( lAsset))){
				lFile = lAsset.getFile();
				
				if( lFile != null){
					if( ! pControlFile.exists( lFile.getId())){
						pControlFile[ lFile.getId()] = lFile;
						
						VegaLoaderMgr.getInstance().freeLoadedFileMem( lFile);
					}
				}
			}
		}
	}
	
	function mallocPatternAsset( pPattern : PatternAsset, pControl : Map<String,AssetDesc>) : Void {
		var lI		: String;
		var lAsset	: AssetDesc;
		
		for( lI in assets.keys()){
			lAsset = assets[ lI];
			
			if( ( pControl[ lI] == null) && ( ( pPattern == null) || pPattern.match( lAsset))){
				pControl[ lI] = lAsset;
				mallocStack.push( lAsset);
			}
		}
	}
	
	function loadPatternAsset( pLoader : VegaLoader, pPattern : PatternAsset, pLoadControl : Map<String,MyFile>) : Void {
		var lI		: String;
		var lAsset	: AssetDesc;
		var lFile	: MyFile;
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : AssetsMgr::loadPatternAsset ...");
		
		for( lI in assets.keys()){
			lAsset = assets[ lI];
			
			if( ( pPattern == null) || pPattern.match( lAsset)){
				lFile = lAsset.getFile();
				if( ( lFile != null) && ! pLoadControl.exists( lFile.getId())){
					pLoadControl[ lFile.getId()] = lFile;
					
					//ApplicationMatchSize.instance.traceDebug( "INFO : AssetsMgr::loadPatternAsset : addFile " + lFile.getId());
					
					if ( lAsset.getRender().render == AssetRender.RENDER_FLUMP) pLoader.addFlumpFile( lFile);
					else pLoader.addDisplayFile( lFile);
				}
			}
		}
	}
	
	function parseAssets( pConfig : Dynamic, pParent : AssetGroupDesc = null) : Void {
		var lAssets	: Array<Dynamic>	= pConfig.assets;
		var lI		: Int;
		var lIPool	: Int;
		var lLPool	: Int;
		var lAsset	: Dynamic;
		var lPool	: VarPool;
		var lAssetD	: AssetDesc;
		
		if( lAssets != null){
			lI = 0;
			while ( lI < lAssets.length){
				lAsset	= lAssets[ lI];
				lPool	= getVarPool( lAsset);
				lLPool	= lPool.getLen();
				
				lIPool = 0;
				while ( lIPool < lLPool){
					lAssetD				= new AssetDesc( lPool.substituteVars( lAsset, lIPool), pParent, this);
					assets[ lAssetD.id]	= lAssetD;
					
					lIPool++;
				}
				
				lI++;
			}
		}
	}
	
	function parseGroups( pConfig : Dynamic, pParent : AssetGroupDesc = null) : Void {
		var lGroups	: Array<Dynamic>	= pConfig.groups;
		var lGroup	: Dynamic;
		var lAGroup	: AssetGroupDesc;
		var lI		: Int;
		
		parseAssets( pConfig, pParent);
		
		if( lGroups != null){
			lI = 0;
			while ( lI < lGroups.length){
				lGroup				= lGroups[ lI];
				lAGroup				= new AssetGroupDesc( lGroup, pParent);
				
				if( groups[ AssetGroupDesc.getId( lGroup)] != null){
					lAGroup = groups[ AssetGroupDesc.getId( lGroup)];
					lAGroup.setConfig( lGroup, pParent);
				}else{
					lAGroup = new AssetGroupDesc( lGroup, pParent);
					groups[ lAGroup.id] = lAGroup;
				}
				
				parseGroups( lGroup, lAGroup);
				
				lI++;
			}
		}
	}
	
	function parseGlobal( pConfig : Dynamic) : Void {
		sharedProperties = new AssetsSharedProperties( pConfig);
		
		if ( sharedProperties.render == null) sharedProperties.render = new AssetRender( null);
		if ( sharedProperties.instanceCount < 0) sharedProperties.instanceCount = 1;
		if ( sharedProperties.lockInstance == AssetsSharedProperties.LOCKER_UNDEFINED) sharedProperties.lockInstance = AssetsSharedProperties.LOCKER_UNLOCKED;
		
		buildVars( pConfig);
	}
	
	function buildVars( pConfig : Dynamic) : Void {
		var lVars	: Array<Dynamic>	= pConfig.vars;
		var lVar	: AssetVarDesc;
		var lI		: Int;
		
		if( vars == null) vars = new Map<String,AssetVarDesc>();
		
		if ( lVars != null){
			lI = 0;
			while ( lI < lVars.length){
				lVar = new AssetVarDesc( lVars[ lI]);
				
				vars[ lVar.id] = lVar;
				
				lI++;
			}
		}
	}
	
	function getVarPool( pNode : Dynamic) : VarPool {
		var lStr	: String		= Json.stringify( pNode);
		var lPool	: VarPool		= new VarPool();
		var lDesc	: AssetVarDesc;
		
		for( lDesc in vars){
			if( lStr.indexOf( lDesc.id) >= 0) lPool.addVar( vars[ lDesc.id]);
		}
		
		return lPool;
	}
}