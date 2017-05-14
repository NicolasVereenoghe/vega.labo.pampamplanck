package vega.paddle;

import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.interaction.InteractionEvent;
import pixi.interaction.InteractionData;
import vega.paddle.MyTouchPaddle.TouchDesc;
import vega.shell.ApplicationMatchSize;
import vega.utils.PointIJ;

/**
 * paddle directionnel controlé au slide sur écran
 * 
 * @author nico
 */
class MyTouchPaddle implements IDirectionPaddle {
	/** identifiant de touche de la souris */
	var TOUCH_MOUSE_ID				: String						= "mouse";
	
	/** dt max en ms de calcul entre 2 itérations de frame */
	var DT_MAX						: Float							= 70;
	
	/** temps en ms d'empilement de touches avant d'avoir un résultat de direction */
	var STACK_TOUCH_TIME			: Float							= 80;
	
	/** coef d'inertie par dt appliqué à l'ancre de position */
	var ANCHOR_INERTIA_DT			: Float							= .015;
	/** rayon inerte autour du point d'ancre ; max pixels par ms*/
	var ANCHOR_INERT_RAY_DT			: Float							= 10 / ( 1000 / 30);//5 / ( 1000 / 30);
	/** rayon minimal de prise de mesure de mouvement ; max pixels par ms */
	var MESURE_RAY_MIN				: Float							= 1 / ( 1000 / 30);
	
	/** temps en ms de neutralité entre 2 directions antagonistes */
	var NEUTRAL						: Float							= 90;// 110;// 150;
	
	/** secteur angulaire direction "droite" en rad, sur ]-pi..pi] */
	var ANGULAR_RIGHT				: Array<Float>					= [ -Math.PI * 3 / 8, Math.PI * 3 / 8];
	/** secteur angulaire direction "bas" en rad, sur ]-pi..pi] */
	var ANGULAR_BOT					: Array<Float>					= [ Math.PI * 9 / 32, Math.PI * 23 / 32];//[ Math.PI / 4, Math.PI * 3 / 4];//[ Math.PI / 8, Math.PI * 7 / 8];
	/** secteur angulaire direction "droite" en rad, sur ]-pi..pi] */
	var ANGULAR_LEFT				: Array<Float>					= [ Math.PI * 5 / 8, -Math.PI * 5 / 8];
	/** secteur angulaire direction "droite" en rad, sur ]-pi..pi] */
	var ANGULAR_TOP					: Array<Float>					= [ -Math.PI * 7 / 8, -Math.PI / 8];
	
	/** pile des points de touches actifs, indexés par ordre d'arrivé (0 : le + vieux, n-1 le + récent) */
	var datas						: Array<TouchDesc>;
	/** touche courrante */
	var data						: TouchDesc;
	
	/** dernier point de touche utilisé comme ancrage à l'itération précédente ; null si aucun */
	var anchor						: TouchDesc;
	
	/** pile de directions de touches indexée par ancienneté : 0 = ancien .. n-1 = courrant */
	var dirs						: Array<TouchDirTime>;
	
	/** vecteurs direction unitaire horizontale (i) et direction unitaire verticale (j) */
	var curDir						: PointIJ;
	
	/** vecteurs verrous des axes horizontaux (i) et verticaux (j) */
	var locks						: PointIJ;
	
	/** compteurs de neutralité des axes horizontaux (x) et verticaux (y), en ms */
	var neutralsDT					: Point;
	/** directions d'axes neutralisées, i pour direction horizontal et j pour verticales */
	var neutrals					: PointIJ;
	
	/**
	 * construction
	 */
	public function new() {
		var lAnchor	: DisplayObject	= getEventAnchor();
		
		datas		= [];
		dirs		= [];
		curDir		= new PointIJ();
		locks		= new PointIJ();
		neutrals	= new PointIJ();
		neutralsDT	= new Point();
		
		lAnchor.on( "mousedown", onMouseDown);
		lAnchor.on( "mouseup", onMouseUp);
		lAnchor.on( "mouseupoutside", onMouseUp);
		lAnchor.on( "mouseout", onMouseUp);
		lAnchor.on( "mousemove", onMouseMove);
		
		lAnchor.on( "touchstart", onTouchDown);
		lAnchor.on( "touchend", onTouchUp);
		lAnchor.on( "touchendoutside", onTouchUp);
		lAnchor.on( "touchmove", onTouchMove);
	}
	
