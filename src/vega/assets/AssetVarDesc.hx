package vega.assets;

/**
 * ...
 * @author nico
 */
class AssetVarDesc {
	public var id			: String;
	
	var values				: Array<VarValue>;
	
	public function new( pVar : Dynamic) {
		var lVals	: Array<String>	= pVar.value.split( ",");
		var lI		: Int;
		
		id		= pVar.id;
		values	= new Array<VarValue>();
		
		lI = 0;
		while ( lI < lVals.length){
			values.push( new VarValue( lVals[ lI]));
			
			lI++;
		}
	}
	
	public function getLen() : Int {
		var lLen	: Int	= 0;
		var lI		: Int	= 0;
		
		while ( lI < values.length) lLen += values[ lI++].getLen();
		
		return lLen;
	}
	
	public function getVal( pI : Int) : String {
		var lI : Int;
		
		lI = 0;
		while( lI < values.length ){
			if( pI >= values[ lI].getLen()) pI -= values[ lI].getLen();
			else break;
			
			lI++;
		}
		
		return values[ lI].getVal( pI);
	}
}