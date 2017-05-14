package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:structInit
class DistanceJointDef extends JointDef {
	public var frequencyHz		: Float;
	public var dampingRatio		: Float;
	
	public var localAnchorA		: Vec2;
	public var localAnchorB		: Vec2;
	
	public function new( ?userData : Dynamic, ?collideConnected : Bool, ?frequencyHz : Float, ?dampingRatio : Float, ?localAnchorA : Vec2, ?localAnchorB : Vec2) {
		super( userData, collideConnected);
		
		this.frequencyHz	= frequencyHz != null ?		frequencyHz		: 0;
		this.dampingRatio	= dampingRatio != null ?	dampingRatio	: 0;
		
		this.localAnchorA	= localAnchorA;
		this.localAnchorB	= localAnchorB;
	}
}

@:native("planck.DistanceJoint")
extern class DistanceJoint extends Joint {
	static var TYPE				: String;
	
	function new( ?def : DistanceJointDef, ?bodyA : Body, anchorA : Vec2, ?bodyB : Body, anchorB : Vec2);
	
	function getLocalAnchorA() : Vec2;
	
	function getLocalAnchorB() : Vec2;
	
	function setLength( length : Float) : Void;
	
	function getLength() : Float;
	
	function setFrequency( hz : Float) : Void;
	
	function getFrequency() : Float;
	
	function setDampingRatio( ratio : Float) : Void;
	
	function getDampingRatio() : Float;
}