package planck.joint;

import planck.Body;
import planck.Joint;
import planck.common.Vec2;

@:native("planck.PulleyJoint")
extern class PulleyJoint extends Joint {
	static var TYPE					: String;
	static var MIN_PULLEY_LENGTH	: Float;
	
	function new( def : JointDef, bodyA : Body, bodyB : Body, groundA : Vec2, groundB : Vec2, anchorA : Vec2, anchorB : Vec2, ratio : Float);
	
	function getGroundAnchorA() : Vec2;
	
	function getGroundAnchorB() : Vec2;
	
	function getLengthA() : Float;
	
	function getLengthB() : Float;
	
	function setRatio() : Float; // /!\ : getRatio
	
	function getCurrentLengthA() : Float;
	
	function getCurrentLengthB() : Float;
}