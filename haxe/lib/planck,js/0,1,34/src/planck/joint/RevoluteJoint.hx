package planck.joint;

import planck.Joint;
import planck.common.Vec2;

@:structInit
class RevoluteJointDef extends JointDef {
	public var lowerAngle			: Float;
	public var upperAngle			: Float;
	public var maxMotorTorque		: Float;
	public var motorSpeed			: Float;
	public var enableLimit			: Bool;
	public var enableMotor			: Bool;
	
	public var localAnchorA			: Vec2;
	public var localAnchorB			: Vec2;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?lowerAngle : Float, ?upperAngle : Float, ?maxMotorTorque : Float, ?motorSpeed : Float, ?enableLimit : Bool, ?enableMotor : Bool, ?localAnchorA : Vec2, ?localAnchorB : Vec2) {
		super( userData, collideConnected);
		
		this.lowerAngle			= lowerAngle != null ?			lowerAngle		: 0;
		this.upperAngle			= upperAngle != null ?			upperAngle		: 0;
		this.maxMotorTorque		= maxMotorTorque != null ?		maxMotorTorque	: 0;
		this.motorSpeed			= motorSpeed != null ?			motorSpeed		: 0;
		this.enableLimit		= enableLimit != null ?			enableLimit		: false;
		this.enableMotor		= enableMotor != null ?			enableMotor		: false;
		
		this.localAnchorA		= localAnchorA;
		this.localAnchorB		= localAnchorB;
	}
}

@:native("planck.RevoluteJoint")
extern class RevoluteJoint extends Joint {
	static var TYPE					: String;
	
	function new( ?def : RevoluteJointDef, bodyA : Body, bodyB : Body, ?anchor : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function getReferenceAngle() : Float;
	
	function getJointAngle() : Float;
	
	function getJointSpeed() : Float;
	
	function isMotorEnabled() : Bool;
	
	function enableMotor( flag : Bool) : Void;
	
	function getMotorTorque( inv_dt : Float) : Float;
	
	function setMotorSpeed( speed : Float) : Void;
	
	function getMotorSpeed() : Float;
	
	function setMaxMotorTorque( torque : Float) : Void;
	
	function isLimitEnabled() : Bool;
	
	function enableLimit( flag : Bool) : Void;
	
	function getLowerLimit() : Float;
	
	function getUpperLimit() : Float;
	
	function setLimits( lower : Float, upper : Float) : Void;
}