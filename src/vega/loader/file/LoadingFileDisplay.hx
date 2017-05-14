package vega.loader.file;
import pixi.core.textures.Texture;

/**
 * ...
 * @author nico
 */
class LoadingFileDisplay extends LoadingFile {
	public function new( pFile : MyFile) { super( pFile); }
	
	override public function free() : Void {
		//Texture.removeTextureFromCache( getUrl());
		Texture.removeTextureFromCache( getUrl()).destroy( true);
		
		super.free();
	}
}