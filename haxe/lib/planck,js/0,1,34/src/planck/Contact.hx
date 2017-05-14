package planck;
import planck.common.Transform;

@:structInit
class ContactEdge {
	public var contact			: Contact;
	public var prev				: ContactEdge;
	public var next				: ContactEdge;
	public var other			: Body;
	
	public function new( ?contact : Contact, ?prev : ContactEdge, ?next : ContactEdge, ?other : Body) {
		this.contact	= contact;
		this.prev		= prev;
		this.next		= next;
		this.other		= other;
	}
}

@:native("planck.Contact")
extern class Contact {
	function new( fA : Fixture, indexA : Int, fB : Fixture, indexB : Int, evaluateFcn : Manifold->Transform->Fixture-> Int->Transform->Fixture-> Int->Void);
	
	function getManifold() : Manifold;
	
	function getWorldManifold( ?worldManifold : Manifold) : Manifold;
	
	function setEnabled( flag : Bool) : Void;
	
	function isEnabled() : Bool;
	
	function isTouching() : Bool;
	
	function getNext() : Contact;
	
	function getFixtureA() : Fixture;
	
	function getFixtureB() : Fixture;
	
	function getChildIndexA() : Int;
	
	function getChildIndexB() : Int;
	
	function flagForFiltering() : Void;
	
	function setFriction( friction : Float) : Void;
	
	function getFriction() : Float;
	
	function resetFriction() : Void;
	
	function setRestitution( restitution : Float) : Void;
	
	function getRestitution() : Float;
	
	function resetRestitution() : Void;
	
	function setTangentSpeed( speed : Float) : Void;
	
	function getTangentSpeed() : Float;
	
	function evaluate( manifold : Manifold, xfA : Transform, xfB : Transform) : Void;
}