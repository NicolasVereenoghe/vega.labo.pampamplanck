package vega.shell;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.interaction.InteractionEvent;
import pixi.interaction.InteractionData;

/**
 * tracking de coordonnées globales de pointeur
 * 
 * @author nico
 */
class GlobalPointer {
	public static var instance				: GlobalPointer;
	
	/** délai de timeout en ms d'une touche */
	var TIMEOUT								: Float						= 5000;
	/** délai de timeout en ms de souris */
	//var TIMEOUT_MOUSE						: Float						= 5000;
	/** id arbitraire de touche sans id ; semble correspondre à la souris */
	public static inline var DEFAULT_ID		: Int						= 421;
	
	/** flag indiquant que le pointeur actuel est de type "touchpad" (true) ou souris (false) */
	public var isTouchpad					: Bool						= false;
	/** flag indiquant si le pointeur actuel est en train de toucher l'appli (true) ou pas (false) */
	public var isDown						: Bool						= false;
	
	/** pile des points de touches actifs, indexés par ordre d'arrivé (0 : le + vieux, n-1 le + récent) */
	var datas								: Array<TouchDesc>;
	
	/**
	 * on vérifie que l'instance singleton existe et qu'elle est active
	 * @return	true si tout est ok, false si pas prêt
	 */
	public static function isOK() : Bool { return instance != null && instance.getEventAnchor().interactive; }
	
	public function new() {
		var lAnchor	: DisplayObject	= getEventAnchor();
		
		instance	= this;
		datas		= [];
		
		lAnchor.on( "mousedown", onMouseDown);
		lAnchor.on( "mouseup", onMouseUp);
		lAnchor.on( "mouseupoutside", onMouseUp);
		//lAnchor.on( "mouseout", onMouseUp);
		lAnchor.on( "mousemove", onMouseMove);
		
		lAnchor.on( "touchstart", onTouchDown);
		lAnchor.on( "touchend", onTouchUp);
		lAnchor.on( "touchendoutside", onTouchUp);
		lAnchor.on( "touchmove", onTouchMove);
		
		switchEnable( true);
		
		VegaFramer.getInstance().addIterator( doFrame);
	}
	
	/**
	 * on vérifie si une coord de touche passe par dessus un rectangle
	 * @param	pRect	rectangle dans le repère des touches
	 * @return	listes de touches passant par dessus (liste vide si aucune)
	 */
	public function getTouchOverRect( pRect : Rectangle) : Array<TouchDesc> {
		var lRes	: Array<TouchDesc>	= [];
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if ( pRect.contains( lTouch.coord.x, lTouch.coord.y)) lRes.push( lTouch);
		}
		
