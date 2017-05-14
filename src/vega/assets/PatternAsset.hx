package vega.assets;

/**
 * ...
 * @author nico
 */
class PatternAsset {
	public static inline var FIND_ON_GROUP			: String	= "findOnGroup";
	public static inline var FIND_ON_ID				: String	= "findOnId";
	public static inline var FIND_ON_FILE			: String	= "findOnFile";
	public static inline var FIND_ON_EXPORT			: String	= "findOnExport";
	
	public static inline var MATCH_ALL				: String	= "matchAll";
	public static inline var MATCH_SUBSTR			: String	= "matchSubstr";
	
	var find										: String;
	var typeFind									: String;
	var typeMatch									: String;

	public function new( pFind : String, pTypeFind : String = FIND_ON_ID, pTypeMatch : String = MATCH_SUBSTR) {
		find		= pFind;
		typeFind	= pTypeFind;
		typeMatch	= pTypeMatch;
	}
	
	public function match( pAsset : AssetDesc) : Bool {
		var lDesc	: AssetGroupDesc;
		
		if ( typeFind == FIND_ON_GROUP){
			for ( lDesc in pAsset.groups){
				if( matchGroup( lDesc)) return true;
			}
		}else if( typeFind == FIND_ON_ID) return cmpStr( pAsset.id);
		else if( typeFind == FIND_ON_FILE) return cmpStr( pAsset.getFile().getId());
		else if( typeFind == FIND_ON_EXPORT) return cmpStr( pAsset.export);
		
		return false;
	}
	
	function matchGroup( pGroup : AssetGroupDesc) : Bool {
		if( pGroup == null) return false;
		else if( cmpStr( pGroup.id)) return true;
		else return matchGroup( pGroup.parent);
	}
	
	function cmpStr( pStr : String) : Bool {
		if( typeMatch == MATCH_ALL) return pStr == find;
		else return ( pStr != null) && ( pStr.indexOf( find) >= 0);
	}
}