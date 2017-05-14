package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class WeldJointDef extends JointDef {
	public var frequencyHz		: Float;
	public var dampingRatio		: Float;
	
	public function new( ?userData : Dynamic, ?collideConnected : Bool, ?frequencyHz : Float, ?dampingRatio : Float) {
		super( userData, collideConnected);
		
		this.frequencyHz			= frequencyHz != null ?			frequencyHz		: 0;
		this.dampingRatio			= dampingRatio != null ?		dampingRatio	: 0;
	}
}

@:native("planck.WeldJoint")
extern class WeldJoint extends Joint {
	static var TYPE					: String;
	
	function new( ?def : WeldJointDef, bodyA : Body, bodyB : Body, anchor : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function setFrequency( hz : Float) : Void;
	
	function getFrequency() : Float;
	
	function setDampingRatio( ratio : Float) : Void;
	
	function getDampingRatio() : Float;
}