package vega.assets;

import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import vega.utils.UtilsFlump;
import haxe.extern.EitherType;

/**
 * ...
 * @author nico
 */
class AssetInstance extends Container {
	var _export								: DisplayObject;
	
	var _desc								: AssetDesc;
	
	public function new( pDesc : AssetDesc, pExport : DisplayObject) {
		super();
		
		_desc	= pDesc;
		
		if ( pExport != null){
			_export = addChild( pExport);
			
			if ( Std.is( _export, Container)) UtilsFlump.recursiveStop( cast _export);
		}
	}
	
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		if ( _export != null){
			if( _export.parent != null) _export.parent.removeChild( _export);
			//_export.destroy( true); // pas de sens pour les png car géré déjà par fichier, provoque un bug de détruire texture de base alors qu'on a juste une instance en trop ; ni pour flump géré par les atlas
			_export.destroy();
			_export = null;
		}
		
		_desc = null;
		
		super.destroy();
	}
	
	public function getContent() : DisplayObject { return _export; }
	
	public function getDesc() : AssetDesc { return _desc; }
	
	public function free() : Void { _desc.freeAssetInstance( this); }
}