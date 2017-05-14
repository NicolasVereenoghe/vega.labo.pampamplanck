package vega.shell;

import js.Browser;
import js.html.Event;
import pixi.core.Pixi;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import pixi.core.text.Text;
import pixi.core.utils.Utils;
import pixi.interaction.InteractionEvent;
import pixi.plugins.app.Application;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author nico
 */
class ApplicationMatchSize extends Application {
	public static var instance					: ApplicationMatchSize;
	
	/** flag indiquant si on est en debug (true) ou pas (false) ; en debug, on affiche les trace de debugpar dessus l'appli */
	public var debug							: Bool			= false;
	/** true si traces de debug visibles dès l'init, false si ils sont invisibles */
	public var debugVisibleInit					: Bool			= false;
	/** code rgb de couleur de font de debug */
	public var debugRGB							: String		= "#444444";
	/** niveau de trace de debug ; { "" | "INFO" | "WARNING" | "ERROR"} */
	public var debugLvl							: String		= "WARNING";
	/** liste de motifs à afficher si trouvés dans chaine de trace debug, malgré le level de debug */
	public var debugMotifs						: Array<String>	= null;
	/** taille de font de trace debug */
	public var debugFontSize					: Int			= 25;
	
	public var version							: String;
	
	public var vars								: Dynamic;
	
	/** frame rate conjoncturel de l'appli */
	var tmpFPS									: Int			= -1;
	/** flag indiquant si le fps contextuel est forcé (true) ou pas (false) ; si fps contextuel forcé, on ne l'utilise plus tant qu'on n'invoque pas sa restauration (voir ::restaureFPS) */
	var isFPSForced								: Bool			= false;
	
	var _MIN_WIDTH								: Float			= 960;
	var _MIN_HEIGHT								: Float			= 640;
	
	var _EXT_WIDTH								: Float			= 1136;
	var _EXT_HEIGHT								: Float			= 720;
	
	var BORDER									: Float			= 2000;
	
	var _content								: Container;
	
	var _container								: Container;
	var _borders								: Graphics		= null;
	var _bg										: Graphics;
	
	var _tmpW									: Float			= -1;
	var _tmpH									: Float			= -1;
	
	/** conteneur de trace de debug ; null si pas encore construit */
	var _debugContainer							: Container		= null;
	/** conteneur de bt switch de trace debug */
	var _debugSwitchBt							: Container		= null;
	/** conteneur de bt cls de trace debug */
	var _debugClsBt								: Container		= null;
	/** compteur de lignes de debug */
	var _debugCtrLine							: Int			= 0;
	
	/** zone de hit global, scalé comme le conteneur principal, et dont la taille du contenu (Graphics child en 0) est adaptée pour recouvrir tout l'écran */
	var _hit									: Container;
	
	var _baseScale								: Float;
	var _screenRect								: Rectangle;
	
	public function new() {
		super();
		
		instance = this;
		
		vars = {};
		
		init();
	}
	
	public function getHit() : DisplayObject { return _hit; }
	
	public function getContent() : Container { return _content; }
	
