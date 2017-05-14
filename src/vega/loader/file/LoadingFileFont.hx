package vega.loader.file;
import vega.loader.VegaLoader;
import vega.shell.ApplicationMatchSize;
import webfont.WebFontLoader;

/**
 * ...
 * @author nico
 */
class LoadingFileFont extends LoadingFile {
	var fontId						: String;
	
	public function new( pFontId : String, pFontCss : MyFile) {
		super( pFontCss);
		
		fontId = pFontId;
	}
	
	override function doLoad() : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : LoadingFileFont::doLoad : " + fontId + " : " + getUrlRequest());
		
		WebFontLoader.load(
			{
				"custom": {
					"families": [
						fontId
					],
					"urls": [
						getUrlRequest()
					]
				},
				"active": onLoadComplete
			}
		);
	}
	
	override function onLoadComplete() : Void {
		vegaLoader.onCurFileLoaded();
		
		vegaLoader = null;
	}
	
	override function buildLoader() : Void { }
	
	override function removeLoaderListener() : Void { }
}