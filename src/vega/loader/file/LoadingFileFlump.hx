package vega.loader.file;
import flump.json.FlumpJSON;
import flump.json.FlumpJSON.AtlasSpec;
import flump.library.FlumpLibrary;
import haxe.Timer;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.BaseTexture;
import pixi.core.textures.Texture;
import pixi.flump.Resource;
import pixi.flump.Parser;
import pixi.loaders.Loader;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
@:access(pixi.flump.Resource)
class LoadingFileFlump extends LoadingFile {
	var atlasLoader						: Loader							= null;
	var lib								: FlumpLibrary						= null;
	var textures						: Map<String,Texture>				= null;
	var specByUrl						: Map<String,AtlasSpec>				= null;
	
	public function new( pFile : MyFile) { super( pFile); }
	
	override public function free() : Void {
		atlasLoader	= null;
		lib			= null;
		textures	= null;
		specByUrl	= null;
		
		Resource.destroy( getId());
		
		super.free();
	}
	
	override function removeLoaderListener() : Void {
		if ( atlasLoader != null) atlasLoader.removeAllListeners();
		
		super.removeLoaderListener();
	}
	
	override function onLoadComplete() : Void {
		var lData		: Dynamic;
		
		if ( Reflect.getProperty( loader.resources, _file.getId()).error == null){
			lData = getLoadedContent();
			
			if ( lData == null || ! isJson() || ! Reflect.hasField( lData, "md5") || ! Reflect.hasField( lData, "movies") || ! Reflect.hasField( lData, "textureGroups") || ! Reflect.hasField( lData, "frameRate")){
				onError();
				return;
			}
			
			ctrReload = 0;
			
			lib			= FlumpLibrary.create( lData, 1);
			textures	= new Map<String,Texture>();
			specByUrl	= new Map<String,AtlasSpec>();
			
			atlasLoader = new Loader();
			atlasLoader.on( "error", onAtlasError);
			atlasLoader.on( "complete", onAtlasLoadComplete);
			
			buildAtlasLoadQ();
			
			doAtlasLoad();
		}else onError();
	}
	
	function buildAtlasLoadQ( pForceAntiCache : Bool = false) : Void {
		var lBase		: String		= ~/\/(.[^\/]*)$/i.replace( getUrl(), "");
		var lSpec		: AtlasSpec;
		var lFile		: String;
		
		for ( lSpec in lib.atlases){
			lFile = lBase + "/" + LoadingFile.addVersionToUrl( lSpec.file, LoadingFile.getVersionUrl( _file, pForceAntiCache));
			
			specByUrl[ lBase + "/" + lSpec.file] = lSpec;
			
			ApplicationMatchSize.instance.traceDebug( "INFO : LoadingFileFlump::buildAtlasLoadQ : " + lFile);
			
			atlasLoader.add( lFile, onAtlasLoaded);
		}
	}
	
	function doAtlasLoad() : Void { atlasLoader.load(); }
	
	function onAtlasLoaded( pRes : pixi.loaders.Resource) : Void {
		var lTxtSpecs	: Array<TextureSpec>	= specByUrl[ pRes.url.split( "?")[ 0]].textures;
		var lTexture	: BaseTexture			= new BaseTexture( pRes.data);
		var lSpec		: TextureSpec;
		var lFrame		: Rectangle;
		var lOrigin		: Point;
		
		lTexture.resolution = 1;
		
		for( lSpec in lTxtSpecs){
			lFrame	= new Rectangle( lSpec.rect.x, lSpec.rect.y, lSpec.rect.width, lSpec.rect.height);
			lOrigin	= new Point( lSpec.origin.x, lSpec.origin.y);
			
			lOrigin.x	= lOrigin.x / lFrame.width;
			lOrigin.y	= lOrigin.y / lFrame.height;
			
			textures[ lSpec.symbol]	= new Texture( lTexture, lFrame);
		}
	}
	
	function onAtlasLoadComplete() : Void {
		var lRes	: pixi.flump.Resource	= new pixi.flump.Resource( lib, textures, getId(), 1);
		
		if ( getId() != null) pixi.flump.Resource.resources[ getId()] = lRes;
		
		Reflect.setProperty( loader.resources, "data", lRes);
		
		super.onLoadComplete();
	}
	
	function onAtlasError() : Void {
		ApplicationMatchSize.instance.traceDebug( "ERROR : LoadingFileFlump::onAtlasError ( " + ctrReload + ")");
		
		if ( ctrReload++ < RELOAD_MAX){
			atlasLoader.reset();
			
			buildAtlasLoadQ( true);
			
			Timer.delay( doAtlasLoad, RELOAD_DELAY_MAX * Math.round( Math.pow( ctrReload / RELOAD_MAX, 2)));
		}else ApplicationMatchSize.instance.reload();
	}
}