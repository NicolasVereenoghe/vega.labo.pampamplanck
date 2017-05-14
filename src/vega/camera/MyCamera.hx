package vega.camera;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;

/**
 * ...
 * @author nico
 */
class MyCamera {
	var _MIN_DIST					: Float							= .5;
	
	var _INERT_DIST_X				: Float							= 100;
	var _MAX_INERTIA_DELT_X			: Float							= 220;
	var MAX_INERTIA_X				: Float							= 1 / 6;
	var MIN_INERTIA_X				: Float							= 0;
	
	var _INERT_DIST_Y				: Float							= 100;
	var _MAX_INERTIA_DELT_Y			: Float							= 220;
	var MAX_INERTIA_Y				: Float							= 1 / 6;
	var MIN_INERTIA_Y				: Float							= 0;
	
	var INERTIA_DELT_I				: Float							= 1 / 26;//1 / 18;
	
	var inertiaLeft					: Float							= 0;
	var inertiaRight				: Float							= 0;
	var inertiaTop					: Float							= 0;
	var inertiaBottom				: Float							= 0;
	
	var _OFFSET_X					: Float;
	var _OFFSET_Y					: Float;
	
	var _SCREEN_W					: Float;
	var _SCREEN_H					: Float;
	
	var _x							: Float;
	var _y							: Float;
	
	var _clipRect					: Rectangle;
	
	/** scale de zoom appliqué à la caméra */
	var _zoomScale					: Float							= 1;
	
	public function new() { }
	
	/**
	 * on fixe la vue initiale ainsi que les params de position et de de dimension de la caméra
	 * @param	pInitX		abscisse initiale centre écran
	 * @param	pInitY		ordonnée initiale centre écran
	 * @param	pOffsetX	composante x de décalage entre position de l'origine de scène en caméra 0, et centre réel de l'écran
	 * @param	pOffsetY	composante y de décalage entre position de l'origine de scène en caméra 0, et centre réel de l'écran
	 * @param	pScreenW	largeur d'écran
	 * @param	pScreenH	hauteur d'écran
	 */
	public function init( pInitX : Float, pInitY : Float, pOffsetX : Float, pOffsetY : Float, pScreenW : Float, pScreenH : Float) : Void {
		_OFFSET_X	= pOffsetX;
		_OFFSET_Y	= pOffsetY;
		_SCREEN_W	= pScreenW;
		_SCREEN_H	= pScreenH;
		_x			= pInitX;
		_y			= pInitY;
		
		updateClipRect();
	}
	
	public function getZoomScale() : Float { return _zoomScale; }
	public function getScreenMidX() : Float { return _x; }
	public function getScreenMidY() : Float { return _y;}
	public function getX() : Float { return getOFFSET_X() - _x; }
	public function getY() : Float { return getOFFSET_Y() - _y; }
	public function getClipRect() : Rectangle { return _clipRect; }
	public function getSCREEN_W() : Float { return _SCREEN_W / _zoomScale; }
	public function getSCREEN_H() : Float { return _SCREEN_H / _zoomScale; }
	
	/**
	 * on effectue un saut sans inertie de la caméra vers le nouveau point de vue
	 * @param	pView	point de vue dans repère caméra, visé par rapport au centre de caméra ; réf temporisée et modifiée en interne si on tappe une limite
	 */
	public function jumpTo( pView : Point) : Void {
		inertiaLeft		= MAX_INERTIA_X;
		inertiaRight	= MAX_INERTIA_X;
		inertiaTop		= MAX_INERTIA_Y;
		inertiaBottom	= MAX_INERTIA_Y;
		
		_x	= pView.x;
		_y	= pView.y;
		
		updateClipRect();
	}
	
