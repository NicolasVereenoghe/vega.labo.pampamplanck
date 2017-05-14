package vega.local;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class TxtDescFlump {
	public static inline var ALIGN_CENTER	: String	= "center";
	public static inline var ALIGN_RIGHT	: String	= "right";
	
	public static inline var V_ALIGN_CENTER	: String	= "center";
	public static inline var V_ALIGN_BOT	: String	= "bot";
	
	public var localId		: String;
	public var fontId		: String;
	public var size			: Int;
	public var align		: String;
	public var color		: String;
	public var wordWrap		: Float						= -1;
	public var vAlign		: String;
	
	public function new( pLayerData : String) {
		var lDatas	: Array<String>	= pLayerData.split( LocalMgr.instance.TXT_SEP);
		
		if ( lDatas.length < 6) throw "WARNING : TxtDescFlump::TxtDescFlump : invalid params : " + pLayerData;
		
		localId		= lDatas[ 1];
		fontId		= lDatas[ 2];
		size		= Std.parseInt( lDatas[ 3]);
		align		= lDatas[ 4];
		color		= "#" + lDatas[ 5];
		
		if ( lDatas.length > 6) wordWrap = Std.parseFloat( lDatas[ 6]);
		if ( lDatas.length > 7) vAlign = lDatas[ 7];
	}
}