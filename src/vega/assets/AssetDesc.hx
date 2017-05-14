package vega.assets;
import js.html.ImageData;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import pixi.core.renderers.canvas.CanvasRenderer;
import pixi.core.sprites.Sprite;
import pixi.flump.Movie;
import pixi.flump.Sprite;
import vega.loader.VegaLoaderMgr;
import vega.loader.file.MyFile;

/**
 * ...
 * @author nico
 */
class AssetDesc {
	public var id						: String;
	
	public var export					: String;
	
	public var sharedProperties			: AssetsSharedProperties;
	
	public var groups					: Map<String,AssetGroupDesc>;
	
	public var imageData(get, null)		: ImageDataOffset;
	
	var mgr								: AssetsMgr;
	
	var freeInstances					: Array<AssetInstance>;
	var usedInstances					: Map<AssetInstance,AssetInstance>;
	
	var _imageData						: ImageDataOffset						= null;
	
	public function new( pConf : Dynamic, pParent : AssetGroupDesc, pMgr : AssetsMgr) {
		var lGroups	: Array<Dynamic>;
		var lGroup	: AssetGroupDesc;
		var lI		: Int;
		
		mgr			= pMgr;
		
		if ( pConf != null){
			lGroups				= pConf.add_groups;
			id					= pConf.id;
			export				= pConf.export;
			sharedProperties	= new AssetsSharedProperties( pConf);
			groups				= new Map<String,AssetGroupDesc>();
			
			if( pParent != null){
				pParent.assets[ id] = this;
				groups[ pParent.id] = pParent;
			}
			
			if( lGroups != null){
				lI = 0;
				while( lI < lGroups.length){
					lGroup = pMgr.addGroup( lGroups[ lI]);
					lGroup.assets[ id] = this;
					groups[ lGroup.id] = lGroup;
					
					lI++;
				}
			}
		}
	}
	
	public function getAssetInstance() : AssetInstance {
		var lAssetI : AssetInstance;
		
		if( freeInstances.length > 0){
			lAssetI 				= freeInstances.pop();
			usedInstances[ lAssetI]	= lAssetI;
			
			// hack pixi 4 : force texture
			lAssetI.addChild( lAssetI.getContent());
			
			return lAssetI;
		}else{
			lAssetI = generateInstance();
			
			if( getLockInstance() != AssetsSharedProperties.LOCKER_LOCKED){
				usedInstances[ lAssetI] = lAssetI;
			}
			
			return lAssetI;
		}
	}
	
	public function freeAssetInstance( pAssetI : AssetInstance) : Void {
		if ( usedInstances.exists( pAssetI)) {
			usedInstances.remove( pAssetI);
			freeInstances.push( pAssetI);
		}else{
			pAssetI.destroy();
		}
	}
	
	public function getFile() : MyFile {
		var lDesc	: AssetGroupDesc;
		var lFile	: MyFile;
		
		if( sharedProperties.file != null) return sharedProperties.file;
		else{
			for( lDesc in groups){
				lFile = lDesc.getFile();
				
				if( lFile != null) return lFile;
			}
		}
		
		return mgr.sharedProperties.file;
	}
	
	/**
	 * on libère les instances allouées en mémoire ; attention, on suppose que toutes les instances utilisées ont été libérées
	 */
	public function free() : Void {
		var lAsset	: AssetInstance;
		
		for ( lAsset in freeInstances) lAsset.destroy();
		
		freeMap();
		
		freeInstances	= null;
		usedInstances	= null;
	}
	
	/**
	 * on vérifie si ce descripteur d'asset est "actif", c'est à dire si on a prévu de la mémoire d'allocation pour des instances d'assets
	 * 
	 * même si aucune instance n'a été préchargée en mémoire (config d'instance à 0), le descripteur est dit actif à partir du moment
	 * où on a demandé de préparer une allocation
	 * 
	 * @return	true si le descripteur est actif, false sinon (pas de mémoire allouée pour d'éventuelles instances)
	 */
	public function isMalloc() : Bool { return freeInstances != null;}
	
	public function getInstanceCount() : Int {
		var lGroup	: AssetGroupDesc;
		var lCount	: Int;
		
		if( sharedProperties.instanceCount >= 0) return sharedProperties.instanceCount;
		else{
			for( lGroup in groups){
				lCount = lGroup.getInstanceCount();
				
				if( lCount >= 0) return lCount;
			}
		}
		
		return mgr.sharedProperties.instanceCount;
	}
	
	public function getLockInstance() : String {
		var lGroup	: AssetGroupDesc;
		var lLock	: String;
		
		if( sharedProperties.lockInstance != AssetsSharedProperties.LOCKER_UNDEFINED) return sharedProperties.lockInstance;
		else{
			for( lGroup in groups){
				lLock = lGroup.getLockInstance();
				
				if( lLock != AssetsSharedProperties.LOCKER_UNDEFINED) return lLock;
			}
		}
		
		return mgr.sharedProperties.lockInstance;
	}
	
	public function getRender() : AssetRender {
		var lGroup	: AssetGroupDesc;
		var lRender	: AssetRender;
		
		if ( sharedProperties.render != null) return sharedProperties.render;
		
		for ( lGroup in groups){
			lRender = lGroup.getRender();
			
			if ( lRender != null) return lRender;
		}
		
		return mgr.sharedProperties.render;
	}
	
