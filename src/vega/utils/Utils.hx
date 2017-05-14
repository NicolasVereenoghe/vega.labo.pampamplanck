package vega.utils;

/**
 * ...
 * @author nico
 */
class Utils {
	/** The lowest integer value in Flash and JS. */
    public static inline var INT_MIN	: Int	= -2147483648;
	/** The highest integer value in Flash and JS. */
    public static inline var INT_MAX	: Int	= 2147483647;
	
	/** an arbitrary epsilon constant */
	public static inline var EPSILON	: Float	= 1e-8;
	
	public static function minInt( pA : Int, pB : Int) : Int { return pA < pB ? pA : pB; }
	public static function maxInt( pA : Int, pB : Int) : Int { return pA > pB ? pA : pB; }
	
	public static function isMapEmpty( pMap : Map<Dynamic,Dynamic>) : Bool {
		var lVal : Dynamic;
		
		if ( pMap == null) return true;
		
		for ( lVal in pMap) return false;
		
		return true;
	}
	
	public static function cloneMap( pMap : Map<Dynamic,Dynamic>) : Map<Dynamic,Dynamic> {
		var lClone	: Map<Dynamic,Dynamic>	= Type.createInstance( Type.getClass( pMap), []);
		var lKey	: Dynamic;
		
		for ( lKey in pMap.keys()) lClone.set( lKey, pMap.get( lKey));
		
		return lClone;
	}
	
	public static function doesInherit( pSon : Class<Dynamic>, pMother : Class<Dynamic>) : Bool {
		if ( pSon == null) return false;
		
		//if ( Type.getClassName( pSon) == Type.getClassName( pMother)) return true;
		if ( pSon == pMother) return true;
		
		return doesInherit( Type.getSuperClass( pSon), pMother);
	}
	
	/**
	 * on calcule l'angle médian d'un secteur d'angle
	 * @param	pModALeft	angle sur [ 0 .. 2PI [ de borne gauche (début, sens trigo) de secteur
	 * @param	pModARight	angle sur [ 0 .. 2PI [ de borne droite (fin, sens trigo) de secteur
	 * @return	angle médian sur [ 0 .. 2PI [
	 */
	public static function midA( pModALeft : Float, pModARight : Float) : Float {
		if ( pModALeft > pModARight) return modA( ( pModALeft + pModARight) / 2 - Math.PI);
		else return ( pModALeft + pModARight) / 2;
	}
	
	/**
	 * on calcule le modulo de l'angle sur [ 0 .. 2PI [
	 * @param	pA	angle en radian
	 * @return	angle sur [ 0 .. 2PI [
	 */
	public static function modA( pA : Float) : Float {
		var l2PI	: Float	= 2 * Math.PI;
		
		pA %= l2PI;
		
		if ( pA < 0) pA = ( pA + l2PI) % l2PI;
		
		return pA;
	}
	
	/**
	 * calcule de racine cubique
	 * @param	pVal	valeur au cube
	 * @return	racine cubique
	 */
	public static function cubeRoot( pVal : Float) : Float {
		if ( pVal < 0) return -Math.pow( -pVal, 1 / 3);
		else return Math.pow( pVal, 1 / 3);
	}
	
	/**
	 * calcul des racines d'un polynome de 3ème deg : ax^3 + bx^2 + cx + d = 0
	 * @param	pA	coef a ; (!=0)
	 * @param	pB	coef b
	 * @param	pC	coef c
	 * @param	pD	coef d
	 * @return	liste de racines possibles : [ x1, x2, x3]
	 */
	public static function poly3( pA : Float, pB : Float, pC : Float, pD : Float) : Array<Float> {
		/*var lP	: Float	= ( 3 * pA * pC - pB * pB) / ( 3 * pA * pA);
		var lQ	: Float	= ( 2 * pB * pB * pB - 9 * pA * pB * pC + 27 * pA * pA * pD) / ( 27 * pA * pA * pA);
		var lD1	: Float	= lQ * lQ + 4 * lP * lP * lP / 27;
		var lX1	: Float	= cubeRoot( ( -lQ - lD1) / 2) + cubeRoot( ( -lQ + lD1) / 2) - pB / ( 3 * pA);
		var lD2	: Float	= ( pB + pA * lX1) * ( pB + pA * lX1) - 4 * pA * ( pC + ( pB + pA * lX1) * lX1);
		
		if ( lD2 < 0) return [ lX1];
		else return[
			lX1,
			( -pB - pA * lX1 - Math.sqrt( lD2)) / ( 2 * pA),
			( -pB - pA * lX1 + Math.sqrt( lD2)) / ( 2 * pA)
		];*/
		
		var lP		: Float			= ( 3 * pA * pC - pB * pB) / ( 3 * pA * pA);
		var lQ		: Float			= ( 2 * pB * pB * pB - 9 * pA * pB * pC + 27 * pA * pA * pD) / ( 27 * pA * pA * pA);
		var lDeprec	: Float			= pB / ( 3 * pA);
		var lD		: Float;
		var lU		: Float;
		var lT		: Float;
		var lK		: Float;
		
		if ( Math.abs( lP) < EPSILON){
			return [ cubeRoot( -lQ) - lDeprec];
		}else if ( Math.abs( lQ) < EPSILON){
			if ( lP < 0) return [ -lDeprec, Math.sqrt( -lP) - lDeprec, -Math.sqrt( -lP) - lDeprec];
			else return [ -lDeprec];
		}else{
			lD = lQ * lQ / 4 + lP * lP * lP / 27;
			
			if ( Math.abs( lD) < EPSILON){
				return [ -1.5 * lQ / lP - lDeprec, 3 * lQ / lP - lDeprec];
			}else if ( lD > 0){
				lU = cubeRoot( -lQ / 2 - Math.sqrt( lD));
				
				return [ lU - lP / ( 3 * lU) - lDeprec];
			}else{
				lU = 2 * Math.sqrt( -lP / 3);
				lT = Math.acos( 3 * lQ / lP / lU) / 3;
				lK = 2 * Math.PI / 3;
				
				return [ lU * Math.cos( lT) - lDeprec, lU * Math.cos( lT - lK) - lDeprec, lU * Math.cos( lT - 2 * lK) - lDeprec];
			}
		}
	}
	
