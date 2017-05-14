package vega.assets;
import vega.loader.file.MyFile;

/**
 * ...
 * @author nico
 */
class AssetGroupDesc {
	public var id				: String;
	public var parent			: AssetGroupDesc;
	
	public var childs			: Map<String,AssetGroupDesc>;
	public var assets			: Map<String,AssetDesc>;
	
	public var sharedProperties	: AssetsSharedProperties;
	
	public function new( pConfig : Dynamic = null, pParent : AssetGroupDesc = null) {
		id		= pConfig != null ? getId( pConfig) : null;
		
		childs	= new Map<String,AssetGroupDesc>();
		assets	= new Map<String,AssetDesc>();
		
		setConfig( pConfig, pParent);
	}
	
	public static function getId( pConfig : Dynamic) : String { return pConfig.id; }
	
	public function setConfig( pConfig : Dynamic, pParent : AssetGroupDesc) : Void {
		sharedProperties	= new AssetsSharedProperties( pConfig);
		parent				= pParent;
		
		if( pParent != null) pParent.childs[ id] = this;
	}
	
	public function getFile() : MyFile {
		if( sharedProperties.file != null) return sharedProperties.file;
		else if( parent != null) return parent.getFile();
		else return null;
	}
	
	public function getInstanceCount() : Int {
		if( sharedProperties.instanceCount >= 0) return sharedProperties.instanceCount;
		else if( parent != null) return parent.getInstanceCount();
		else return -1;
	}
	
	public function getLockInstance() : String {
		if( sharedProperties.lockInstance != AssetsSharedProperties.LOCKER_UNDEFINED) return sharedProperties.lockInstance;
		else if( parent != null) return parent.getLockInstance();
		else return AssetsSharedProperties.LOCKER_UNDEFINED;
	}
	
	public function getRender() : AssetRender {
		if( sharedProperties.render != null) return sharedProperties.render;
		else if( parent != null) return parent.getRender();
		else return null;
	}
	
	public function getMapMode() : String {
		if ( sharedProperties.mapMode != AssetsSharedProperties.MAP_UNDEFINED) return sharedProperties.mapMode;
		else if ( parent != null) return parent.getMapMode();
		else return AssetsSharedProperties.MAP_UNDEFINED;
	}
	
	/**
	 * on récupère une valeur définie en "datas" pour les membres de ce groupe et correspondant à la clef passée ; si info pas définie, on cherche dans le parent
	 * @param	pId		clef de la valeur cherchée dans les datas de cet asset
	 * @return	valeur correspondante, ou null si rien de défini
	 */
	public function getData( pId : String) : String {
		if( sharedProperties.datas.exists( pId)) return sharedProperties.datas[ pId];
		else if( parent != null) return parent.getData( pId);
		else return null;
	}
}