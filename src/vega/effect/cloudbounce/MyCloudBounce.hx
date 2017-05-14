package vega.effect.cloudbounce;
import pixi.core.math.Point;
import pixi.flump.Movie;

/**
 * collisions par nuage de points ; ne gère pas le skew/scale
 * @author 
 */
class MyCloudBounce {
	var BOUNCE_QUOTIENT							: Float										= 10;
	
	var points									: Array<Point>								= null;
	var gravity									: Point										= null;
	var bTab									: Array<Array<MyBounceData>>				= null;
	
	var testOneBounce							: Float->Float->Int->Bool					= null;
	
	var notifyPreBounce							: Float->Float->Void						= null;
	
	var curPos									: Point										= null;
	var curSpeed								: Point										= null;
	
	var bounceIBeg								: Int										= -1;
	var bounceIEnd								: Int										= -1;
	
	public function new( pTestOneBounce : Float->Float->Int->Bool, pBounceQ : Float = -1, pNotifyPreBounce : Float->Float->Void = null) {
		testOneBounce	= pTestOneBounce;
		notifyPreBounce	= pNotifyPreBounce;
		
		if ( pBounceQ > 0) BOUNCE_QUOTIENT = pBounceQ;
	}
	
	public function initFromModel( pModel : Movie) : Void {
		// TODO !!
	}
	
	public function initFromDisk( pRay : Float, pNbPt : Int, pOffsetA : Float = 0, pOffsetPt : Point = null) : Void {
		var lDA	: Float	= 2 * Math.PI / pNbPt;
		var lI	: Int;
		var lA	: Float;
		
		points	= new Array<Point>();
		
		if ( pOffsetPt != null) gravity = pOffsetPt;
		else gravity = new Point();
		
		lI = 0;
		while ( lI < pNbPt){
			lA = pOffsetA + lDA * lI;
			
			points.push( new Point( pRay * Math.cos( lA) + gravity.x, pRay * Math.sin( lA) + gravity.y));
			
			lI++;
		}
		
		initBTab();
	}
	
	public function destroy() : Void {
		curPos			= null;
		curSpeed		= null;
		testOneBounce	= null;
		bTab			= null;
		points			= null;
		gravity			= null;
	}
	
	public function doBounce( pPos : Point, pSpeed : Point) : Bool {
		curPos		= pPos;
		curSpeed	= pSpeed;
		
		if ( seekBounce()){
			resolveBounce();
			
			return true;
		}else return false;
	}
	
	function testOneBounceAt( pAt : Int) : Bool { return testOneBounce( curPos.x + points[ pAt].x, curPos.y + points[ pAt].y, pAt); }
	
	function seekBounce() : Bool {
		var lNbPt		: Int		= points.length;
		var lI0Len		: Int		= 0;
		var lIndPt		: Int		= 1;
		var lPrev		: Int		= -1;
		var lIBeg		: Int		= -1;
		var lLen		: Int		= 0;
		
		if ( ! testOneBounceAt( 0)){
			while ( ! testOneBounceAt( lIndPt++)){
				if ( lIndPt == lNbPt) return false;
			}
			
			lI0Len	= lIndPt - 1;
		}
		
		while ( lIndPt < lNbPt){
			if ( testOneBounceAt( lIndPt)){
				if ( lIndPt - lPrev == 1 && lLen < lIndPt - lIBeg){
					bounceIBeg	= lIBeg;
					lLen		= lIndPt - lIBeg;
				}
				
				lIndPt++;
				continue;
			}
			
			if( lIndPt - lPrev != 1) lIBeg = lIndPt;
			
			lPrev = lIndPt;
			
			lIndPt++;
		}
		
		if( lIndPt - lPrev == 1 && lI0Len + lNbPt - lIBeg > lLen){
			bounceIBeg = lIBeg;
			
			if( lI0Len > 0){
				bounceIEnd = lI0Len - 1;
				return true;
			}
			
			bounceIEnd = lNbPt - 1;
			return true;
		}
		
		if( lI0Len > lLen){
			bounceIBeg	= 0;
			bounceIEnd	= lI0Len - 1;
			
			return true;
		}
		
		if( lLen > 0){
			bounceIEnd = bounceIBeg + lLen - 1;
			
			return true;
		}
		
		return false;
	}
	