	/**
	 * on parcours la config pour savoir si cet asset doit avoir une map de pixels à générer
	 * @return
	 */
	public function getIsMap() : Bool {
		var lGroup	: AssetGroupDesc;
		
		if ( sharedProperties.mapMode != AssetsSharedProperties.MAP_UNDEFINED) return sharedProperties.mapMode == AssetsSharedProperties.MAP_YES;
		
		for ( lGroup in groups){
			if( lGroup.getMapMode() != AssetsSharedProperties.MAP_UNDEFINED) return lGroup.getMapMode() == AssetsSharedProperties.MAP_YES;
		}
		
		if ( mgr.sharedProperties.mapMode != AssetsSharedProperties.MAP_UNDEFINED) return mgr.sharedProperties.mapMode == AssetsSharedProperties.MAP_YES;
		
		return false;
	}
	
	/**
	 * on récupère une valeur définie en "datas" pour l'asset et correspondant à la clef passée
	 * @param	pId		clef de la valeur cherchée dans les datas de cet asset
	 * @return	valeur correspondante, ou null si rien de défini
	 */
	public function getData( pId : String) : String {
		var lGroup	: AssetGroupDesc;
		var lVal	: String;
		
		if( sharedProperties.datas.exists( pId)) return sharedProperties.datas[ pId];
		else {
			for ( lGroup in groups) {
				lVal = lGroup.getData( pId);
				
				if ( lVal != null) return lVal;
			}
		}
		
		if( mgr.sharedProperties.datas.exists( pId)) return mgr.sharedProperties.datas[ pId];
		else return null;
	}
	
	public function malloc() : Bool {
		freeInstances	= new Array<AssetInstance>();
		usedInstances	= new Map<AssetInstance,AssetInstance>();
		
		mallocInstance();
		
		if ( getIsMap()) generateMap();
		
		return true;
	}
	
	function get_imageData() : ImageDataOffset { return _imageData; }
	
	function mallocInstance() : Void {
		var lCount	: Int	= getInstanceCount();
		var lI		: Int;
		
		lI = 0;
		while ( lI < lCount){
			freeInstances.push( generateInstance());
			
			lI++;
		}
	}
	
	function generateInstance() : AssetInstance {
		var lRender : AssetRender	= getRender();
		
		if( lRender.render == AssetRender.RENDER_DEFAULT){
			if ( getFile() != null && VegaLoaderMgr.getInstance().getLoadingFile( getFile().getId()).isIMG()){
				return new AssetInstance( this, pixi.core.sprites.Sprite.fromImage( VegaLoaderMgr.getInstance().getLoadingFile( getFile().getId()).getUrl()));
			}
		}else if ( lRender.render == AssetRender.RENDER_FLUMP){
			if ( lRender.type == AssetRender.TYPE_FLUMP_MC){
				return new AssetInstance( this, new Movie( export));
			}else if ( lRender.type == AssetRender.TYPE_FLUMP_SP){
				return new AssetInstance( this, new pixi.flump.Sprite( export));
			}
		}
		
		return new AssetInstance( this, new pixi.core.sprites.Sprite());
	}
	
	/**
	 * on génère la map de pixels correspondant à l'affichage d'une instance dans un canvas
	 */
	function generateMap() : Void {
		var lModel	: AssetInstance		= generateInstance();
		var lCanvas	: CanvasRenderer	= new CanvasRenderer( lModel.width, lModel.height, { transparent: true});
		var lBounds	: Rectangle			= lModel.getLocalBounds();
		
		lModel.x = -lBounds.x;
		lModel.y = -lBounds.y;
		
		lCanvas.render( lModel);
		
		_imageData = new ImageDataOffset( lModel.x, lModel.y, lCanvas.context.getImageData( 0, 0, lModel.width, lModel.height));
		
		lModel.destroy();
		lCanvas.destroy( true);
	}
	
	/**
	 * on libère de la mémoire de la map pixels
	 */
	function freeMap() : Void {
		if( _imageData != null){
			_imageData.destroy();
			
			_imageData = null;
		}
	}
}

/**
 * données en pixels avec offset d'image
 */
class ImageDataOffset {
	var dx			: Float;
	var dy			: Float;
	var imageData	: ImageData;
	
	public function new( pX : Float, pY : Float, pDat : ImageData) {
		dx			= pX;
		dy			= pY;
		imageData	= pDat;
	}
	
	public function getPixel( pX : Float, pY : Float) : Array<Int> {
		var lX	: Int	= Math.floor( pX + dx);
		var lY	: Int	= Math.floor( pY + dy);
		var lI	: Int;
		
		if ( lX < 0 || lX > imageData.width || lY < 0 || lY > imageData.height) return [ 0, 0, 0, 0];
		else{
			lI = ( lX + imageData.width * lY) * 4;
			
			return [ imageData.data[ lI], imageData.data[ lI + 1], imageData.data[ lI + 2], imageData.data[ lI + 3]];
		}
		
	}
	
	public function destroy() : Void { imageData = null; }
}