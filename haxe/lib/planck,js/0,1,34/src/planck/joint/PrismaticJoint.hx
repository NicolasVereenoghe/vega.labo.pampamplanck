package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class PrismaticJointDef extends JointDef {
	public var enableLimit			: Bool;
	public var lowerTranslation		: Float;
	public var upperTranslation		: Float;
	public var enableMotor			: Bool;
	public var maxMotorForce		: Float;
	public var motorSpeed			: Float;
	
	public var localAnchorA			: Vec2;
	public var localAnchorB			: Vec2;
	public var localAxisA			: Vec2;
	public var referenceAngle		: Float;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?enableLimit : Bool, ?lowerTranslation : Float, ?upperTranslation : Float, ?enableMotor : Bool, ?maxMotorForce : Float, ?motorSpeed : Float, ?localAnchorA : Vec2, ?localAnchorB : Vec2, ?localAxisA : Vec2, ?referenceAngle : Float) {
		super( userData, collideConnected);
		
		this.enableLimit		= enableLimit != null ?			enableLimit			: false;
		this.lowerTranslation	= lowerTranslation != null ?	lowerTranslation	: 0;
		this.upperTranslation	= upperTranslation != null ?	upperTranslation	: 0;
		this.enableMotor		= enableMotor != null ?			enableMotor			: false;
		this.maxMotorForce		= maxMotorForce != null ?		maxMotorForce		: 0;
		this.motorSpeed			= motorSpeed != null ?			motorSpeed			: 0;
		
		this.localAnchorA		= localAnchorA;
		this.localAnchorB		= localAnchorB;
		this.localAxisA			= localAxisA;
		this.referenceAngle		= referenceAngle;
	}
}

@:native("planck.PrismaticJoint")
extern class PrismaticJoint extends Joint {
	static var TYPE				: String;
	
	public function new( ?def : PrismaticJointDef, bodyA : Body, bodyB : Body, ?anchor : Vec2, ?axis : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function getLocalAxisA() : Vec2;
	
	function getReferenceAngle() : Float;
	
	function getJointTranslation() : Float;
	
	function getJointSpeed() : Float;
	
	function isLimitEnabled() : Bool;
	
	function enableLimit( flag : Bool) : Void;
	
	function getLowerLimit() : Float;
	
	function getUpperLimit() : Float;
	
	function setLimits( lower : Float, upper : Float) : Void;
	
	function isMotorEnabled() : Bool;
	
	function enableMotor( flag : Bool) : Void;
	
	function setMotorSpeed( speed : Float) : Void;
	
	function setMaxMotorForce( force : Float) : Void;
	
	function getMotorSpeed() : Float;
	
	function getMotorForce( inv_dt : Float) : Float;
}