		return lRes;
	}
	
	/**
	 * on récupère une liste de touches marquées "down"
	 * @return	liste de touches "down", de la plus ancienne (en 0) à la plus récente ( n-1)
	 */
	public function getDownTouches() : Array<TouchDesc> {
		var lRes	: Array<TouchDesc>	= [];
		var lI		: Int				= 0;
		
		while ( lI < datas.length){
			if ( datas[ lI].isDown) lRes.push( datas[ lI]);
			
			lI++;
		}
		
		return lRes;
	}
	
	/**
	 * on récupère le descripteur de touche ayant l'identifiant précisé
	 * @param	pId		identifiant de touche recherchée
	 * @return	descripteur de touche correspondant, ou null si inexistant
	 */
	public function getTouchId( pId : Int) : TouchDesc {
		var lTouch	: TouchDesc;
		
		if ( pId == null) pId = DEFAULT_ID;
		
		for ( lTouch in datas) if ( lTouch.id == pId) return lTouch;
		
		return null;
	}
	
	/**
	 * on essaye de retrouver une touche à partir d'un event de touche
	 * @param	pE	event de touche
	 * @param	pIsMouse	true si event venant de souris, sinon recherche d'identifiant sur toutes les touches
	 * @return	descripteur de touche ou null si pas trouvé
	 */
	public function getTouchEvent( pE : InteractionEvent, pIsMouse : Bool = false) : TouchDesc {
		if ( pIsMouse) return getMouseTouch();
		else return getTouchId( pE.data.identifier);
		// sans InteractionData::identifier
		/*if ( pIsMouse == null) return findNearestPos( pE.data.getLocalPosition( getRepere()), true);
		else if ( pIsMouse) return getMouseTouch();
		else return findNearestPos( pE.data.getLocalPosition( getRepere()));*/
	}
	
	/**
	 * on récupère les coordonnées globales du pointeur
	 * @return	coordonnées globales, ou null si pointeur invalide
	 */
	public function getPointerCoord() : Point {
		if ( datas.length > 0) return datas[ 0].coord;
		
		return null;
	}
	
	/**
	 * on bascule l'activation (perf)
	 * @param	pIsEnable	true pour activé, false pour désactivé
	 */
	public function switchEnable( pIsEnable : Bool) : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : GlobalPointer::switchEnable : " + pIsEnable);
		
		getEventAnchor().interactive = pIsEnable;
		
		flush();
	}
	
	/**
	 * on force la capture d'un event de down qu'on enregistre
	 * (par exemple, un bouton le capture en premier mais peut le transmettre explicitement pour court circuiter la chaine de transmission)
	 * @param	pE			event de down
	 * @param	pIsMouse	true pour désigner un event de souris, false pour le touchpad
	 */
	public function forceCaptureDown( pE : InteractionEvent, pIsMouse : Bool) : Void {
		if ( pIsMouse) onMouseDown( pE);
		else onTouchDown( pE);
		
		pE.stopPropagation();
	}
	
	/**
	 * on reset les données de pointeur
	 */
	public function flush() : Void {
		isDown	= false;
		datas	= [];
	}
	
	/**
	 * itération de frame
	 * @param	pDT	dt en ms
	 */
	function doFrame( pDT : Float) : Void {
		var lI	: Int	= datas.length - 1;
		
		while ( lI >= 0) {
			datas[ lI].delay += pDT;
			
			if ( datas[ lI].isMouse){
				//if ( datas[ lI].delay >= TIMEOUT_MOUSE) datas.remove( datas[ lI]);
			}else{
				if ( datas[ lI].delay >= TIMEOUT) datas.remove( datas[ lI]);
			}
			
			lI--;
		}
		
		checkTouchState();
	}
	
	/**
	 * on retourne une chaine de trace
	 * @return	chaine de trace
	 */
	public function toString() : String {
		var lStr	: String		= "";
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas) lStr += lTouch.id + ":" + Math.round( lTouch.coord.x) + ":" + Math.round( lTouch.coord.y) + ":" + ( lTouch.isDown ? "D" : "U") + ":" + ( lTouch.isMouse ? "M" : "T") + " - ";
		
		return lStr;
	}
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant de repère de coordonnées
	 * @return	objet d'affichage
	 */
	public function getRepere() : DisplayObject { return ApplicationMatchSize.instance.getContent(); }
	
	function onTouchDown( pE : InteractionEvent) : Void {
		datas.push( new TouchDesc( pE.data.getLocalPosition( getRepere()), false, true, pE.data.identifier));
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : GlobalPointer::onTouchDown : " + datas[ datas.length - 1].id, true);
		//ApplicationMatchSize.instance.traceDebug( toString(), true);
		
		checkTouchState();
	}
	
	function onTouchUp( pE : InteractionEvent) : Void {
		// sans InteractionData::identifier
		//var lTouch	: TouchDesc	= findNearestPos( pE.data.getLocalPosition( getRepere()));
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		if ( lTouch != null){
			datas.remove( lTouch);
			checkTouchState();
		}
		
		//ApplicationMatchSize.instance.traceDebug( toString(), true);
	}
	
	function onTouchMove( pE : InteractionEvent) : Void {
		var lPt		: Point		= pE.data.getLocalPosition( getRepere());
		// sans InteractionData::identifier
		//var lTouch	: TouchDesc	= findNearestPos( lPt);
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
		}else{
			datas.push( new TouchDesc( lPt, false, true, pE.data.identifier));
			
			checkTouchState();
		}
	}
	
	function onMouseDown( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= getMouseTouch();
		var lPt		: Point		= pE.data.getLocalPosition( getRepere());
		
		if ( lTouch == null) datas.push( new TouchDesc( lPt, true, true, pE.data.identifier));
		else {
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= true;
		}
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : GlobalPointer::onMouseDown : " + lTouch.id, true);
		//ApplicationMatchSize.instance.traceDebug( pE.data.identifier + " : d : " + toString(), true);
		
		checkTouchState();
	}
	
	function onMouseUp( pE : InteractionEvent) : Void {
		var lPt		: Point		= pE.data.getLocalPosition( getRepere());
		var lTouch	: TouchDesc	= getMouseTouch();
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= false;
		}else{
			datas.push( new TouchDesc( lPt, true, false, pE.data.identifier));
		}
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : GlobalPointer::onMouseUp", true);
		//ApplicationMatchSize.instance.traceDebug( pE.data.identifier + " : u : " + toString(), true);
		
		checkTouchState();
	}
	
	function onMouseMove( pE : InteractionEvent) : Void {
		var lPt		: Point		= pE.data.getLocalPosition( getRepere());
		var lTouch	: TouchDesc	= getMouseTouch();
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
		}else{
			datas.push( new TouchDesc( lPt, true, false, pE.data.identifier));
			
			checkTouchState();
		}
	}
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant d'ancrage aux évent de touch / mouse
	 * @return	objet d'affichage
	 */
	function getEventAnchor() : DisplayObject { return ApplicationMatchSize.instance.stage; }
	
	// sans InteractionData::identifier
	/**
	 * on recherche la touche la plus proche du point précisé ; par défaut, méthode dédiée au touchpad
	 * @param	pPos		position de recherche
	 * @param	pDoMouse	true pour inclure la souris à la recherche, false si que le touch pad
	 * @return	touche enregistrée la plus proche, ou null si rien de trouvé
	 */
	/*function findNearestPos( pPos : Point, pDoMouse : Bool = false) : TouchDesc {
		var lDist	: Float		= -1;
		var lRes	: TouchDesc	= null;
		var lTmp	: Float;
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if( pDoMouse || ( ! lTouch.isMouse)){
				lTmp = ( lTouch.coord.x - pPos.x) * ( lTouch.coord.x - pPos.x) + ( lTouch.coord.y - pPos.y) * ( lTouch.coord.y - pPos.y);
				
				if ( lDist < 0 || lTmp < lDist){
					lDist	= lTmp;
					lRes	= lTouch;
				}
			}
		}
		
		return lRes;
	}*/
	
	/**
	 * on récupère la ref sur la touche de la souris
	 * @return	ref sur touche de souris ou null si aucune
	 */
	function getMouseTouch() : TouchDesc {
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if ( lTouch.isMouse) return lTouch;
		}
		
		return null;
	}
	
	/**
	 * on rafraichit l'état de la touche
	 */
	function checkTouchState() : Void {
		if ( datas.length > 0){
			if ( datas[ 0].isMouse){
				isTouchpad	= false;
				isDown		= datas[ 0].isDown;
			}else{
				isTouchpad	= true;
				isDown		= true;
			}
		}else isDown = false;
	}
}

/**
 * descripteur de touche
 */
class TouchDesc {
	//static var ctrTouch			: Int				= 0;
	
	public var coord			: Point;
	public var delay			: Float;
	public var isMouse			: Bool;
	public var isDown			: Bool;
	public var id				: Int;
	
	public var isBound			: Bool				= false;
	
	public function new( pCoord : Point, pIsMouse : Bool, pIsDown : Bool, pId : Int) {
		coord	= pCoord;
		isMouse	= pIsMouse;
		delay	= 0;
		isDown	= pIsDown;
		//id		= ctrTouch++;
		id		= pId != null ? pId : GlobalPointer.DEFAULT_ID;
	}
}