	/** @inheritDoc */
	public function doFrame( pDT : Float) : Void {
		var lILock	: Bool			= false;
		var lJLock	: Bool			= false;
		var lDelt	: Point;
		var lCoef	: Float;
		var lDir	: TouchDirTime;
		var lI		: Int;
		var lI2		: Int;
		var lCtrT	: Float;
		var lIsRes	: Bool;
		var lA		: Float;
		
		pDT = Math.min( pDT, DT_MAX);
		
		if ( data != null){
			if ( anchor != null && anchor.id == data.id){
				lCoef			= Math.pow( 1 - ANCHOR_INERTIA_DT, pDT);
				anchor.coord.x	= lCoef * anchor.coord.x + ( 1 - lCoef) * ( data.coord.x * ANCHOR_INERTIA_DT) / ANCHOR_INERTIA_DT;
				anchor.coord.y	= lCoef * anchor.coord.y + ( 1 - lCoef) * ( data.coord.y * ANCHOR_INERTIA_DT) / ANCHOR_INERTIA_DT;
				
				lDelt			= new Point( data.coord.x - anchor.coord.x, data.coord.y - anchor.coord.y);
				
				if ( locks.i > 0){
					if ( lDelt.x > 0){
						lDelt.x = 0;
						anchor.coord.x = data.coord.x;
						lILock = true;
					}
				}else if ( locks.i < 0){
					if ( lDelt.x < 0){
						lDelt.x = 0;
						anchor.coord.x = data.coord.x;
						lILock = true;
					}
				}
				
				if ( locks.j > 0){
					if ( lDelt.y > 0){
						lDelt.y = 0;
						anchor.coord.y = data.coord.y;
						lJLock = true;
					}
				}else if ( locks.j < 0){
					if ( lDelt.y < 0){
						lDelt.y = 0;
						anchor.coord.y = data.coord.y;
						lJLock = true;
					}
				}
				
				if ( lDelt.x * lDelt.x + lDelt.y * lDelt.y > ANCHOR_INERT_RAY_DT * pDT * ANCHOR_INERT_RAY_DT * pDT){
					dirs.push( new TouchDirTime( pDT, lDelt));
				}else{
					if( dirs.length > 0) dirs.push( new TouchDirTime( pDT, null));
				}
				
				lDelt = null;
				lI = dirs.length - 1;
				lI2 = -1;
				lCtrT = 0;
				lIsRes = false;
				while ( lI >= 0){
					lCtrT += dirs[ lI].dt;
					
					if ( dirs[ lI].dir == null){
						if( lI2 == -1) lI2 = lI + 1;
					}else{
						lI2 = -1;
						if ( lDelt != null){
							lDelt.x += dirs[ lI].dir.x;
							lDelt.y += dirs[ lI].dir.y;
						}else lDelt = new Point( dirs[ lI].dir.x, dirs[ lI].dir.y);
					}
					
					if ( lCtrT >= STACK_TOUCH_TIME){
						if ( lDelt != null){
							lIsRes = true;
							lDelt.x /= lCtrT;
							lDelt.y /= lCtrT;
						}
						
						break;
					}
					
					lI--;
				}
				
				if ( lI > 0) dirs.splice( 0, lI > lI2 ? lI : lI2);
				
				if ( dirs.length > 0 && lIsRes){
					lA = Math.atan2( lDelt.y, lDelt.x);
					
					if ( Math.abs( lDelt.x) >= MESURE_RAY_MIN){
						if ( lA > ANGULAR_RIGHT[ 0] && lA < ANGULAR_RIGHT[ 1]){
							if ( curDir.i == -1){
								neutrals.i = curDir.i;
								neutralsDT.x = pDT;
								
								curDir.i = 0;
								for ( lDir in dirs) lDir.dir = null;
							}else{
								if ( neutrals.i == -1) neutralsDT.x += pDT;
								else if ( neutrals.i != 0) neutrals.i = 0;
								
								curDir.i = 1;
							}
							
							if ( locks.i == 1) curDir.i = 0;
							else locks.i = 0;
						}else if ( lA > ANGULAR_LEFT[ 0] || lA < ANGULAR_LEFT[ 1]){
							if ( curDir.i == 1){
								neutrals.i = curDir.i;
								neutralsDT.x = pDT;
								
								curDir.i = 0;
								for ( lDir in dirs) lDir.dir = null;
							}else{
								if ( neutrals.i == 1) neutralsDT.x += pDT;
								else if ( neutrals.i != 0) neutrals.i = 0;
								
								curDir.i = -1;
							}
							
							if ( locks.i == -1) curDir.i = 0;
							else locks.i = 0;
						}else{
							if ( neutrals.i != 0) neutralsDT.x += pDT;
							else if ( curDir.i != 0){
								neutrals.i = curDir.i;
								neutralsDT.x = pDT;
							}
							
							curDir.i = 0;
							
							if ( ! lILock) locks.i = 0;
						}
					}else{
						if ( neutrals.i != 0) neutralsDT.x += pDT;
						else if ( curDir.i != 0){
							neutrals.i = curDir.i;
							neutralsDT.x = pDT;
						}
						
						curDir.i = 0;
						
						if ( ! lILock) locks.i = 0;
					}
					
					if ( Math.abs( lDelt.y) >= MESURE_RAY_MIN){
						if ( lA > ANGULAR_BOT[ 0] && lA < ANGULAR_BOT[ 1]){
							/*if ( curDir.j == -1){
								neutrals.j = curDir.j;
								neutralsDT.y = pDT;
								
								curDir.j = 0;
								for ( lDir in dirs) lDir.dir = null;
							}else{
								if ( neutrals.j == -1) neutralsDT.y += pDT;
								else if ( neutrals.j != 0) neutrals.j = 0;
								
								curDir.j = 1;
							}*/
							curDir.j = 1;
							// neutralisation verticale désactivée
							
							if ( locks.j == 1) curDir.j = 0;
							else locks.j = 0;
						}else if ( lA > ANGULAR_TOP[ 0] && lA < ANGULAR_TOP[ 1]){
							/*if ( curDir.j == 1){
								neutrals.j = curDir.j;
								neutralsDT.y = pDT;
								
								curDir.j = 0;
								for ( lDir in dirs) lDir.dir = null;
							}else{
								if ( neutrals.j == 1) neutralsDT.y += pDT;
								else if ( neutrals.j != 0) neutrals.j = 0;
								
								curDir.j = -1;
							}*/
							curDir.j = -1;
							// neutralisation verticale désactivée
							
							if ( locks.j == -1) curDir.j = 0;
							else locks.j = 0;
						}else{
							/*if ( neutrals.j != 0) neutralsDT.y += pDT;
							else if ( curDir.j != 0){
								neutrals.j = curDir.j;
								neutralsDT.y = pDT;
							}*/
							// neutralisation verticale désactivée
							
							curDir.j = 0;
							
							if ( ! lJLock) locks.j = 0;
						}
					}else{
						/*if ( neutrals.j != 0) neutralsDT.y += pDT;
						else if ( curDir.j != 0){
							neutrals.j = curDir.j;
							neutralsDT.y = pDT;
						}*/
						// neutralisation verticale désactivée
						
						curDir.j = 0;
						
						if ( ! lJLock) locks.j = 0;
					}
				}else{
					if ( ! lILock) locks.i = 0;
					if ( ! lJLock) locks.j = 0;
					
					if ( neutrals.i != 0){
						neutralsDT.x += pDT;
						
						if ( neutralsDT.x >= NEUTRAL){
							curDir.i = 0;
							neutrals.i = 0;
						}
					}
					
					/*if ( neutrals.j != 0){
						neutralsDT.y += pDT;
						
						if ( neutralsDT.y >= NEUTRAL){
							curDir.j = 0;
							neutrals.j = 0;
						}
					}*/
					// neutralisation verticale désactivée
				}
			}else{
				anchor = data.clone();
				
				dirs = [];
				curDir.i = 0;
				curDir.j = 0;
				locks.i = 0;
				locks.j = 0;
				neutrals.i = 0;
				neutrals.j = 0;
				neutralsDT.x = 0;
				neutralsDT.y = 0;
			}
		}else{
			anchor = null;
			
			dirs = [];
			curDir.i = 0;
			curDir.j = 0;
			locks.i = 0;
			locks.j = 0;
			neutrals.i = 0;
			neutrals.j = 0;
			neutralsDT.x = 0;
			neutralsDT.y = 0;
		}
	}
	
