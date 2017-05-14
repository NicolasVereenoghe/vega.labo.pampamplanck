package vega.assets;

/**
 * ...
 * @author nico
 */
class AssetRender {
	public static inline var RENDER_FLUMP		: String	= "flump";
	public static inline var RENDER_DEFAULT		: String	= "default";
	
	public static inline var TYPE_FLUMP_MC		: String	= "mc";
	public static inline var TYPE_FLUMP_SP		: String	= "sp";
	
	public var render							: String;
	public var type								: String;
	
	public function new( pNode : Dynamic) {
		if ( pNode != null){
			render = pNode.name;
			
			if ( pNode.type != null) type = pNode.type;
		}else render = RENDER_DEFAULT;
	}
}