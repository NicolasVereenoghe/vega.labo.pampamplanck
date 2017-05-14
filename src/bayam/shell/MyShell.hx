package bayam.shell;

import bayam.game.MyGMgr;
import bayam.shell.MyHUD;
import pixi.core.display.Container;
import vega.assets.AssetVarDesc;
import vega.assets.AssetsMgr;
import vega.assets.PatternAsset;
import vega.loader.VegaLoader;
import vega.loader.file.MyFile;
import vega.screen.MyScreen;
import vega.screen.MyScreenPreload;
import vega.screen.MyScreenSplash;
import vega.shell.ApplicationMatchSize;
import vega.shell.GameShell;
import vega.shell.IGameMgr;
import vega.shell.IMyHUD;
import vega.shell.MyScore;
import vega.shell.SavedDatas;
import vega.utils.UtilsPixi;

class LvlData {
	public var id		: Int;
	public var done		: Bool;
	
	public function new( pId : Int, ?pDone : Bool) {
		id		= pId;
		done	= pDone != null ?	pDone	: false;
	}
}

/**
 * ...
 * @author nico
 */
class MyShell extends GameShell {
	public static inline var BG_GAME_RADIX		: String									= "bg_game";
	
	var bgContainer								: Container									= null;
	
	var myHUDContainer							: Container;
	var curHUD									: IMyHUD									= null;
	
	public var curLvlI( default, null)			: Int										= 0;
	
	var lvls									: Array<LvlData>							= null;
	
	public function new() {
		super();
	}
	
	public function isLvlDone( pILvl : Int) : Bool { return lvls[ pILvl].done; }
	
	override public function init( pCont : Container, pFileAssets : MyFile, pFileLocal : MyFile, pFonts : Dynamic) : Void {
		bgContainer = cast pCont.addChild( new Container());
		
		super.init( pCont, pFileAssets, pFileLocal, pFonts);
		
		myHUDContainer = cast pCont.addChildAt( new Container(), pCont.getChildIndex( gameContainer) + 1);
		
		switchGameContentInteractive( false);
	}
	
	override public function getCurGameHUD() : IMyHUD { return curHUD; }
	
	override public function enableGameHUD( pType : String = null) : IMyHUD {
		if ( curHUD == null){
			curHUD = new MyHUD();
			
			curHUD.init( this, myHUDContainer);
		}else ApplicationMatchSize.instance.traceDebug( "ERROR : MyShell::enableGameHUD : un HUD est déjà actif, ignore");
		
		return curHUD;
	}
	
	override public function onGameover( pScore : MyScore = null, pSavedDatas : SavedDatas = null) : Void {
		var lLvls	: AssetVarDesc;
		
		lvls[ curLvlI].done = true;
		
		if ( curLvlI + 1 < getCurPackLvls().getLen()) ++curLvlI;
		else curLvlI = 0;
		
		cast( curGame, MyGMgr).clear();
		cast( curGame, MyGMgr).setLvlId( Std.parseInt( getCurPackLvls().getVal( curLvlI)));
	}
	
	override function onAssetDescBuilt() : Void { initLvlDatas(); }
	
	override function getCurGameSavedDatas() : SavedDatas { return null; }
	
	override public function onGameProgress( pRate : Float) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( .75 + pRate * .25); }
	
	override public function onGameReady() : Void {
		super.onGameReady();
		
		cast( curScreen, MyScreenPreload).onLoadComplete();
	}
	
	override function onShellReadyMini() : Void {
		cast( curGame, MyGMgr).setLvlId( Std.parseInt( getCurPackLvls().getVal( 0)));
		
		switchGameContentInteractive( true);
	}
	
	override function getScreenSplash() : MyScreenSplash { return null; }
	
	override function getGameInstance() : IGameMgr { return new MyGMgr(); }
	
	override function getAssetsMiniPatterns() : Array<PatternAsset> {
		var lPats	: Array<PatternAsset>	= super.getAssetsMainPatterns();
		
		lPats.push( new PatternAsset( "pack", PatternAsset.FIND_ON_GROUP, PatternAsset.MATCH_ALL));
		
		return lPats;
	}
	
	override function onAssetsMiniProgress( pLoader:VegaLoader) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( .5 + pLoader.getProgressRate() * .125); }
	
	override function onMallocMiniProgress( pCur : Int, pTotal : Int) : Void { cast( curScreen, MyScreenPreload).onLoadProgress( .625 + ( pCur / pTotal) * .125); }
	
	override function onMallocMiniEnd():Void {
		UtilsPixi.fit( cast bgContainer.addChild( AssetsMgr.instance.getAssetInstance( BG_GAME_RADIX/* + _packNum*/)));
		
		launchGame();
	}
	
	function switchGameContentInteractive( pIsActive : Bool) : Void {
		gameContainer.interactiveChildren = pIsActive;
		myHUDContainer.interactiveChildren = pIsActive;
	}
	
	function initLvlDatas() : Void {
		var lLvls	: AssetVarDesc	= getCurPackLvls();
		var lI		: Int			= 0;
		
		lvls = [];
		
		while ( lI < lLvls.getLen()){
			lvls.push( new LvlData(
				Std.parseInt( lLvls.getVal( lI)),
				false
			));
			
			lI++;
		}
	}
	
	function getCurPackLvls() : AssetVarDesc { return AssetsMgr.instance.getVar( "#PACK_LVLS#"); }
}