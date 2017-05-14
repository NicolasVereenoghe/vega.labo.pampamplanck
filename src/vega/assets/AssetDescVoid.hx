package vega.assets;

/**
 * ...
 * @author nico
 */
class AssetDescVoid extends AssetDesc {
	public function new( pConf : Dynamic, pParent : AssetGroupDesc, pMgr : AssetsMgr) {
		super( pConf, pParent, pMgr);
		
		id					= AssetsMgr.VOID_ASSET;
		export				= null;
		sharedProperties	= new AssetsSharedProperties( null);
		groups				= new Map<String,AssetGroupDesc>();
		
		sharedProperties.instanceCount	= 0;
		sharedProperties.lockInstance	= AssetsSharedProperties.LOCKER_LOCKED;
		sharedProperties.render			= new AssetRender( null);
		sharedProperties.mapMode		= AssetsSharedProperties.MAP_NO;
	}
}