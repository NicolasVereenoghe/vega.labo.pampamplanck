package planck.joint;

import planck.Joint;
import planck.common.Vec2;

@:structInit
class MouseJointDef extends JointDef {
	public var maxForce				: Float;
	public var frequencyHz			: Float;
	public var dampingRatio			: Float;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?maxForce : Float, ?frequencyHz : Float, ?dampingRatio : Float) {
		super( userData, collideConnected);
		
		this.maxForce		= maxForce != null ?		maxForce		: 0;
		this.frequencyHz	= frequencyHz != null ?		frequencyHz		: 5;
		this.dampingRatio	= dampingRatio != null ?	dampingRatio	: .7;
	}
}

@:native("planck.MouseJoint")
extern class MouseJoint extends Joint {
	static var TYPE				: String;
	
	function new( ?def : JointDef, bodyA : Body, bodyB : Body, target : Vec2);
	
	function setTarget( target : Vec2) : Void;
	
	function getTarget() : Vec2;
	
	function setMaxForce( force : Float) : Void;
	
	function getMaxForce() : Float;
	
	function setFrequency( hz : Float) : Void;
	
	function getFrequency() : Float;
	
	function setDampingRatio( ratio : Float) : Void;
	
	function getDampingRatio() : Float;
}