	/**
	 * on effectue un trace de debug, par dessus l'appli, seulement si on est en debug
	 * @param	pTxt	ligne de trace
	 * @param	pForce	true pour ignorer le niveau de debug et tracer quand même, sinon laisser false
	 */
	public function traceDebug( pTxt : String, pForce : Bool = false) : Void {
		var lTxt	: Text;
		var lMax	: Int;
		
		trace( pTxt);
		
		if ( debug){
			if( ! ( pForce || detectDebugMotifIn( pTxt))){
				if ( debugLvl == "INFO"){
					if ( pTxt.indexOf( "INFO") == -1 && pTxt.indexOf( "WARNING") == -1 && pTxt.indexOf( "ERROR") == -1) return;
				}else if ( debugLvl == "WARNING"){
					if ( pTxt.indexOf( "WARNING") == -1 && pTxt.indexOf( "ERROR") == -1) return;
				}else if ( debugLvl == "ERROR"){
					if ( pTxt.indexOf( "ERROR") == -1) return;
				}
			}
			
			if ( _debugContainer == null){
				_debugContainer		= cast _container.addChild( new Container());
				_debugContainer.x	= _screenRect.x;
				_debugContainer.y	= _screenRect.y;
				
				_debugContainer.visible = debugVisibleInit;
				
				_debugContainer.interactiveChildren = false;
				
				_debugSwitchBt		= cast _container.addChild( new Container());
				_debugSwitchBt.addChild( new Graphics());
				cast( _debugSwitchBt.getChildAt( 0), Graphics).beginFill( 0, 0);
				cast( _debugSwitchBt.getChildAt( 0), Graphics).drawRect( 0, 0, 25, 25);
				cast( _debugSwitchBt.getChildAt( 0), Graphics).endFill();
				_debugSwitchBt.x	= _screenRect.x;
				_debugSwitchBt.y	= _screenRect.y;
				
				UtilsPixi.setQuickBt( _debugSwitchBt, onBtSwitchTrace);
				
				_debugClsBt			= cast _container.addChild( new Container());
				_debugClsBt.addChild( new Graphics());
				cast( _debugClsBt.getChildAt( 0), Graphics).beginFill( 0, 0);
				cast( _debugClsBt.getChildAt( 0), Graphics).drawRect( 0, -25, 25, 25);
				cast( _debugClsBt.getChildAt( 0), Graphics).endFill();
				_debugClsBt.x		= _screenRect.x;
				_debugClsBt.y		= _screenRect.y + _screenRect.height;
				
				UtilsPixi.setQuickBt( _debugClsBt, onBtClsTrace);
			}
			
			lTxt = new Text(
				pTxt,
				{
					//"font": debugFontSize + "px Arial",
					"fontFamily": "Arial",
					"fontSize": debugFontSize,
					"fill": debugRGB//"#444444"//"#FF0088"
				}
			);
			
			_debugContainer.addChild( lTxt);
			_debugCtrLine++;
			lTxt.y				= -( _debugCtrLine - 1) * debugFontSize;
			_debugContainer.y	= _screenRect.y + ( _debugCtrLine - 1) * debugFontSize;
			
			while ( _debugContainer.children.length > Math.ceil( _EXT_HEIGHT / debugFontSize)) _debugContainer.removeChildAt( 0).destroy();
		}
	}
	
	/**
	 * capture switch affichage de trace
	 * @param	pE	target de click
	 */
	function onBtSwitchTrace( pE : InteractionEvent) : Void { _debugContainer.visible = ! _debugContainer.visible; }
	
	/**
	 * capture cls de trace
	 * @param	pE	tacraget de click
	 */
	function onBtClsTrace( pE : InteractionEvent) : Void {
		_debugCtrLine = 0;
		
		while ( _debugContainer.children.length > 0) _debugContainer.removeChildAt( 0).destroy();
	}
	
	/**
	 * on détecte la présence de l'un des motifs de trace debug dans la chaine de trace passée
	 * @param	pTxt	chaine de trace
	 * @return	true si un motif détecté, false sinon
	 */
	function detectDebugMotifIn( pTxt : String) : Bool {
		var lMot	: String;
		
		if ( debugMotifs != null && debugMotifs.length > 0){
			for ( lMot in debugMotifs){
				if ( pTxt.indexOf( lMot) != -1) return true;
			}
		}
		
		return false;
	}
	
	/**
	 * on récupère le rectangle étendu ( zone visible + marges) de vue sur contenu déjà scalé
	 * @return	rectangle de coordonnées de vue étendue centrée sur contenu scalé
	 */
	public function getScreenRectExt() : Rectangle { return new Rectangle( -_EXT_WIDTH / 2, -_EXT_HEIGHT / 2, _EXT_WIDTH, _EXT_HEIGHT); }
	
	/**
	 * on récupère le rectangle min ( zone visible la plus petite) de vue sur contenu déjà scalé
	 * @return	rectangle de coordonnées de vue minimale centrée sur contenu scalé
	 */
	public function getScreenRectMin() : Rectangle { return new Rectangle( -_MIN_WIDTH / 2, -_MIN_HEIGHT / 2, _MIN_WIDTH, _MIN_HEIGHT); }
	
	/**
	 * on récupère le rectangle de vue (zone visible) sur contenu déjà scalé
	 * @return	rectangle de coordonnées de vue centrée sur contenu scalé
	 */
	public function getScreenRect() : Rectangle { return _screenRect; }
	
