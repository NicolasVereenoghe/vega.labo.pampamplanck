package vega.assets;
import vega.loader.file.MyFile;

/**
 * ...
 * @author nico
 */
class AssetsSharedProperties {
	public static inline var LOCKER_UNLOCKED	: String				= "unlock_instance";
	public static inline var LOCKER_LOCKED		: String				= "lock_instance";
	public static inline var LOCKER_UNDEFINED	: String				= "lock_undefined";
	
	public static inline var MAP_NO				: String				= "map_no";
	public static inline var MAP_YES			: String				= "map_yes";
	public static inline var MAP_UNDEFINED		: String				= "map_undefined";
	
	public var file								: MyFile;
	
	public var render							: AssetRender;
	/** map de clefs auxquelles correspondent des valeurs ; instance de map vide si aucune clef-valeur */
	public var datas							: Map<String,String>;
	
	/** est-ce qu'on génère une map de pixels ? MAP_YES ? MAP_NO ? ou MAP_UNDEFINED ? */
	public var mapMode							: String;
	
	public var instanceCount					: Int;
	public var lockInstance						: String;
	
	public function new( pConfig : Dynamic) {
		file			= pConfig != null ? parseFile( pConfig) : null;
		
		render			= pConfig != null ? parseRender( pConfig) : null;
		
		instanceCount	= pConfig != null ? parseInstanceCount( pConfig) : -1;
		lockInstance	= pConfig != null ? parseLockInstance( pConfig) : LOCKER_UNDEFINED;
		datas			= pConfig != null ? parseDatas( pConfig) : new Map<String,String>();
		mapMode			= pConfig != null ? parseMapMode( pConfig) : MAP_UNDEFINED;
	}
	
	function parseFile( pNode : Dynamic) : MyFile {
		var lFile	: Dynamic	= pNode.file;
		
		if( lFile != null && lFile.name != null){
			return new MyFile(
				lFile.name,
				lFile.path,
				lFile.version
			);
		}else return null;
	}
	
	function parseRender( pNode : Dynamic) : AssetRender {
		if ( pNode.render != null) return new AssetRender( pNode.render);
		else return null;
	}
	
	function parseInstanceCount( pNode : Dynamic) : Int {
		if( pNode.instance != null) return Std.parseInt( pNode.instance);
		else return -1;
	}
	
	function parseLockInstance( pNode : Dynamic) : String {
		if( pNode.lock_instance != null && pNode.lock_instance != "0") return LOCKER_LOCKED;
		else if( pNode.unlock_instance != null && pNode.unlock_instance != "0") return LOCKER_UNLOCKED;
		else return LOCKER_UNDEFINED;
	}
	
	function parseMapMode( pNode : Dynamic) : String {
		if ( pNode.map != null){
			if ( pNode.map == "1") return MAP_YES;
			else return MAP_NO;
		}else return MAP_UNDEFINED;
	}
	
	/**
	 * construit une map de clef-valeur à partir de la config xml
	 * @param	node xml de config contenant éventuellement un node <datas> de liste de clef-valeur
	 * @return	map de clef-valeur
	 */
	function parseDatas( pNode : Dynamic) : Map<String,String> {
		var lDatas	: Array<Dynamic>		= pNode.datas;
		var lRes 	: Map<String,String>	= new Map<String,String>();
		var lData	: Dynamic;
		
		if ( lDatas != null) {
			for ( lData in lDatas) {
				lRes[ lData.id] = lData.value;
			}
		}
		
		return lRes;
	}
}