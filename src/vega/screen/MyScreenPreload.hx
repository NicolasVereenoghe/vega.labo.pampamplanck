package vega.screen;
import pixi.core.graphics.Graphics;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class MyScreenPreload extends MyScreenLoad {
	var bar									: Graphics;
	
	public function new() {
		super();
		
		bgColor			= 0xFFFFFF;
	}
	
	override public function destroy() : Void {
		content.removeChild( bar);
		bar.destroy();
		bar = null;
		
		super.destroy();
	}
	
	override public function start() : Void { setModeProgress(); }
	
	override public function onLoadProgress( pLoadRate : Float) : Void { toRate = .5 + .5 * pLoadRate; }
	
	override function doLoadFinal() : Void {
		super.doLoadFinal();
		
		shell.onScreenClose( this);
		
		setModeFadeOut();
	}
	
	override function buildContent() : Void {
		super.buildContent();
		
		bar = cast content.addChild( new Graphics());
		bar.beginFill( 0);
		bar.drawRect( 0, 0, ApplicationMatchSize.instance.getScreenRectExt().width, 30);
		bar.endFill();
		
		onResize();
	}
	
	override function onResize() : Void {
		bar.x	= ApplicationMatchSize.instance.getScreenRect().x;
		bar.y	= ApplicationMatchSize.instance.getScreenRect().y;
		
		refreshBar();
	}
	
	override function launchAfterInit() : Void { shell.onScreenReady( this); }
	
	override function doModeProgress( pTime : Float) : Void {
		super.doModeProgress( pTime);
		
		refreshBar();
	}
	
	function refreshBar() : Void {
		bar.scale.x = Math.max( .005, curRate) * ApplicationMatchSize.instance.getScreenRect().width / ApplicationMatchSize.instance.getScreenRectExt().width;
	}
}