	/*function cuberoot(x) {
		var y = Math.pow(Math.abs(x), 1/3);
		return x < 0 ? -y : y;
	}

	function solveCubic(a, b, c, d) {
		if (Math.abs(a) < 1e-8) { // Quadratic case, ax^2+bx+c=0
			a = b; b = c; c = d;
			if (Math.abs(a) < 1e-8) { // Linear case, ax+b=0
				a = b; b = c;
				if (Math.abs(a) < 1e-8) // Degenerate case
					return [];
				return [-b/a];
			}

			var D = b*b - 4*a*c;
			if (Math.abs(D) < 1e-8)
				return [-b/(2*a)];
			else if (D > 0)
				return [(-b+Math.sqrt(D))/(2*a), (-b-Math.sqrt(D))/(2*a)];
			return [];
		}

		// Convert to depressed cubic t^3+pt+q = 0 (subst x = t - b/3a)
		var p = (3*a*c - b*b)/(3*a*a);
		var q = (2*b*b*b - 9*a*b*c + 27*a*a*d)/(27*a*a*a);
		var roots;

		if (Math.abs(p) < 1e-8) { // p = 0 -> t^3 = -q -> t = -q^1/3
			roots = [cuberoot(-q)];
		} else if (Math.abs(q) < 1e-8) { // q = 0 -> t^3 + pt = 0 -> t(t^2+p)=0
			roots = [0].concat(p < 0 ? [Math.sqrt(-p), -Math.sqrt(-p)] : []);
		} else {
			var D = q*q/4 + p*p*p/27;
			if (Math.abs(D) < 1e-8) {       // D = 0 -> two roots
				roots = [-1.5*q/p, 3*q/p];
			} else if (D > 0) {             // Only one real root
				var u = cuberoot(-q/2 - Math.sqrt(D));
				roots = [u - p/(3*u)];
			} else {                        // D < 0, three roots, but needs to use complex numbers/trigonometric solution
				var u = 2*Math.sqrt(-p/3);
				var t = Math.acos(3*q/p/u)/3;  // D < 0 implies p < 0 and acos argument in [-1..1]
				var k = 2*Math.PI/3;
				roots = [u*Math.cos(t), u*Math.cos(t-k), u*Math.cos(t-2*k)];
			}
		}

		// Convert back from depressed cubic
		for (var i = 0; i < roots.length; i++)
			roots[i] -= b/(3*a);

		return roots;
	}*/
	
	
	/**
	 * on détermine si un angle fait partie d'un secteur angulaire
	 * @param	pModA		angle sur [ 0 .. 2PI [ à tester
	 * @param	pModALeft	angle sur [ 0 .. 2PI [ de borne gauche (début, sens trigo) de secteur
	 * @param	pModARight	angle sur [ 0 .. 2PI [ de borne droite (fin, sens trigo) de secteur
	 * @return	true si l'angle est dans le secteur, false sinon
	 */
	public static function isAInSector( pModA : Float, pModALeft : Float, pModARight : Float) : Bool {
		if ( pModALeft > pModARight){
			if ( pModA < pModALeft) return pModA >= pModALeft - 2 * Math.PI && pModA <= pModARight;
			else return pModA >= pModALeft && pModA <= pModARight + 2 * Math.PI;
		}else{
			return pModA >= pModALeft && pModA <= pModARight;
		}
	}
}