package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class RopeJointDef extends JointDef {
	public var maxLength			: Float;
	
	public var localAnchorA			: Vec2;
	public var localAnchorB			: Vec2;
	
	public function new( ?userData : Dynamic, ?collideConnected : Bool, ?maxLength : Float, ?localAnchorA : Vec2, ?localAnchorB : Vec2) {
		super( userData, collideConnected);
		
		this.maxLength			= maxLength != null ?			maxLength		: 0;
		
		this.localAnchorA		= localAnchorA;
		this.localAnchorB		= localAnchorB;
	}
}

@:native("planck.RopeJoint")
extern class RopeJoint extends Joint {
	static var TYPE					: String;
	
	function new( ?def : RopeJointDef, ?bodyA : Body, ?bodyB : Body, anchor : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function setMaxLength( length : Float) : Void;
	
	function getMaxLength() : Float;
	
	function getLimitState() : Int;
}