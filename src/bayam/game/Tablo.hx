package bayam.game;

import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.math.Point;
import pixi.flump.Movie;
import planck.Body;
import planck.Contact;
import planck.Fixture.FixtureDef;
import planck.Settings;
import planck.World;
import planck.shape.BoxShape;
import planck.shape.CircleShape;
import planck.shape.EdgeShape;
import planck.common.Vec2;
import planck.shape.PolygonShape;
import vega.shell.ApplicationMatchSize;
import vega.sound.SndMgr;
import vega.utils.UtilsFlump;

import haxe.extern.EitherType;

/**
 * ...
 * @author 
 */
class Tablo extends Container {
	public static inline var SCALE				: Float						= 30;
	
	public static inline var WIDTH				: Float						= 640;
	public static inline var HEIGHT				: Float						= 457;
	public static inline var HEIGHT_FULL		: Float						= 480;
	
	public static var nivoSol(get, null)		: Float;
	public static function get_nivoSol() : Float { return HEIGHT / SCALE; }
	
	public var m_world							: World						= null;
	
	var DEFAULT_TYPE							: String					= Body.DYNAMIC;//Body.KINEMATIC;
	var MOBILE_MASSE_COEF						: Float						= 3;
	
	var m_timeStep								: Float						= 1 / 30;
	var m_iterations_p							: Int						= 10;
	var m_iterations_v							: Int						= 100;//10;
	
	var bounds									: Body						= null;
	var ground									: Body						= null;
	
	var mgr										: MyGMgr					= null;
	
	var balancePos								: Map<String,Point>			= null;
	
	public function new( pMgr : MyGMgr) {
		super();
		
		mgr = pMgr;
		
		balancePos = new Map<String,Point>();
		
		initB2D();
	}
	
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		m_world.off( World.WORLD_CONTACT_BEGIN, onWorldContactBegin);
		
		clear();
		
		m_world.destroyBody( ground);
		ground = null;
		
		m_world.destroyBody( bounds);
		bounds = null;
		
		m_world = null;
		
		balancePos = null;
		
		mgr = null;
		
