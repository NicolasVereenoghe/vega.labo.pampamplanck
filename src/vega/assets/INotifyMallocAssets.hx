package vega.assets;

/**
 * @author nico
 */
interface INotifyMallocAssets {
	function onMallocAssetsProgress( pCurrent : Int, pTotal : Int) : Void;
	
	function onMallocAssetsEnd() : Void;
}