	/** @inheritDoc */
	public function destroy() : Void {
		var lAnchor	: DisplayObject	= getEventAnchor();
		
		lAnchor.off( "mousedown", onMouseDown);
		lAnchor.off( "mouseup", onMouseUp);
		lAnchor.off( "mouseupoutside", onMouseUp);
		lAnchor.off( "mouseout", onMouseUp);
		lAnchor.off( "mousemove", onMouseMove);
		
		lAnchor.off( "touchstart", onTouchDown);
		lAnchor.off( "touchend", onTouchUp);
		lAnchor.off( "touchendoutside", onTouchUp);
		lAnchor.off( "touchmove", onTouchMove);
		
		neutralsDT = null;
		neutrals = null;
		locks = null;
		curDir = null;
		dirs = null;
		datas = null;
		anchor = null;
		data = null;
	}
	
	/** @inheritDoc */
	public function getCurDir() : PointIJ { return curDir; }
	
	/** @inheritDoc */
	public function lockDir( pLock : PointIJ) : Void {
		var lDir	: TouchDirTime;
		
		if ( pLock.i != 0 && curDir.i == pLock.i){
			locks.i = pLock.i;
			
			curDir.i = 0;
			for ( lDir in dirs) lDir.dir = null;
		}
		
		if ( pLock.j != 0 && curDir.j == pLock.j){
			locks.j = pLock.j;
			
			curDir.j = 0;
			for ( lDir in dirs) lDir.dir = null;
		}
	}
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant d'ancrage aux évent de touch / mouse
	 * @return	objet d'affichage
	 */
	function getEventAnchor() : DisplayObject { return ApplicationMatchSize.instance.getHit();/*ApplicationMatchSize.instance.stage;*/ }
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant de repère de coordonnées
	 * @return	objet d'affichage
	 */
	function getRepere() : DisplayObject { return ApplicationMatchSize.instance.getContent(); }
	