		super.destroy( true);
	}
	
	public function reset() : Void {
		var lBody	: Body				= m_world.getBodyList();
		var lResets	: Array<Container>	= new Array<Container>();
		var lTmp	: Body;
		var lDisp	: Container;
		
		while ( lBody != null){
			if ( Std.is( lBody.getUserData(), Container)){
				lDisp = cast lBody.getUserData();
				
				if ( lDisp.name.indexOf( MyGMgr.LAYER_BALANCE_RADIX) != -1){
					lDisp.rotation	= 0;
					lDisp.x			= balancePos.get( lDisp.name).x;
					lDisp.y			= balancePos.get( lDisp.name).y;
					
					lTmp = lBody.getNext();
					
					lBody.setUserData( null);
					m_world.destroyBody( lBody);
					
					lBody = lTmp;
					
					lResets.push( lDisp);
					
					continue;
				}
			}
			
			lBody = lBody.getNext();
		}
		
		for ( iDisp in lResets) createBalance( iDisp);
	}
	
	public function clear() : Void {
		var lBody	: Body	= m_world.getBodyList();
		
		while ( lBody != null){
			if ( lBody != bounds && lBody != ground) m_world.destroyBody( lBody);
			
			lBody = lBody.getNext();
		}
		
		balancePos = new Map<String,Point>();
	}
	
	public function doFrame( pDt : Float) : Void {
		var lBody	: Body;
		var lDisp	: DisplayObject;
		
		m_world.step( m_timeStep, m_iterations_v, m_iterations_p);
		
		lBody = m_world.getBodyList();
		while ( lBody != null){
			if ( Std.is( lBody.getUserData(), DisplayObject)){
				lDisp			= cast lBody.getUserData();
				lDisp.x			= lBody.getPosition().x * SCALE;
				lDisp.y			= lBody.getPosition().y * SCALE;
				lDisp.rotation	= lBody.getAngle();
				
				if ( lDisp.name == MyGMgr.LAYER_BALLE){
					if ( ! lBody.isAwake()) mgr.onBalleStoped();
					else if ( lDisp.x < WIDTH / 2 - ApplicationMatchSize.instance.getScreenRect().width / mgr.getTableauScale() / 2 || lDisp.y > WIDTH / 2 + ApplicationMatchSize.instance.getScreenRect().width / mgr.getTableauScale() / 2) mgr.onBalleOut();
				}
			}
			
			lBody = lBody.getNext();
		}
	}
	
	public function setHitZoneCrap( pLayerCrap : Container) : Body {
		var lBody = m_world.createBody( {
			position: new Vec2( pLayerCrap.x / SCALE, pLayerCrap.y / SCALE),
			userData: pLayerCrap
		});
		
		lBody.createFixture( {
			friction: 1,
			filterMaskBits: 4,
			shape: new BoxShape( pLayerCrap.width / SCALE / 10, pLayerCrap.height / SCALE / 3)
		});
		
		lBody.createFixture( {
			friction: 1,
			filterMaskBits: 4,
			restitution: .2,
			shape: new CircleShape( new Vec2( 0, -2), .6)
		});
		
		return lBody;
	}
	
	public function createBoite( pLayer : Container, pIsMobile : Bool) : Body {
		var lMovie	: Movie			= cast pLayer.getChildAt( 0);
		var lBody	: Body			= m_world.createBody( {
			position: new Vec2( pLayer.x / SCALE, pLayer.y / SCALE),
			userData: pLayer
		});
		var lDef	: FixtureDef	= { filterCategoryBits: 4, friction: 1};
		var lVec2s	: Array<Vec2>;
		var lI		: Int;
		var lChild	: DisplayObject;
		var lLayer	: Container;
		
		if ( pIsMobile){
			lBody.setType( DEFAULT_TYPE);
			lDef.density = .15 * MOBILE_MASSE_COEF;
		}
		
		if ( pLayer.name.charAt( 6) == "T"){
			lVec2s	= [];
			lI		= 0;
			
			while ( lI < lMovie.children.length){
				lChild = lMovie.getChildAt( lI++);
				
				if ( lChild.name.charAt( 0) == "p"){
					lVec2s.push( new Vec2(
						Math.floor( 10 * lChild.x / SCALE) / 10,
						Math.floor( 10 * lChild.y / SCALE) / 10
					));
				}
			}
			
			lDef.shape = new PolygonShape( lVec2s);
		}else if ( pLayer.name.charAt( 6) == "R"){
			lLayer		= lMovie.getLayer( MyGMgr.LAYER_RECT_BOUNDS);
			lDef.shape	= new BoxShape( lLayer.width / SCALE / 2, lLayer.height / SCALE / 2);
		}
		
		lBody.createFixture( lDef);
		
		return lBody;
	}
	
	public function setSupportSam( pLayer : Container) : Void {
		var lLayer	: Container	= cast( pLayer.getChildAt( 0), Movie).getLayer( MyGMgr.LAYER_RECT_BOUNDS);
		
		m_world.createBody( new Vec2( pLayer.x / SCALE, pLayer.y / SCALE)).createFixture( {
			friction: 1,
			filterMaskBits: 4,
			shape: new BoxShape( lLayer.width / SCALE / 2, lLayer.height / SCALE / 2)
		});
	}
	
	public function createBalle( pLayer : Container, pIsRight : Bool) : Body {
		var lBody	: Body	= m_world.createBody( {
			position: new Vec2( pLayer.x / SCALE, pLayer.y / SCALE),
			userData: pLayer,
			type: DEFAULT_TYPE,
			linearDamping: mgr.getLvlId() < 5 ? .05 : .4
		});
		
		lBody.createFixture( {
			filterCategoryBits: 4,
			friction: 15,
			density: .6 * MOBILE_MASSE_COEF,
			shape: new CircleShape( .8)
		});
		
		if ( pIsRight) lBody.applyLinearImpulse( new Vec2( 8 * MOBILE_MASSE_COEF, 0), lBody.getWorldCenter(), true);
		else lBody.applyLinearImpulse( new Vec2( -8 * MOBILE_MASSE_COEF, 0), lBody.getWorldCenter(), true);
		
		return lBody;
	}
	
	public function createBalance( pLayer : Container) : Void {
		var lBody	: Body	= m_world.createBody( {
			position: new Vec2( pLayer.x / SCALE, pLayer.y / SCALE),
			userData: pLayer,
			type: DEFAULT_TYPE
		});
		
		balancePos.set( pLayer.name, new Point( pLayer.x, pLayer.y));
		
		lBody.createFixture( {
			filterCategoryBits: 4,
			friction: 10,
			density: 10,
			shape: new BoxShape( .1, .8, new Vec2( 0, .6), 0)
		});
		
		lBody.createFixture( {
			filterCategoryBits: 4,
			friction: 10,
			density: 10,
			shape: new BoxShape( 4, .2)
		});
	}
	
	public function createSpecial( pLayer : Container) : Void {
		var lBody	: Body		= m_world.createBody( {
			position: new Vec2( pLayer.x / SCALE, pLayer.y / SCALE),
			userData: pLayer
		});
		var lTag	: String	= pLayer.name.charAt( 7);
		
		if ( lTag == "J"){
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .6, .2, new Vec2( -.4, .1), 0)
			});
			
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .2, .5, new Vec2( .1, -.2), 0)
			});
		}else if ( lTag == "L"){
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .6, .2, new Vec2( .5, .1), 0)
			});
			
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .2, .5, new Vec2( .1, -.2), 0)
			});
		}else if ( lTag == "N"){
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .7, .2, new Vec2( -.45, .1), 0)
			});
			
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .2, .6, new Vec2( .1, .5), 0)
			});
		}else{
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .7, .2, new Vec2( .55, 0), 0)
			});
			
			lBody.createFixture( {
				filterCategoryBits: 4,
				friction: 1,
				shape: new BoxShape( .2, .7, new Vec2( .1, .5), 0)
			});
		}
	}
	
	public function createSpecialU( pLayer : Container) : Body {
		var lMovie	: Movie			= cast pLayer.getChildAt( 0);
		var lBody	: Body			= m_world.createBody( {
			position: new Vec2( pLayer.x / SCALE, pLayer.y / SCALE),
			userData: pLayer,
			type: DEFAULT_TYPE
		});
		var lDef	: FixtureDef	= {
			filterCategoryBits: 4,
			friction: 10,
			density: 1
		};
		var lVec2s	: Array<Vec2>	= [];
		var lI		: Int			= 0;
		var lChild	: DisplayObject;
		
		// polygon
		while ( lI < lMovie.children.length){
			lChild = lMovie.getChildAt( lI++);
			
			if ( lChild.name.charAt( 0) == "p"){
				lVec2s.push( new Vec2(
					Math.floor( 10 * lChild.x / SCALE) / 10,
					Math.floor( 10 * lChild.y / SCALE) / 10
				));
			}
		}
		
		lDef.shape = new PolygonShape( lVec2s);
		
		lBody.createFixture( lDef);
		
		// rectangle 1
		lBody.createFixture( {
			filterCategoryBits: 4,
			friction: 10,
			density: 1,
			shape: new BoxShape( .2, .85, new Vec2( -.5, -2), 0)
		});
		
		// rectangle 2
		lBody.createFixture( {
			filterCategoryBits: 4,
			friction: 10,
			density: 1,
			shape: new BoxShape( .85, .2, new Vec2( 2, .5), 0)
		});
		
		return null;
	}
	
	function initB2D() : Void {
		m_world = new World( new Vec2( 0, 30));
		
		bounds = m_world.createBody();
		bounds.createFixture( { shape: new EdgeShape( new Vec2( -100, -100), new Vec2( 100, -100))});
		bounds.createFixture( { shape: new EdgeShape( new Vec2( 100, -100), new Vec2( 100, 100))});
		bounds.createFixture( { shape: new EdgeShape( new Vec2( 100, 100), new Vec2( -100, 100))});
		bounds.createFixture( { shape: new EdgeShape( new Vec2( -100, 100), new Vec2( -100, -100))});
		
		ground = m_world.createBody( { position: new Vec2( WIDTH / SCALE / 2, nivoSol)});
		ground.createFixture( {
			friction: .1,
			filterCategoryBits: 2,
			shape: new BoxShape( ApplicationMatchSize.instance.getScreenRectExt().width / mgr.getTableauScale() / SCALE, .5)
		});
		
		m_world.on( World.WORLD_CONTACT_BEGIN, onWorldContactBegin);
	}
	
	function onWorldContactBegin( pContact : Contact) : Void {
		var lDispA	: DisplayObject;
		var lDispB	: DisplayObject;
		
		if ( pContact.getFixtureA().getBody().getUserData() != null && pContact.getFixtureB().getBody().getUserData() != null){
			lDispA	= cast pContact.getFixtureA().getBody().getUserData();
			lDispB	= cast pContact.getFixtureB().getBody().getUserData();
			
			if ( lDispA.name == MyGMgr.LAYER_BALLE || lDispB.name == MyGMgr.LAYER_BALLE){
				if ( lDispA.name == MyGMgr.LAYER_CRAP || lDispB.name == MyGMgr.LAYER_CRAP) mgr.onBalleHitCrap();
			}
		}
	}
}