	/**
	 * on fait glisser la caméra vers le point de vue précisé
	 * @param	pView		point de vue dans repère caméra, visé par rapport au centre de caméra ; réf temporisée et modifiée en interne si on tappe une limite
	 * @param	pZoomScale	forcer un scale de zoom sur la caméra ; laisser -1 pour garder celui en cours
	 */
	public function slideTo( pView : Point, pZoomScale : Float = -1) : Void {
		var lDeltX	: Float	= pView.x - _x;
		var lDeltY	: Float	= pView.y - _y;
		var lRate	: Float;
		var lDelt	: Float;
		
		if ( pZoomScale > 0) _zoomScale = pZoomScale;
		
		if ( lDeltX > getINERT_DIST_X()) {
			lRate			= Math.min( 1, ( lDeltX - getINERT_DIST_X()) / getMAX_INERTIA_DELT_X());
			inertiaLeft		= MIN_INERTIA_X;
			inertiaRight	+= ( lRate * MAX_INERTIA_X - inertiaRight) * INERTIA_DELT_I;
		}else if ( lDeltX < -getINERT_DIST_X()) {
			lRate			= Math.min( 1, -( lDeltX + getINERT_DIST_X()) / getMAX_INERTIA_DELT_X());
			inertiaLeft		+= ( lRate * MAX_INERTIA_X - inertiaLeft) * INERTIA_DELT_I;
			inertiaRight	= MIN_INERTIA_X;
		}else {
			inertiaLeft		-= ( inertiaLeft - MIN_INERTIA_X) * INERTIA_DELT_I;
			inertiaRight	-= ( inertiaRight - MIN_INERTIA_X) * INERTIA_DELT_I;
		}
		
		lDelt = Math.max( inertiaLeft, inertiaRight) * lDeltX;
		if ( Math.abs( lDelt) > getMIN_DIST()) _x += lDelt;
		
		if ( lDeltY > getINERT_DIST_Y()) {
			lRate			= Math.min( 1, ( lDeltY - getINERT_DIST_Y()) / getMAX_INERTIA_DELT_Y());
			inertiaTop		= MIN_INERTIA_Y;
			inertiaBottom	+= ( lRate * MAX_INERTIA_Y - inertiaBottom) * INERTIA_DELT_I;
		}else if ( lDeltY < -getINERT_DIST_Y()) {
			lRate			= Math.min( 1, -( lDeltY + getINERT_DIST_Y()) / getMAX_INERTIA_DELT_Y());
			inertiaTop		+= ( lRate * MAX_INERTIA_Y - inertiaTop) * INERTIA_DELT_I;
			inertiaBottom	= MIN_INERTIA_Y;
		}else {
			inertiaTop		-= ( inertiaTop - MIN_INERTIA_Y) * INERTIA_DELT_I;
			inertiaBottom	-= ( inertiaBottom - MIN_INERTIA_Y) * INERTIA_DELT_I;
		}
		
		lDelt = Math.max( inertiaTop, inertiaBottom) * lDeltY;
		if ( Math.abs( lDelt) > getMIN_DIST()) _y += lDelt;
		
		updateClipRect();
	}
	
	function getOFFSET_X() : Float { return _OFFSET_X / _zoomScale; }
	function getOFFSET_Y() : Float { return _OFFSET_Y / _zoomScale; }
	function getMIN_DIST() : Float { return _MIN_DIST / _zoomScale; }
	function getINERT_DIST_X() : Float { return _INERT_DIST_X / _zoomScale; }
	function getINERT_DIST_Y() : Float { return _INERT_DIST_Y / _zoomScale; }
	function getMAX_INERTIA_DELT_X() : Float { return _MAX_INERTIA_DELT_X / _zoomScale; }
	function getMAX_INERTIA_DELT_Y() : Float { return _MAX_INERTIA_DELT_Y / _zoomScale; }
	
	function updateClipRect() : Void { _clipRect = new Rectangle( _x - getSCREEN_W() / 2, _y - getSCREEN_H() / 2, getSCREEN_W(), getSCREEN_H()); }
}