package vega.effect.diskbounce;
import haxe.io.Error;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import vega.utils.Utils;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author ...
 */
class MyDiskBounce {
	public var x									: Float										= 0;
	public var y									: Float										= 0;
	public var vx									: Float										= 0;
	public var vy									: Float										= 0;
	
	public var accFX								: Float										= 0;
	public var accFY								: Float										= 0;
	
	public var ray									: Float										= 0;
	public var masse								: Float										= 1;
	public var frot									: Float										= .1;
	public var maxV									: Float										= 15;
	
	public var ignoreBDist							: Float										= 1;
	public var diskAbsorbOffset						: Float										= 1;
	public var bCoefPairs							: Float										= .1;
	public var bCoefStack							: Float										= .3;
	public var bMin									: Float										= 1;
	/** coef de réflexion de vitesse sur collision (0 => pas de rebond, 1 => réflexion sans amorti avec rebond) */
	public var globalBounceCoef						: Float										= 0;
	
	public var isFixed								: Bool										= false;
	public var isGlobalBounce						: Bool										= false;
	
	var bPairs										: Array<Point>								= [];
	var isPairsValid								: Bool										= true;
	var bStack										: Point										= null;
	
	public function new() {
		bStack = new Point();
	}
	
	public function clone() : MyDiskBounce {
		var lInstance	: MyDiskBounce	= new MyDiskBounce();
		
		lInstance.ray				= ray;
		lInstance.masse				= masse;
		lInstance.frot				= frot;
		lInstance.maxV				= maxV;
		lInstance.ignoreBDist		= ignoreBDist;
		lInstance.diskAbsorbOffset	= diskAbsorbOffset;
		lInstance.bCoefPairs		= bCoefPairs;
		lInstance.bCoefStack		= bCoefStack;
		lInstance.bMin				= bMin;
		lInstance.globalBounceCoef	= globalBounceCoef;
		lInstance.isFixed			= isFixed;
		lInstance.isGlobalBounce	= isGlobalBounce;
		
		return lInstance;
	}
	
	public function destroy() : Void {
		bPairs = null;
		bStack = null;
	}
	
	public function testHitOnPt( pX : Float, pY : Float) : Bool { return ( x - pX) * ( x - pX) + ( y - pY) * ( y - pY) < ray * ray; }
	
	public function testHitOnDisk( pDisk : MyDiskBounce) : Bool {
		var lDX		: Float	= pDisk.x - x;
		var lDY		: Float	= pDisk.y - y;
		
		return ( lDX * lDX + lDY * lDY <= ( ray + pDisk.ray) * ( ray + pDisk.ray));
	}
	
	public function doBounceWithDiskBounce( pDisk : MyDiskBounce, pReflectTransmit : Bool = true) : Bool {
		var lDX		: Float	= pDisk.x - x;
		var lDY		: Float	= pDisk.y - y;
		var lDist	: Float	= lDX * lDX + lDY * lDY;
		var lDA		: Float;
		var lA		: Float;
		
		if ( lDist < ( ray + pDisk.ray) * ( ray + pDisk.ray) && lDist > ignoreBDist * ignoreBDist){
			lA		= Utils.modA( Math.atan2( lDY, lDX));
			lDist	= Math.sqrt( lDist);
			
			if ( lDist > pDisk.ray + diskAbsorbOffset || lDist > ray + diskAbsorbOffset){
				if( isPairsValid){
					lDA		= Utils.modA( secureACos( ( lDist * lDist + ray * ray - pDisk.ray * pDisk.ray) / ( 2 * lDist * ray)));
					
					addBPair( Utils.modA( lA - lDA), Utils.modA( lA + lDA));
				}
			}else{
				// absorb
				lDist = pDisk.ray + ray - lDist;
				
				addBStack( -Math.cos( lA) * lDist, -Math.sin( lA) * lDist);
			}
			
			if ( pReflectTransmit) doReflectTransmit( pDisk, lA);
			
			return true;
		}
		
		return false;
	}
	
