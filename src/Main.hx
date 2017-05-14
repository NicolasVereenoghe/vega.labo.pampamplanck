package;

import bayam.shell.MyShell;
import pixi.core.Pixi;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;
import vega.shell.BaseShell;
import vega.shell.GlobalPointer;
import vega.shell.VegaDeactivator;
import vega.shell.VegaFramer;
import vega.shell.VegaOrient;
import vega.sound.SndMgr;

/**
 * ...
 * @author nico
 */
class Main extends ApplicationMatchSize {
	var shell		: BaseShell;
	
	static function main() { new Main(); }
	
	public function new() {
		super();
		
		SndMgr.getInstance();
		
		new GlobalPointer();
		//GlobalPointer.instance.switchEnable( false);
		
		//VegaOrient.getInstance().init();
		
		VegaFramer.getInstance().addIterator( startShell);
		
		VegaDeactivator.getInstance( ( ! debug) ? 10000 : 600000);
	}
	
	override function init() {
		//debugLvl = "INFO";
		//debug = true;
		//debugVisibleInit = true;
		//debugMotifs = [ "VegaOrient"];
		
		setFPS( 25);
		
		version = "0";
		//autoResize = false;
		
		super.init();
		
		traceDebug( version + ";" + Pixi.VERSION, true);
	}
	
	function startShell( pDT : Float) : Void {
		VegaFramer.getInstance().remIterator( startShell);
		
		shell = new MyShell();
		shell.init(
			getContent(),
			new MyFile( "assets.json", null, MyFile.VERSION_NO_CACHE),
			new MyFile( "local.xml", null, MyFile.VERSION_NO_CACHE),
			{}
		);
		
		//new Perf();
	}
}