package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;
import planck.joint.WheelJoint.WheelJointDef;

@:structInit
class WheelJointDef extends JointDef {
	public var enableMotor			: Bool;
	public var maxMotorTorque		: Float;
	public var motorSpeed			: Float;
	public var frequencyHz			: Float;
	public var dampingRatio			: Float;
	
	public function new( ?userData : Dynamic, ?collideConnected : Bool, ?enableMotor : Bool, ?maxMotorTorque : Float, ?motorSpeed : Float, ?frequencyHz : Float, ?dampingRatio : Float) {
		super( userData, collideConnected);
		
		this.enableMotor		= enableMotor != null ?			enableMotor			: false;
		this.maxMotorTorque		= maxMotorTorque != null ?		maxMotorTorque		: 0;
		this.motorSpeed			= motorSpeed != null ?			motorSpeed			: 0;
		this.frequencyHz		= frequencyHz != null ?			frequencyHz			: 2;
		this.dampingRatio		= dampingRatio != null ?		dampingRatio		: .7;
	}
}

@:native("planck.WheelJoint")
extern class WheelJoint extends Joint {
	static var TYPE					: String;
	
	function new( ?def : WheelJointDef, bodyA : Body, bodyB : Body, anchor : Vec2, ?axis : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function getLocalAxisA() : Vec2;
	
	function getJointTranslation() : Float;
	
	function getJointSpeed() : Float;
	
	function isMotorEnabled() : Bool;
	
	function enableMotor( flag : Bool) : Void;
	
	function setMotorSpeed( speed : Float) : Void;
	
	function getMotorSpeed() : Float;
	
	function setMaxMotorTorque( torque : Float) : Void;
	
	function getMaxMotorTorque() : Float;
	
	function getMotorTorque( inv_dt : Float) : Float;
	
	function setSpringFrequencyHz( hz : Float) : Void;
	
	function getSpringFrequencyHz() : Float;
	
	function setSpringDampingRatio( ratio : Float) : Void;
	
	function getSpringDampingRatio() : Float;
	
	
}