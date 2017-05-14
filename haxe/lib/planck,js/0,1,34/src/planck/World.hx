package planck;

import planck.Body.BodyDef;
import planck.Solver.ContactImpulse;
import planck.collision.AABB;
import planck.common.Vec2;

import haxe.extern.EitherType;

@:structInit
class WorldDef {
	public var gravity						: Vec2;
	public var allowSleep					: Bool;
	public var continuousPhysics			: Bool;
	public var subStepping					: Bool;
	public var blockSolve					: Bool;
	public var velocityIterations			: Int;
	public var positionIterations			: Int;
	
	public function new( ?gravity : Vec2, ?allowSleep : Bool, ?continuousPhysics : Bool, ?subStepping : Bool, ?blockSolve : Bool, ?velocityIterations : Int, ?positionIterations : Int) {
		this.gravity			= gravity != null ?				gravity 			: Vec2.zero();
		this.allowSleep			= allowSleep != null ?			allowSleep			: true;
		this.continuousPhysics	= continuousPhysics != null ?	continuousPhysics	: true;
		this.subStepping		= subStepping != null ?			subStepping			: false;
		this.blockSolve			= blockSolve != null ?			blockSolve			: true;
		this.velocityIterations	= velocityIterations != null ?	velocityIterations	: 8;
		this.positionIterations	= positionIterations != null ?	positionIterations	: 3;
	}
}

@:native("planck.World")
extern class World {
	//static var WORLD_REMOVE_BODY			: String					= "remove-body";	// ? Body->Void
	static inline var WORLD_REMOVE_JOINT	: String					= "remove-joint";	// Joint->Void
	static inline var WORLD_REMOVE_FIXTURE	: String					= "remove-fixture";	// Fixture->Void
	
	static inline var WORLD_CONTACT_BEGIN	: String					= "begin-contact";	// Contact->Void
	static inline var WORLD_CONTACT_END		: String					= "end-contact";	// Contact->Void
	static inline var WORLD_CONTACT_PRE		: String					= "pre-solve";		// Contact->Manifold->Void
	static inline var WORLD_CONTACT_POST	: String					= "post-solve";		// Contact->ContactImpulse->Void
	
	function new( def : EitherType<WorldDef,Vec2>);
	
	function getBodyList() : Body;
	
	function getJointList() : Joint;
	
	function getContactList() : Contact;
	
	function getBodyCount() : Int;
	
	function getJointCount() : Int;
	
	function getContactCount() : Int;
	
	function setGravity( gravity : Vec2) : Void;
	
	function getGravity() : Vec2;
	
	function isLocked() : Bool;
	
	function setAllowSleeping( flag : Bool) : Void;
	
	function getAllowSleeping() : Bool;
	
	function setWarmStarting( flag : Bool) : Void;
	
	function getWarmStarting() : Bool;
	
	function setContinuousPhysics( flag : Bool) : Void;
	
	function getContinuousPhysics() : Bool;
	
	function setSubStepping( flag : Bool) : Void;
	
	function getSubStepping() : Bool;
	
	function setAutoClearForces( flag : Bool) : Void;
	
	function getAutoClearForces() : Bool;
	
	function clearForces() : Void;
	
	function queryAABB( aabb : AABB, queryCallback : Fixture-> Bool) : Void;
	
	function rayCast( point1 : Vec2, point2 : Vec2, reportFixtureCallback : Fixture-> Vec2->Vec2->Float->Int) : Float;
	
	function getProxyCount() : Int;
	
	function getTreeHeight() : Int;
	
	function getTreeBalance() : Int;
	
	function getTreeQuality() : Float;
	
	function shiftOrigin( newOrigin : Vec2) : Void;
	
	function createBody( ?def : EitherType<BodyDef,Vec2>, ?angle : Float) : Body;
	
	function createDynamicBody( ?def : EitherType<BodyDef,Vec2>, ?angle : Float) : Body;
	
	function createKinematicBody( ?def : EitherType<BodyDef,Vec2>, ?angle : Float) : Body;
	
	function destroyBody( b : Body) : Bool;
	
	function createJoint( joint : Joint) : Joint;
	
	function destroyJoint( joint : Joint) : Void;
	
	function step( timeStep : Float, ?velocityIterations : Int, ?positionIterations : Int) : Void;
	
	function findNewContacts() : Void;
	
	function updateContacts() : Void;
	
	function destroyContact( contact : Contact) : Void;
	
	function on( name : String, listener : EitherType<Body->Void,EitherType<Fixture->Void,EitherType<Joint->Void,EitherType<Contact->Void,EitherType<Contact->Manifold->Void,Contact->ContactImpulse->Void>>>>>) : World;
	
	function off( name : String, listener : EitherType<Body->Void,EitherType<Fixture->Void,EitherType<Joint->Void,EitherType<Contact->Void,EitherType<Contact->Manifold->Void,Contact->ContactImpulse->Void>>>>>) : World;
}