package vega.assets;
import haxe.Json;

/**
 * ...
 * @author nico
 */
class VarPool {
	var vars						: Array<AssetVarDesc>;

	public function new() { vars = new Array<AssetVarDesc>(); }
	
	public function addVar( pVar : AssetVarDesc) : Void { vars.push( pVar); }
	
	public function getLen() : Int {
		var lCard	: Int	= 1;
		var lI		: Int;
		
		lI = 0;
		while ( lI < vars.length){
			lCard *= vars[ lI].getLen();
			
			lI++;
		}
		
		return lCard;
	}
	
	public function substituteVars( pNode : Dynamic, pIPool : Int) : Dynamic {
		var lStr	: String;
		var lMap	: Map<String,String>;
		var lI		: String;
		
		if( vars.length > 0){
			lStr	= Json.stringify( pNode);
			lMap	= getVarValAt( pIPool);
			
			for ( lI in lMap.keys()){
				lStr = StringTools.replace( lStr, lI, lMap[ lI]);
			}
			
			return Json.parse( lStr);
		}else return pNode;
	}
	
	function getVarValAt( pI :Int) : Map<String,String> {
		var lMap	: Map<String,String>	= new Map<String,String>();
		var lI		: Int;
		
		lI = 0;
		while( lI < vars.length) {
			lMap[ vars[ lI].id] = vars[ lI].getVal( pI % vars[ lI].getLen());
			
			pI = Std.int( pI / vars[ lI].getLen());
			lI++;
		}
		
		return lMap;
	}
}