package planck;

import planck.Contact.ContactEdge;
import planck.Fixture.FixtureDef;
import planck.Joint.JointEdge;
import planck.common.Transform;
import planck.common.Vec2;

import haxe.extern.EitherType;

@:structInit
class BodyDef {
	public var type				: String;
	public var position			: Vec2;
	public var angle			: Float;
	
	public var linearVelocity	: Vec2;
	public var angularVelocity	: Float;

	public var linearDamping	: Float;
	public var angularDamping	: Float;

	public var fixedRotation	: Bool;
	public var bullet			: Bool;
	public var gravityScale		: Float;

	public var allowSleep		: Bool;
	public var awake			: Bool;
	public var active			: Bool;

	public var userData			: Dynamic;
	
	public function new( ?type : String, ?position : Vec2, ?angle : Float, ?linearVelocity : Vec2, ?angularVelocity : Float, ?linearDamping : Float, ?angularDamping : Float, ?fixedRotation : Bool, ?bullet : Bool, ?gravityScale : Float, ?allowSleep : Bool, ?awake : Bool, ?active : Bool, ?userData : Dynamic) {
		this.type				= type != null ?				type				: Body.STATIC;
		this.position			= position != null ?			position			: Vec2.zero();
		this.angle				= angle != null ?				angle				: 0;
		this.linearVelocity		= linearVelocity != null ?		linearVelocity		: Vec2.zero();
		this.angularVelocity	= angularVelocity != null ?		angularVelocity		: 0;
		this.linearDamping		= linearDamping != null ?		linearDamping		: 0;
		this.angularDamping		= angularDamping != null ?		angularDamping		: 0;
		this.fixedRotation		= fixedRotation != null ?		fixedRotation		: false;
		this.bullet				= bullet != null ?				bullet				: false;
		this.gravityScale		= gravityScale != null ?		gravityScale		: 1;
		this.allowSleep			= allowSleep != null ?			allowSleep			: true;
		this.awake				= awake != null ?				awake				: true;
		this.active				= active != null ?				active				: true;
		this.userData			= userData;
	}
}

@:structInit
class MassData {
	public var mass								: Float;
	public var center							: Vec2;
	public var I								: Float;
	
	public function new( ?mass : Float, ?center : Vec2, ?I : Float) {
		this.mass		= mass != null ?			mass			: 0;
		this.center		= center != null ?			center			: Vec2.zero();
		this.I			= I != null ?				I				: 0;
	}
}

@:native("planck.Body")
extern class Body {
	static var STATIC							: String;
	static var KINEMATIC						: String;
	static var DYNAMIC							: String;
	
	function new( world : World, ?def : BodyDef);
	
	function isWorldLocked() : Bool;
	
	function getWorld() : World;
	
	function getNext() : Body;
	
	function setUserData( data : Dynamic) : Void;
	
	function getUserData() : Dynamic;
	
	function getFixtureList() : Fixture;
	
	function getJointList() : JointEdge;
	
	function getContactList() : ContactEdge;
	
	function isStatic() : Bool;
	
	function isDynamic() : Bool;
	
	function isKinematic() : Bool;
	
	function setStatic() : Body;
	
	function setDynamic() : Body;
	
	function setKinematic() : Body;
	
	function getType() : String;
	
	function setType( type : String) : Void;
	
	function isBullet() : Bool;
	
	function setBullet( flag : Bool) : Void;
	
	function isSleepingAllowed() : Bool;
	
	function setSleepingAllowed( flag : Bool) : Void;
	
	function isAwake() : Bool;
	
	function setAwake( flag : Bool) : Void;
	
	function isActive() : Bool;
	
	function setActive( flag : Bool) : Void;
	
	function isFixedRotation() : Bool;
	
	function setFixedRotation( flag : Bool) : Void;
	
	function getTransform() : Transform;
	
	function setTransform( position : Vec2, angle : Float) : Void;
	
	function synchronizeTransform() : Void;
	
	function synchronizeFixtures() : Void;
	
	function advance( alpha : Float) : Void;
	
	function getPosition() : Vec2;
	
	function setPosition( p : Vec2) : Void;
	
	function getAngle() : Float;
	
	function setAngle( angle : Float) : Void;
	
	function getWorldCenter() : Vec2;
	
	function getLocalCenter() : Vec2;
	
	function getLinearVelocity() : Vec2;
	
	function getLinearVelocityFromWorldPoint( worldPoint : Vec2) : Vec2;
	
	function getLinearVelocityFromLocalPoint( localPoint : Vec2) : Vec2;
	
	function setLinearVelocity( v : Vec2) : Void;
	
	function getAngularVelocity() : Float;
	
	function setAngularVelocity( w : Float) : Void;
	
	function getLinearDamping() : Float;
	
	function setLinearDamping( linearDamping : Float) : Void;
	
	function getAngularDamping() : Float;
	
	function setAngularDamping( angularDamping : Float) : Void;
	
	function getGravityScale() : Float;
	
	function setGravityScale( scale : Float) : Void;
	
	function getMass() : Float;
	
	function getInertia() : Float;
	
	function getMassData( data : MassData) : Void;
	
	function resetMassDara() : Void;
	
	function setMassData( massData : MassData) :  Void;
	
	function applyForce( force : Vec2, point : Vec2, wake : Bool) : Void;
	
	function applyForceToCenter( force : Vec2, wake : Bool) : Void;
	
	function applyTorque( torque : Float, wake : Bool) : Void;
	
	function applyLinearImpulse( impulse : Vec2, point : Vec2, wake : Bool) : Void;
	
	function applyAngularImpulse( impulse : Float, wake : Bool) : Void;
	
	function shouldCollide( that : Body) : Bool;
	
	function createFixture( shape : EitherType<Shape,FixtureDef>, ?fixdef : EitherType<FixtureDef,Float>) : Fixture;
	
	function destroyFixture( fixture : Fixture) : Void;
	
	function getWorldPoint( localPoint : Vec2) : Vec2;
	
	function getWorldVector( worldPoint : Vec2) : Vec2;
	
	function getLocalPoint( worldPoint : Vec2) : Vec2;
	
	function getLocalVector( worldVector : Vec2) : Vec2;
}