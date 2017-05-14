package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class MotorJointDef extends JointDef {
	public var maxForce				: Float;
	public var maxTorque			: Float;
	public var correctionFactor		: Float;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?maxForce : Float, ?maxTorque : Float, ?correctionFactor : Float) {
		super( userData, collideConnected);
		
		this.maxForce			= maxForce != null ?			maxForce			: 1;
		this.maxTorque			= maxTorque != null ?			maxTorque			: 1;
		this.correctionFactor	= correctionFactor != null ?	correctionFactor	: .3;
	}
}

@:native("planck.MotorJoint")
extern class MotorJoint extends Joint {
	static var TYPE				: String;
	
	function new( ?def : MotorJointDef, bodyA : Body, bodyB : Body);
	
	function setMaxForce( force : Float) : Void;
	
	function getMaxForce() : Float;
	
	function setMaxTorque( torque : Float) : Void;
	
	function getMaxTorque() : Float;
	
	function setCorrectionFactor( factor : Float) : Void;
	
	function getCorrectionFactor() : Float;
	
	function setLinearOffset( linearOffset : Vec2) : Void;
	
	function getLinearOffset() : Vec2;
	
	function setAngularOffset( angularOffset : Float) : Void;
	
	function getAngularOffset() : Float;
}