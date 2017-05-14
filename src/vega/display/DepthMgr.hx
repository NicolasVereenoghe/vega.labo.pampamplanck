package vega.display;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;

/**
 * ...
 * @author nico
 */
class DepthMgr {
	var _zone								: Container;
	public var zone(get, null)				: Container;
	
	var items								: Array<DepthCell>;
	
	public function new( pZone : Container) {
		_zone	= pZone;
		items	= new Array<DepthCell>();
	}
	
	public function setDepth( pItem : DisplayObject, pDepth : Float) : Void {
		var lBeg	: Int	= 0;
		var lEnd	: Int	= items.length;
		var lMid	: Int	= Math.floor( ( lBeg + lEnd) / 2);
		
		while( lBeg < lEnd){
			if( pDepth > items[ lMid].depth){
				lBeg = lMid + 1;
			}else if( pDepth < items[ lMid].depth){
				lEnd = lMid;
			}else break;
			
			lMid = Math.floor( ( lBeg + lEnd) / 2);
		}
		
		items.insert( lMid, new DepthCell( pItem, pDepth));
		
		if( items.length == lMid + 1) _zone.setChildIndex( pItem, _zone.children.length - 1);
		else _zone.setChildIndex( pItem, _zone.getChildIndex( items[ lMid + 1].mc));
	}
	
	/**
	 * update the depth of an already registered item
	 * @param	pItem	the displayed item which depth should be updated
	 * @param	pDeth	its new depth hint comparative value
	 */
	public function updateDepth( pItem : DisplayObject, pDepth : Float) : Void {
		freeDepth( pItem);
		_zone.setChildIndex( pItem, _zone.children.length - 1);
		setDepth( pItem, pDepth);
	}
	
	public function freeDepth( pItem : DisplayObject) : Void {
		var lBeg	: Int	= 0;
		var lEnd	: Int	= items.length;
		var lMid	: Int	= Math.floor( ( lBeg + lEnd) / 2);
		var lDepth	: Int	= _zone.getChildIndex( pItem);
		
		while( lBeg < lEnd){
			if( lDepth > _zone.getChildIndex( items[ lMid].mc)){
				lBeg = lMid + 1;
			}else if( lDepth < _zone.getChildIndex( items[ lMid].mc)){
				lEnd = lMid;
			}else break;
			
			lMid = Math.floor( ( lBeg + lEnd) / 2);
		}
		
		items.splice( lMid, 1);
	}
	
	function get_zone() : Container { return _zone; }
}

class DepthCell {
	public var mc		: DisplayObject;
	public var depth	: Float;
	
	public function new( pMc : DisplayObject, pD : Float){
		mc		= pMc;
		depth	= pD;
	}
}