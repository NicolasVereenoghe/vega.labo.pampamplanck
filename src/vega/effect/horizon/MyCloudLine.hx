package vega.effect.horizon;

import pixi.core.display.Container;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.shell.ApplicationMatchSize;

/**
 * une ligne de nuages d'un horizon
 * 
 * @author nico
 */
class MyCloudLine extends Container {
	/** réf sur gestionnaire de ligne */
	var mgr								: MyHorizonMgr;
	
	/** conteneur de motifs 1 */
	var contMotif1						: Container;
	/** conteneur de motifs 1 */
	var contMotif2						: Container;
	
	/** construction */
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function destroy() : Void {
		while ( contMotif1.children.length > 0){
			cast( contMotif1.removeChild( contMotif1.getChildAt( 0)), AssetInstance).free();
		}
		
		removeChild( contMotif1);
		contMotif1.destroy();
		contMotif1 = null;
		
		while ( contMotif2.children.length > 0){
			cast( contMotif2.removeChild( contMotif2.getChildAt( 0)), AssetInstance).free();
		}
		
		removeChild( contMotif2);
		contMotif2.destroy();
		contMotif2 = null;
		
		mgr = null;
		
		super.destroy();
	}
	
	/**
	 * init : on construit la ligne de motifs
	 * @param	pMgr	gestionnaire d'horizon associé
	 * @param	pLineI	indice de progression dans la période d'anim de motif (0 .. n-1)
	 */
	public function init( pMgr : MyHorizonMgr, pLineI : Int) : Void {
		var lW			: Float			= ( ApplicationMatchSize.instance.getScreenRectExt().width + pMgr.getBUMP_X()) / scale.x;
		var lMotifW		: Float			= pMgr.getMotifW();
		var lNbMotifDem	: Int			= Math.round( .5 * lW / lMotifW);
		var lNbMotif	: Int			= 2 * lNbMotifDem + 1;
		var lId1		: String		= pMgr.getMotif1Id();
		var lId2		: String		= pMgr.getMotif2Id();
		var lI			: Int			= 0;
		var lMotif1		: AssetInstance;
		var lMotif2		: AssetInstance;
		
		mgr			= pMgr;
		
		contMotif1	= cast addChild( new Container());
		contMotif2	= cast addChild( new Container());
		
		while ( lI < lNbMotif){
			lMotif1		= cast contMotif1.addChild( AssetsMgr.instance.getAssetInstance( lId1));
			lMotif2		= cast contMotif2.addChild( AssetsMgr.instance.getAssetInstance( lId2));
			
			lMotif1.x	= ( lI - lNbMotifDem - .5) * lMotifW;
			lMotif2.x	= ( lNbMotifDem + .5 - lI) * lMotifW;
			
			lI++;
		}
		
		updateAnim( pLineI);
	}
	
	/**
	 * 
	 * @param	pLineI	indice de progression dans la période d'anim de motif (0 .. n-1)
	 */
	public function updateAnim( pLineI : Int) : Void {
		var lDelt	: Float	= mgr.getMotifW() * mgr.getNbCycle() * pLineI / mgr.getPeriod();
		
		contMotif1.x = lDelt;
		contMotif2.x = -lDelt;
	}
}