	public function doBounceOutsideBox( pBox : Rectangle, pReflectTransmit : Bool = true) : Void {
		var lMidX	: Float	= pBox.x + pBox.width / 2;
		var lMidY	: Float	= pBox.y + pBox.height / 2;
		var lDX		: Float	= x - lMidX;
		var lDY		: Float	= y - lMidY;
		var lDA		: Float;
		var lALeft	: Float;
		var lARight	: Float;
		
		if ( ! UtilsPixi.isPtInRectExp( x, y, pBox, ray)) return;
		
		if ( ( pBox.x - lMidX) * lDY - ( pBox.y - lMidY) * lDX > 0){
			if ( ( pBox.x + pBox.width - lMidX) * lDY - ( pBox.y - lMidY) * lDX > 0){
				// droite
				
				if ( x + ray < pBox.x + pBox.width + diskAbsorbOffset){
					// absorbé ?
					
					if ( y < lMidY){
						if ( y - ray < pBox.y - diskAbsorbOffset){
							// sortie par le haut
							
							if ( isPairsValid){
								lDA = secureACos( ( pBox.y - y) / ray);
								
								addBPair( Utils.modA( Math.PI / 2 - lDA), Utils.modA( Math.PI / 2 + lDA));
							}else{
								addBStack( 0, pBox.y - y - ray);
							}
							
							if ( pReflectTransmit) if ( vy > 0) { vy = -vy; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par la droite
							addBStack( pBox.x + pBox.width - x + ray, 0);
							
							if ( pReflectTransmit) if ( vx < 0) { vx = -vx; onSpeedReflected( null); }
						}
					}else{
						if ( y + ray > pBox.y + pBox.height + diskAbsorbOffset){
							// sortie par le bas
							
							if ( isPairsValid){
								lDA = secureACos( ( y - pBox.y - pBox.height) / ray);
								
								addBPair( Utils.modA( 3 * Math.PI / 2 - lDA), Utils.modA( 3 * Math.PI / 2 + lDA));
							}else{
								addBStack( 0, pBox.y + pBox.height - y + ray);
							}
							
							if ( pReflectTransmit) if ( vy < 0) { vy = -vy; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par la droite
							addBStack( pBox.x + pBox.width - x + ray, 0);
							
							if ( pReflectTransmit) if ( vx < 0) { vx = -vx; onSpeedReflected( null); }
						}
					}
				}else{
					if ( isPairsValid){
						lDA		= secureACos( ( x - pBox.x - pBox.width) / ray);
						lALeft	= Utils.modA( Math.PI - lDA);
						lARight	= Utils.modA( Math.PI + lDA);
						
						if ( y - ray < pBox.y - diskAbsorbOffset){
							lDA = Utils.modA( Math.PI / 2 + secureACos( ( pBox.y - y) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lDA - lALeft)) lARight = lDA;
						}
						
						if ( y + ray > pBox.y + pBox.height + diskAbsorbOffset){
							lDA = Utils.modA( 3 * Math.PI / 2 - secureACos( ( y - pBox.y - pBox.height) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lARight - lDA)) lALeft = lDA;
						}
						
						addBPair( lALeft, lARight);
						
						if ( pReflectTransmit) reflectSpeed( Utils.midA( lALeft, lARight));
					}else{
						// déjà absorbé, sortie par la droite
						addBStack( pBox.x + pBox.width - x + ray, 0);
						
						if ( pReflectTransmit) if ( vx < 0) { vx = -vx; onSpeedReflected( null); }
					}
				}
			}else{
				// haut
				
				if ( y - ray > pBox.y - diskAbsorbOffset) {
					// absorbé ?
					
					if ( x < lMidX){
						if ( x - ray < pBox.x - diskAbsorbOffset){
							// sortie par la gauche
							
							if ( isPairsValid){
								lDA = secureACos( ( pBox.x - x) / ray);
								
								addBPair( Utils.modA( -lDA), Utils.modA( lDA));
							}else{
								addBStack( pBox.x - x - ray, 0);
							}
							
							if ( pReflectTransmit) if ( vx > 0) { vx = -vx; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par le haut
							addBStack( 0, pBox.y - y - ray);
							
							if ( pReflectTransmit) if ( vy > 0) { vy = -vy; onSpeedReflected( null); }
						}
					}else{
						if ( x + ray > pBox.x + pBox.width + diskAbsorbOffset){
							// sortie par la droite
							
							if ( isPairsValid){
								lDA = secureACos( ( x - pBox.x - pBox.width) / ray);
								
								addBPair( Utils.modA( Math.PI - lDA), Utils.modA( Math.PI + lDA));
							}else{
								addBStack( pBox.x + pBox.width - x + ray, 0);
							}
							
							if ( pReflectTransmit) if ( vx < 0) { vx = -vx; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par le haut
							addBStack( 0, pBox.y - y - ray);
							
							if ( pReflectTransmit) if ( vy > 0) { vy = -vy; onSpeedReflected( null); }
						}
					}
				}else{
					if ( isPairsValid){
						lDA		= secureACos( ( pBox.y - y) / ray);
						lALeft	= Utils.modA( Math.PI / 2 - lDA);
						lARight	= Utils.modA( Math.PI / 2 + lDA);
						
						if ( x - ray < pBox.x - diskAbsorbOffset){
							lDA = Utils.modA( secureACos( ( pBox.x - x) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lDA - lALeft)) lARight = lDA;
						}
						
						if ( x + ray > pBox.x + pBox.width + diskAbsorbOffset){
							lDA = Utils.modA( Math.PI - secureACos( ( x - pBox.x - pBox.width) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lARight - lDA)) lALeft = lDA;
						}
						
						addBPair( lALeft, lARight);
						
						if ( pReflectTransmit) reflectSpeed( Utils.midA( lALeft, lARight));
					}else{
						// déjà absorbé, sortie par le haut
						addBStack( 0, pBox.y - y - ray);
						
						if ( pReflectTransmit) if ( vy > 0) { vy = -vy; onSpeedReflected( null); }
					}
				}	
			}
		}else{
			if ( ( pBox.x - lMidX) * lDY - ( pBox.y + pBox.height - lMidY) * lDX > 0){
				// gauche
				
				if ( x - ray > pBox.x - diskAbsorbOffset) {
					// absorbé ?
					
					if ( y < lMidY){
						if ( y - ray < pBox.y - diskAbsorbOffset){
							// sortie par le haut
							
							if ( isPairsValid){
								lDA = secureACos( ( pBox.y - y) / ray);
								
								addBPair( Utils.modA( Math.PI / 2 - lDA), Utils.modA( Math.PI / 2 + lDA));
							}else{
								addBStack( 0, pBox.y - y - ray);//addBStack( pBox.x - x - ray, 0);
							}
							
							if ( pReflectTransmit) if ( vy > 0) { vy = -vy; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par la gauche
							addBStack( pBox.x - x - ray, 0);
							
							if ( pReflectTransmit) if ( vx > 0) { vx = -vx; onSpeedReflected( null); }
						}
					}else{
						if ( y + ray > pBox.y + pBox.height + diskAbsorbOffset){
							// sortie par la bas
							
							if ( isPairsValid){
								lDA = secureACos( ( y - pBox.y - pBox.height) / ray);
								
								addBPair( Utils.modA( 3 * Math.PI / 2 - lDA), Utils.modA( 3 * Math.PI / 2 + lDA));
							}else{
								addBStack( 0, pBox.y + pBox.height - y + ray);
							}
							
							if ( pReflectTransmit) if ( vy < 0) { vy = -vy; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par la gauche
							addBStack( pBox.x - x - ray, 0);
							
							if ( pReflectTransmit) if ( vx > 0) { vx = -vx; onSpeedReflected( null); }
						}
					}
				}else{
					if ( isPairsValid){
						lDA		= secureACos( ( pBox.x - x) / ray);
						lALeft	= Utils.modA( -lDA);
						lARight	= Utils.modA( lDA);
						
						if ( y - ray < pBox.y - diskAbsorbOffset){
							lDA = Utils.modA( Math.PI / 2 - secureACos( ( pBox.y - y) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lARight - lDA)) lALeft = lDA;
						}
						
						if ( y + ray > pBox.y + pBox.height + diskAbsorbOffset){
							lDA = Utils.modA( 3 * Math.PI / 2 + secureACos( ( y - pBox.y - pBox.height) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lDA - lALeft)) lARight = lDA;
						}
						
						addBPair( lALeft, lARight);
						
						if ( pReflectTransmit) reflectSpeed( Utils.midA( lALeft, lARight));
					}else{
						// déjà absorbé, sortie par la gauche
						addBStack( pBox.x - x - ray, 0);
						
						if ( pReflectTransmit) if ( vx > 0) { vx = -vx; onSpeedReflected( null); }
					}
				}
			}else{
				// bas
				
				if ( y + ray < pBox.y + pBox.height + diskAbsorbOffset){
					// absorbé ?
					
					if ( x < lMidX){
						if ( x - ray < pBox.x - diskAbsorbOffset){
							// sortie par la gauche
							
							if ( isPairsValid){
								lDA = secureACos( ( pBox.x - x) / ray);
								
								addBPair( Utils.modA( -lDA), Utils.modA( lDA));
							}else{
								addBStack( pBox.x - x - ray, 0);
							}
							
							if ( pReflectTransmit) if ( vx > 0) { vx = -vx; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par le bas
							addBStack( 0, pBox.y + pBox.height - y + ray);
							
							if ( pReflectTransmit) if ( vy < 0) { vy = -vy; onSpeedReflected( null); }
						}
					}else{
						if ( x + ray > pBox.x + pBox.width + diskAbsorbOffset){
							// sortie par la droite
							
							if ( isPairsValid){
								lDA = secureACos( ( x - pBox.x - pBox.width) / ray);
								
								addBPair( Utils.modA( Math.PI - lDA), Utils.modA( Math.PI + lDA));
							}else{
								addBStack( pBox.x + pBox.width - x + ray, 0);
							}
							
							if ( pReflectTransmit) if ( vx < 0) { vx = -vx; onSpeedReflected( null); }
						}else{
							// absorbé, sortie par le bas
							addBStack( 0, pBox.y + pBox.height - y + ray);
							
							if ( pReflectTransmit) if ( vy < 0) { vy = -vy; onSpeedReflected( null); }
						}
					}
				}else{
					if ( isPairsValid){
						lDA		= secureACos( ( y - pBox.y - pBox.height) / ray);
						lALeft	= Utils.modA( 3 * Math.PI / 2 - lDA);
						lARight	= Utils.modA( 3 * Math.PI / 2 + lDA);
						
						if ( x - ray < pBox.x - diskAbsorbOffset){
							lDA = Utils.modA( -secureACos( ( pBox.x - x) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lARight - lDA)) lALeft = lDA;
						}
						
						if ( x + ray > pBox.x + pBox.width + diskAbsorbOffset){
							lDA = Utils.modA( Math.PI + secureACos( ( x - pBox.x) / ray));
							
							if ( Utils.modA( lARight - lALeft) > Utils.modA( lDA - lALeft)) lARight = lDA;
						}
						
						addBPair( lALeft, lARight);
						
						if ( pReflectTransmit) reflectSpeed( Utils.midA( lALeft, lARight));
					}else{
						// déjà absorbé, sortie par le bas
						addBStack( 0, pBox.y + pBox.height - y + ray);
						
						if ( pReflectTransmit) if ( vy < 0){ vy = -vy; onSpeedReflected( null); }
					}
				}
			}
		}
	}
	
	function reflectSpeed( pReflectA : Float) : Void {
		var lCos	: Float		= Math.cos( pReflectA);
		var lSin	: Float		= Math.sin( pReflectA);
		var lScalar	: Float		= vx * lCos + vy * lSin;
		var lPX		: Float;
		var lPY		: Float;
		
		if ( lScalar > 0){
			vx	-= 2 * lScalar * lCos;
			vy	-= 2 * lScalar * lSin;
			
			onSpeedReflected( null);
		}
	}
	
	public function doBounceInsideBox( pBox : Rectangle, pReflectTransmit : Bool = true) : Void {
		var lDA	: Float;
		
		if ( x - ray < pBox.x){
			// gauche
			
			if ( x + ray > pBox.x + diskAbsorbOffset && isPairsValid){
				lDA = secureACos( ( x - pBox.x) / ray);
				
				addBPair( Utils.modA( Math.PI - lDA), Utils.modA( Math.PI + lDA));
			}else{
				// absorb
				addBStack( pBox.x - x + ray, 0);
			}
			
			if ( pReflectTransmit){
				if ( vx < 0){
					vx = -vx;
					onSpeedReflected( null);
				}
			}
		}else if ( x + ray > pBox.x + pBox.width){
			// droite
			
			if ( x - ray < pBox.x + pBox.width - diskAbsorbOffset && isPairsValid){
				lDA = secureACos( ( pBox.x + pBox.width - x) / ray);
				
				addBPair( Utils.modA( -lDA), Utils.modA( lDA));
			}else{
				// absorb
				addBStack( pBox.x + pBox.width - x - ray, 0);
			}
			
			if ( pReflectTransmit){
				if ( vx > 0){
					vx = -vx;
					onSpeedReflected( null);
				}
			}
		}
		
		if ( y - ray < pBox.y){
			// haut
			
			if ( y + ray > pBox.y + diskAbsorbOffset && isPairsValid){
				lDA = secureACos( ( y - pBox.y) / ray);
				
				addBPair( Utils.modA( 3 * Math.PI / 2 - lDA), Utils.modA( 3 * Math.PI / 2 + lDA));
			}else{
				// absorb
				addBStack( 0, pBox.y - y + ray);
			}
			
			if ( pReflectTransmit){
				if ( vy < 0){
					vy = -vy;
					onSpeedReflected( null);
				}
			}
		}else if ( y + ray > pBox.y + pBox.height){
			// bas
			
			if ( y - ray < pBox.y + pBox.height - diskAbsorbOffset && isPairsValid){
				lDA = secureACos( ( pBox.y + pBox.height - y) / ray);
				
				addBPair( Utils.modA( Math.PI / 2 - lDA), Utils.modA( Math.PI / 2 + lDA));
			}else{
				// absorb
				addBStack( 0, pBox.y + pBox.height - y - ray);
			}
			
			if ( pReflectTransmit){
				if ( vy > 0){
					vy = -vy;
					onSpeedReflected( null);
				}
			}
		}
	}
	
	public function flush() : Void {
		bPairs			= [];
		bStack			= new Point();
		isPairsValid	= true;
	}
	
	public function doFrame() : Bool {
		doPhys();
		
		return doBounce();
	}
	
	public function doPhys() : Void {
		var lLen	: Float;
		
		vx	+= ( accFX - vx * frot) / masse;
		vy	+= ( accFY - vy * frot) / masse;
		
		lLen = vx * vx + vy * vy;
		if ( lLen > maxV * maxV){
			lLen	= Math.sqrt( lLen);
			
			vx	*= maxV / lLen;
			vy	*= maxV / lLen;
		}
		
		accFX	= 0;
		accFY	= 0;
		
		x		+= vx;	
		y		+= vy;
	}
	
	public function doBounce() : Bool {
		var lIsBounce	: Bool	= false;
		
		if ( isPairsValid){
			if ( bPairs.length > 0){
				lIsBounce = true;
				
				doPairBounce();
			}
		}else if ( bStack.x != 0 || bStack.y != 0){
			lIsBounce = true;
			
			doStackBounce();
		}
		
		flush();
		
		return lIsBounce;
	}
	
	public function halt() : Void {
		vx = 0;
		vy = 0;
		accFX = 0;
		accFY = 0;
		
		flush();
	}
	
	function onSpeedReflected( pByDisk : MyDiskBounce) : Void { }
	
	function addBPair( pModALeft : Float, pModARight : Float) : Void {
		var lI	: Int;
		
		lI = 0;
		while ( lI < bPairs.length){
			if ( Utils.isAInSector( pModARight, bPairs[ lI].x, bPairs[ lI].y)){
				if ( Utils.isAInSector( pModALeft, bPairs[ lI].x, bPairs[ lI].y)){
					if ( Utils.isAInSector( bPairs[ lI].x, pModALeft, pModARight)){
						// tout le cercle est compris, aucun secteur privilégié, abort
						isPairsValid = false;
					}
				}else{
					// nouvelle paire déborde la paire lI sur la gauche
					bPairs[ lI].x = pModALeft;
				}
				
				return;
			}if ( Utils.isAInSector( pModALeft, bPairs[ lI].x, bPairs[ lI].y)){
				// nouvelle paire déborde la paire lI sur la droite
				bPairs[ lI].y = pModARight;
				return;
			}else if( Utils.isAInSector( bPairs[ lI].x, pModALeft, pModARight)){
				// nouvelle paire déborde la paire lI des 2 côtés
				bPairs[ lI].x = pModALeft;
				bPairs[ lI].y = pModARight;
				return;
			}else{
				// aucune intersection
				if ( pModARight < bPairs[ lI].y){
					// insertion, nouvelle paire à gauche de lI
					bPairs.insert( lI, new Point( pModALeft, pModARight));
					return;
				}
			}
			
			lI++;
		}
		
		// nouvelle paire à droite des autres
		bPairs.push( new Point( pModALeft, pModARight));
	}
	
	function addBStack( pDX : Float, pDY : Float) : Void {
		isPairsValid = false;
		
		bStack.x	+= pDX;
		bStack.y	+= pDY;
	}
	
	function doReflectTransmit( pDisk : MyDiskBounce, pA : Float) : Void {
		var lCos	: Float		= Math.cos( pA);
		var lSin	: Float		= Math.sin( pA);
		var lP1		: Float		= vx * lCos + vy * lSin;
		var lP2		: Float		= pDisk.vx * lCos + pDisk.vy * lSin;
		var lMu		: Float;
		var lR		: Float;
		var lVX		: Float;
		var lVY		: Float;
		
		if( lP1 >= 0 && lP1 > lP2 || lP1 <= 0 && lP2 < lP1){
			if ( ! pDisk.isFixed){
				lMu			= 1 / ( ( 1 / masse) + ( 1 / pDisk.masse));
				lR			= 2 * lMu * ( lP2 - lP1);
				
				vx			+= ( lR * lCos) / ( masse);
				vy			+= ( lR * lSin) / ( masse);
				pDisk.vx	-= ( lR * lCos) / ( pDisk.masse);
				pDisk.vy	-= ( lR * lSin) / ( pDisk.masse);
			}else{
				lVX			= vx - pDisk.vx;
				lVY			= vy - pDisk.vy;
				
				lP1			= lVX * lCos + lVY * lSin;
				
				vx			= lVX - 2 * lP1 * lCos + pDisk.vx;
				vy			= lVY - 2 * lP1 * lSin + pDisk.vy;
			}
			
			onSpeedReflected( pDisk);
		}
	}
	
	function extrapolateLongestPair() : Point {
		var lRes		: Point	= new Point( bPairs[ 0].x, bPairs[ bPairs.length - 1].y);
		var lFreeLen	: Float	= Utils.modA( lRes.x - lRes.y);
		var lI			: Int	= 1;
		var lTmp		: Float;
		
		while ( lI < bPairs.length){
			lTmp = Utils.modA( bPairs[ lI].x - bPairs[ lI - 1].y);
			
			if ( lTmp > lFreeLen){
				lTmp	= lFreeLen;
				
				lRes.x	= bPairs[ lI].x;
				lRes.y	= bPairs[ lI - 1].y;
			}
			
			lI++;
		}
		
		return lRes;
	}
	
	function doPairBounce() : Void {
		var lPair	: Point		= extrapolateLongestPair();
		var lDiff	: Float		= Utils.modA( lPair.y - lPair.x);
		var lA		: Float		= Utils.midA( lPair.x, lPair.y);
		var lCos	: Float		= -Math.cos( lA);
		var lSin	: Float		= -Math.sin( lA);
		var lDist	: Float;
		
		if ( lDiff < Math.PI){
			lDist	= Math.max( bMin, ( 1 - Math.cos( lDiff / 2)) * ray * bCoefPairs);
		}else{
			lDist	= Math.max( bMin, ( 1 + Math.cos( ( 2 * Math.PI - lDiff) / 2)) * ray * bCoefPairs);
		}
		
		x		+= lCos * lDist;
		y		+= lSin * lDist;
		
		if ( isGlobalBounce) onGlobalBounce( lCos, lSin);
	}
	
	function doStackBounce() : Void {
		var lA	: Float;
		
		x		+= bStack.x * bCoefStack;
		y		+= bStack.y * bCoefStack;
		
		if ( isGlobalBounce){
			lA	= Math.atan2( bStack.y, bStack.x);
			
			onGlobalBounce( Math.cos( lA), Math.sin( lA));
		}
	}
	
	/**
	 * on résoud la réaction à une collision de manière globale
	 * @param	pCos	composante x unitaire du vecteur de sortie de collision
	 * @param	pSin	composante y unitaire du vecteur de sortie de collision
	 */
	function onGlobalBounce( pCos : Float, pSin : Float) : Void {
		var lScalar	: Float	= pCos * vx + pSin * vy;
		
		if ( lScalar < 0){
			vx	-= lScalar * pCos * ( 1 + globalBounceCoef);
			vy	-= lScalar * pSin * ( 1 + globalBounceCoef);
		}
	}
	
	function secureACos( pVal : Float) : Float {
		if ( pVal <= -1) return Math.PI;
		else if ( pVal >= 1) return 0;
		else return Math.acos( pVal);
	}
}