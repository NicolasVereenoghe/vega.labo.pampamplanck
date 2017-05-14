package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class FrictionJointDef extends JointDef {
	public var maxForce		: Float;
	public var maxTorque	: Float;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?maxForce : Float, ?maxTorque : Float) {
		super( userData, collideConnected);
		
		this.maxForce	= maxForce != null ?	maxForce	: 0;
		this.maxTorque	= maxTorque != null ?	maxTorque	: 0;
	}
}

@:native("planck.FrictionJoint")
extern class FrictionJoint extends Joint {
	static var TYPE				: String;
	
	function new( ?def : FrictionJointDef, ?bodyA : Body, ?bodyB : Body, ?anchor : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function setMaxForce( force : Float) : Void;
	
	function getMaxForce() : Float;
	
	function setMaxTorque( torque : Float) : Void;
	
	function getMaxTorque() : Float;
}