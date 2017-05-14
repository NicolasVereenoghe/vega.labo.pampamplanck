package planck.joint;

import planck.Body;
import planck.Joint;

import haxe.extern.EitherType;

@:structInit
class GearJointDef extends JointDef {
	public var ratio		: Float;
	
	function new( ?userData : Dynamic, ?collideConnected : Bool, ?ratio : Float) {
		super( userData, collideConnected);
		
		this.ratio	= ratio != null ?	ratio	: 0;
	}
}

@:native("planck.GearJoint")
extern class GearJoint extends Joint {
	static var TYPE				: String;
	
	function new( ?def : GearJointDef, ?bodyA : Body, ?bodyB : Body, joint1 : EitherType<PrismaticJoint,RevoluteJoint>, joint2 : EitherType<PrismaticJoint,RevoluteJoint>, ?ratio : Float);
	
	function getJoint1() : Joint;
	
	function getJoint2() : Joint;
	
	function setRatio( ratio : Float) : Void;
}