	/**
	 * on vérifie si une touche est active dans la pile temporisée
	 * @param	pId	id de touche
	 * @return	ref sur la touche, ou null si pas trouvée
	 */
	function getDatas( pId : String) : TouchDesc {
		var lDesc	: TouchDesc;
		
		for ( lDesc in datas){
			if ( lDesc.id == pId) return lDesc;
		}
		
		return null;
	}
	
	/**
	 * on cherche et on retire une touche de la pile temporisée
	 * @param	pId	id de touche
	 * @return	ref sur la touche retirée, ou null si pas trouvée
	 */
	function remDatas( pId : String) : TouchDesc {
		var lDesc	: TouchDesc	= getDatas( pId);
		
		if ( lDesc != null) datas.remove( lDesc);
		
		return lDesc;
	}
	
	function onTouchDown( pE : InteractionEvent) : Void {
		var lData	: TouchDesc	= new TouchDesc( Std.string( pE.data.identifier), pE.data.getLocalPosition( getRepere()));
		
		if ( data != null && data.id != lData.id && data.id != TOUCH_MOUSE_ID){
			remDatas( lData.id);
			datas.push( lData);
		}else {
			data = lData;
		}
	}
	
	function onTouchUp( pE : InteractionEvent) : Void {
		var lId		: String	= Std.string( pE.data.identifier);
		
		if ( data != null){
			if ( data.id == TOUCH_MOUSE_ID){
				data = null;
			}else if ( data.id != lId){
				remDatas( lId);
			}else{
				if ( datas.length > 0) data = datas.pop();
				else data = null;
			}
		}
	}
	
	function onTouchMove( pE : InteractionEvent) : Void {
		var lId		: String	= Std.string( pE.data.identifier);
		var lCoord	: Point		= pE.data.getLocalPosition( getRepere());
		var lData	: TouchDesc;
		
		if ( data != null && data.id != TOUCH_MOUSE_ID){
			if ( data.id != lId){
				lData = getDatas( lId);
				
				if ( lData != null) lData.coord = lCoord;
				else datas.push( new TouchDesc( lId, lCoord));
			}else{
				data.coord = lCoord;
			}
		}else data = new TouchDesc( lId, lCoord);
	}
	
	function onMouseDown( pE : InteractionEvent) : Void {
		if( datas.length > 0) datas = [];
		data = new TouchDesc( TOUCH_MOUSE_ID, pE.data.getLocalPosition( getRepere()));
		
	}
	
	function onMouseUp( pE : InteractionEvent) : Void {
		if( datas.length > 0) datas = [];
		data = null;
	}
	
	function onMouseMove( pE : InteractionEvent) : Void {
		if( datas.length > 0) datas = [];
		
		if ( data != null && data.id == TOUCH_MOUSE_ID){
			data.coord = pE.data.getLocalPosition( getRepere());
		}else{
			data = null;
		}
	}
}

/**
 * descripteur de touche
 */
class TouchDesc {
	/** identifiant de touche */
	public var id			: String;
	/** coordonnées de touche */
	public var coord		: Point;
	
	public function new( pId : String, pCoord : Point) {
		id		= pId;
		coord	= pCoord;
	}
	
	public function clone() : TouchDesc { return new TouchDesc( id, coord.clone()); }
}

/**
 * direction de touche timée
 */
class TouchDirTime {
	/** écart de temps en ms lors de la prise de cette direction de touche */
	public var dt			: Float;
	/** direction de touche */
	public var dir			: Point;
	
	public function new( pDt : Float, pDir : Point) {
		dt	= pDt;
		dir	= pDir;
	}
}