	function resolveBounce() : Void {
		var lBounce		: MyBounceData	= bTab[ bounceIBeg][ bounceIEnd];
		var lVect1		: Point			= new Point( lBounce.x, lBounce.y);
		var lX			: Float			= curSpeed.x;
		var lY			: Float			= curSpeed.y;
		
		if ( notifyPreBounce != null) notifyPreBounce( lBounce.c, lBounce.s);
		
		curPos.x	+= lBounce.x / BOUNCE_QUOTIENT;
		curPos.y	+= lBounce.y / BOUNCE_QUOTIENT;
		
		if ( lBounce.x * lX + lBounce.y * lY < 0) {
			curSpeed.x	= -lBounce.y * ( lBounce.x * lY - lBounce.y * lX) / lBounce.d2;
			curSpeed.y	= -lBounce.x * ( lBounce.y * lX - lBounce.x * lY) / lBounce.d2;
		}
	}
	
	function initBTab() : Void {
		var lNbPt		: Int							= points.length;
		var lBTab		: Array<Array<MyBounceData>>	= new Array<Array<MyBounceData>>();
		var lIndA		: Int;
		var lIndB		: Int;
		var lBTabA		: Array<MyBounceData>;
		var lA			: Float;
		var lA1			: Float;
		var lA2			: Float;
		var lVX			: Float;
		var lVY			: Float;
		var lD			: Float;
		
		lIndA = 0;
		while ( lIndA < lNbPt){
			lBTab[ lIndA]	= new Array<MyBounceData>();
			lBTabA			= lBTab[ lIndA];
			
			lIndB = 0;
			while ( lIndB < lNbPt) {
				if ( lIndA == lIndB) {
					lA	= Math.atan2( points[ lIndA].y - gravity.y, points[ lIndA].x - gravity.x);
					lVX	= Math.cos( lA);
					lVY	= Math.sin( lA);
					lD	= getMaxDist( lVX, lVY, points[ lIndA].x, points[ lIndA].y, lIndA, lIndA);
				}else{
					lA1	= Math.atan2( points[ lIndA].y - gravity.y, points[ lIndA].x - gravity.x);
					lA2	= Math.atan2( points[ lIndB].y - gravity.y, points[ lIndB].x - gravity.x);
					
					if ( lA2 < lA1) lA2 += 2 * Math.PI;
					
					lA	= ( lA1 + lA2) / 2;
					lVX	= Math.cos( lA);
					lVY	= Math.sin( lA);
					lD	= Math.max( getMaxDist( lVX, lVY, points[ lIndA].x, points[ lIndA].y, lIndA, lIndB), getMaxDist( lVX, lVY, points[ lIndB].x, points[ lIndB].y, lIndA, lIndB));
				}
				
				lBTabA[ lIndB] = new MyBounceData( lVX * lD, lVY * lD, lVX, lVY, lD * lD);
				
				lIndB++;
			}
			
			lIndA++;
		}
		
		bTab = lBTab;
	}
	
	function getMaxDist( pCos : Float, pSin : Float, pX : Float, pY : Float, pIndA : Int, pIndB : Int) : Float {
		var lNbPt		: Int						= points.length;
		var lInd		: Int						= ( pIndB + 1) % lNbPt;
		var lMax		: Float						= 0;
		var lPt			: Point;
		var lX			: Float;
		var lY			: Float;
		var lDist		: Float;
		
		while ( lInd != pIndA){
			lPt		= points[ lInd];
			lX		= lPt.x - pX + pSin * ( pCos * ( lPt.y - pY) - pSin * ( lPt.x - pX));
			lY		= lPt.y - pY + pCos * ( pSin * ( lPt.x - pX) - pCos * ( lPt.y - pY));
			lDist	= lX * lX + lY * lY;
			
			if ( lDist > lMax) lMax = lDist;
			
			lInd = ( lInd + 1) % lNbPt;
		}
		
		return Math.sqrt( lMax);
	}
}

class MyBounceData {
	public var x					: Float					= 0;
	public var y					: Float					= 0;
	public var c					: Float					= 0;
	public var s					: Float					= 0;
	public var d2					: Float					= 0;
	
	public function new( pX : Float, pY : Float, pC : Float, pS : Float, pD2 : Float) {
		x	= pX;
		y	= pY;
		c 	= pC;
		s	= pS;
		d2	= pD2;
	}
}