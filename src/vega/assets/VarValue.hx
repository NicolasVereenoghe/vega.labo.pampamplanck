package vega.assets;

/**
 * ...
 * @author nico
 */
class VarValue {
	var value		: String;

	public function new( pVal : String) { value = pVal; }
	
	public function getLen() : Int {
		var lVals : Array<String> = value.split( "..");
		
		if( lVals.length == 1) return 1;
		else return Std.parseInt( lVals[ 1]) - Std.parseInt( lVals[ 0]) + 1;
	}
	
	public function getVal( pI : Int) : String {
		var lVals	: Array<String>		= value.split( "..");
		var lFrom	: Int;
		var lRes	: Int;
		var lResTxt	: String;
		var lI		: Int;
		var lLen	: Int;
		
		if( lVals.length == 1) return value;
		else{
			lFrom	= Std.parseInt( lVals[ 0]);
			lRes	= lFrom + pI;
			lLen	= lVals[ 0].length;
			
			if ( Std.string( lFrom).length < lLen) {
				lResTxt	= Std.string( lRes);
				
				lI = lResTxt.length;
				while ( lI < lLen){
					lResTxt = "0" + lResTxt;
					
					lI++;
				}
				
				return lResTxt;
			}else return Std.string( lRes);
		}
	}
}