	/**
	 * on défini un fps conjoncturel pour l'appli. ce fps peut évoluer et être forcé (voir ::forceFPS) pour ensuite être restitué au dernier fps conjoncturel défini (voir ::restaureFPS)
	 * @param	pFPS	fps conjoncturel de l'appli
	 */
	public function setFPS( pFPS : Int) : Void {
		tmpFPS = pFPS;
		if ( ! isFPSForced) set_fps( pFPS);
	}
	
	/**
	 * on restitue le dernier FPS conjoncturel défini pour l'appli
	 */
	public function restaureFPS() : Void {
		isFPSForced = false;
		set_fps( tmpFPS);
	}
	
	/**
	 * on force le fps contextuel ; ce qui est défini en contextuel est ignoré tant qu'on n'invoque pas sa restauration (voir ::restaureFPS)
	 * @param	pFPS	fps forcé
	 */
	public function forceFPS( pFPS : Int) : Void {
		isFPSForced = true;
		set_fps( pFPS);
	}
	
	/** fps arbitraire défini pour l'application ; c'est virtuel, le rendu pixi est déjà configué par défaut (souvent à 60) */
	public var fps( get, set)		: Int;
	var _fps						: Int								= -1;
	function get_fps() : Int { return _fps; }
	function set_fps( pFPS : Int) : Int {
		// NON ! juste un getter : app.ticker.FPS = pFPS;
		// peut-on modifier ce fps courrant d'une certaine manière ?
		
		return _fps = pFPS;
	}
	
	/**
	 * on demande à la page de recharger l'appli ; ne fonction que dans un context de browser
	 * @return	true si la demande aboutit, false sinon
	 */
	public function reload() : Bool {
		//var lId	: String;
		
		if ( Browser.supported){
			try{
				traceDebug( "WARNING : ApplicationMatchSize::reload");
				
				//for ( lId in Reflect.fields( Utils.TextureCache)) Reflect.field( Utils.TextureCache, lId).destroy( true);
				Utils.destroyTextureCache();
			}catch ( pE : Dynamic) traceDebug( "ERROR : ApplicationMatchSize::reload : clear textures failure");
			
			stage.interactiveChildren	= false;
			stage.interactive			= false;
			
			Browser.document.location.reload( true);
			
			return true;
		}else{
			traceDebug( "ERROR : ApplicationMatchSize::reload : no browser, fail");
			
			return false;
		}
	}
	
	/**
	 * on force une mise à jour du rendu ; hack iOS pour récupérer d'une mise en veille
	 */
	public function refreshRender() : Void {
		renderer.resize( 1, 1);
		_onWindowResize( null);
	}
	
	/**
	 * hack pour éviter le clignotement sur de vieux devices ; on force un resize à la taille actuelle ; à appeler une fois quand on est au title screen
	 */
	public function antiFlicker() : Void { renderer.resize( width, height); }
	
	/**
	 * on force la réinitialisation des interactions de bouton / touche
	 * hack pour fixer un bug qui apparait quand on switch les propriétés "interactiveChildren"
	 */
	public function refreshInteraction() : Void {
		pauseRendering();
		resumeRendering();
	}
	
	function init(){
		var lVars	: Array<String>;
		var lKV		: Array<String>;
		var lI		: String;
		var lGraph	: Graphics;
		
		if ( Browser.supported){
			lVars = Browser.window.location.search.substring( 1).split( "&");
			
			for ( lI in lVars){
				lKV = lI.split( "=");
				
				Reflect.setField( vars, lKV[ 0], lKV[ 1]);
			}
		}
		
		backgroundColor = getStageBGColor();
		
		// hack samsung flicker
		/*try{
			var lPixi:Dynamic = untyped __js__("PIXI");
			lPixi.glCore.VertexArrayObject.FORCE_NATIVE = true;
		}catch( pE : Dynamic) { trace( pE); }*/
		
		start();
		
		_hit		= cast stage.addChild( new Container());
		lGraph		= cast _hit.addChild( new Graphics());
		lGraph.beginFill( 0, 0);
		lGraph.drawRect( -100, -100, 200, 200);
		lGraph.endFill();
		_hit.interactive = true;
		
		_container	= new Container();
		stage.addChild( _container);
		
		_bg = new Graphics();
		_bg.beginFill( getBGColor());
		_bg.drawRect( -_EXT_WIDTH / 2, -_EXT_HEIGHT / 2, _EXT_WIDTH, _EXT_HEIGHT);
		_bg.endFill();
		_container.addChild( _bg);
		
		_content	= new Container();
		_container.addChild( _content);
		
		////////////
		//stage.interactive = true;
		////////////
		
		onResize = updateSize;
		
		updateSize();
	}
	
