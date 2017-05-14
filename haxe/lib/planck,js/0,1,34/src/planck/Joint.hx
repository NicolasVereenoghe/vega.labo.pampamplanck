package planck;

import planck.common.Vec2;

@:structInit
class JointDef {
	public var userData			: Dynamic;
	public var collideConnected	: Bool;
	
	public function new( ?userData : Dynamic, ?collideConnected : Bool) {
		this.userData			= userData;
		this.collideConnected	= collideConnected != null ?	collideConnected	: false;
	}
}

@:structInit
class JointEdge {
	public var other			: Body;
	public var joint			: Joint;
	public var prev				: JointEdge;
	public var next				: JointEdge;
	
	public function new( ?other : Body, ?joint : Joint, ?prev : JointEdge, ?next : JointEdge) {
		this.other	= other;
		this.joint	= joint;
		this.prev	= prev;
		this.next	= next;
	}
}

@:native("planck.Joint")
extern class Joint{
	function new( def : JointDef, ?bodyA : Body, ?bodyB : Body);
	
	function isActive() : Bool;
	
	function getType() : String;
	
	function getBodyA() : Body;
	
	function getBodyB() : Body;
	
	function getNext() : Joint;
	
	function getUserData() : Dynamic;
	
	function setUserData( data : Dynamic) : Void;
	
	function getCollideConnected() : Bool;
	
	function getAnchorA() : Vec2;
	
	function getAnchorB() : Vec2;
	
	function getReactionForce( inv_dt : Float) : Vec2;
	
	function getReactionTorque( inv_dt : Float) : Float;
	
	function shiftOrigin( newOrigin : Vec2) : Void;
}