	function getBGColor() : Int { return 0xFFFFFF; }
	function getStageBGColor() : Int { return 0x000000; }
	
	override function _onWindowResize( pE : Event) {
		var lW		: Float	= Browser.window.innerWidth;
		var lH		: Float	= Browser.window.innerHeight;
		var lIsUp	: Bool	= ( pE == null);
		
		if ( _tmpW < 0 || Math.round( lW) != Math.round( _tmpW) && Browser.window.outerWidth != 0){
			_tmpW	= width = lW;
			lIsUp	= true;
		}
		
		if ( _tmpH < 0 || Math.round( lH) != Math.round( _tmpH) && Browser.window.outerHeight != 0){
			_tmpH	= height = lH;
			lIsUp	= true;
		}
		
		if ( ! lIsUp) return;
		
		app.renderer.resize( width, height);
		
		canvas.style.width	= width + "px";
		canvas.style.height	= height + "px";

		if ( onResize != null) onResize();
	}
	
	function updateSize() : Void {
		var lNewW	: Float	= width;
		var lNewH	: Float	= lNewW * _MIN_HEIGHT / _MIN_WIDTH;
		
		if ( lNewH > height) lNewW = height * _MIN_WIDTH / _MIN_HEIGHT;
		
		_baseScale			= lNewW / _MIN_WIDTH;
		
		lNewW				= Math.min( width / _baseScale, _EXT_WIDTH);
		lNewH				= Math.min( height / _baseScale, _EXT_HEIGHT);
		
		_screenRect			= new Rectangle( -lNewW / 2, -lNewH / 2, lNewW, lNewH);
		
		_container.scale.x	= _baseScale;
		_container.scale.y	= _baseScale;
		_container.x		= width / 2;
		_container.y		= height / 2;
		
		_hit.scale.x		= _baseScale;
		_hit.scale.y		= _baseScale;
		_hit.x				= width / 2;
		_hit.y				= height / 2;
		cast( _hit.getChildAt( 0), Graphics).width	= width / _baseScale;
		cast( _hit.getChildAt( 0), Graphics).height	= height / _baseScale;
		
		if ( _borders == null){
			_borders	= new Graphics();
			
			_borders.beginFill( backgroundColor);
			_borders.drawRect( -_EXT_WIDTH / 2 - BORDER, -_EXT_HEIGHT / 2 - BORDER, BORDER, _EXT_HEIGHT + 2 * BORDER);
			_borders.drawRect( -_EXT_WIDTH / 2 - BORDER, -_EXT_HEIGHT / 2 - BORDER, _EXT_WIDTH + 2 * BORDER, BORDER);
			_borders.drawRect( -_EXT_WIDTH / 2 - BORDER, _EXT_HEIGHT / 2, _EXT_WIDTH + 2 * BORDER, BORDER);
			_borders.drawRect( _EXT_WIDTH / 2, -_EXT_HEIGHT / 2 - BORDER, BORDER, _EXT_HEIGHT + 2 * BORDER);
			_borders.endFill();
			
			_container.addChild( _borders);
		}
		
		traceDebug( "INFO : ApplicationMatchSize::updateSize : scale=" + ( Math.round( _baseScale * 100) / 100) + " ; screen=" + Math.round( _screenRect.width) + "x" + Math.round( _screenRect.height) + " ; stage=" + width + "x" + height, true);
		
		if ( _debugContainer != null){
			_debugContainer.x	= _screenRect.x;
			_debugContainer.y	= _screenRect.y + ( _debugCtrLine - 1) * debugFontSize;
			
			_debugSwitchBt.x	= _screenRect.x;
			_debugSwitchBt.y	= _screenRect.y;
			
			_debugClsBt.x		= _screenRect.x;
			_debugClsBt.y		= _screenRect.y + _screenRect.height;
		}
		
		ResizeBroadcaster.getInstance().broadcastResize();
	}
}