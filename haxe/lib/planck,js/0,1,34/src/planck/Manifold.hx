package planck;

import planck.Manifold.ContactFeature;
import planck.common.Transform;
import planck.common.Vec2;

@:structInit
class ManifoldPoint {
	public var localPoint		: Vec2;
	public var normalImpulse	: Float;
	public var tangentImpulse	: Float;
	public var id				: ContactID;
	
	public function new( ?localPoint : Vec2, ?normalImpulse : Float, ?tangentImpulse : Float, ?id: ContactID) {
		this.localPoint			= localPoint != null ?			localPoint				: Vec2.zero();
		this.normalImpulse		= normalImpulse != null ?		normalImpulse			: 0;
		this.tangentImpulse		= tangentImpulse != null ?		tangentImpulse			: 0;
		this.id					= id != null ?					id						: new ContactID();
	}
}

@:structInit
class ContactID {
	public var cf				: ContactFeature;
	public var key				: Int;
	
	public function new( ?cf : ContactFeature, ?key : Int) {
		this.cf			= cf != null ?			cf			: new ContactFeature();
		this.key		= key;
	}
	
	public function set( o : ContactID) : Void {
		key	= o.key;
		cf.set( o.cf);
	}
}

@:structInit
class ContactFeature {
	public var indexA			: Int;
	public var indexB			: Int;
	public var typeA			: Int;
	public var typeB			: Int;
	
	public function new( ?indexA : Int, ?indexB : Int, ?typeA : Int, ?typeB : Int) {
		this.indexA	= indexA;
		this.indexB	= indexB;
		this.typeA	= typeA;
		this.typeB	= typeB;
	}
	
	public function set( o : ContactFeature) : Void {
		indexA	= o.indexA;
		indexB	= o.indexB;
		typeA	= o.typeA;
		typeB	= o.typeB;
	}
}

@:structInit
class WorldManifold {
	public var normal			: Vec2;
	public var points			: Array<Vec2>;
	public var separations		: Array<Float>;
	
	public function new( ?normal : Vec2, ?points : Array<Vec2>, ?separations : Array<Float>) {
		this.normal			= normal;
		this.points			= points != null ?		points		: [];
		this.separations	= separations != null ?	separations	: [];
	}
}

@:native("planck.internal.Manifold")
extern class Manifold {
	static var e_circles		: Int;
	static var e_faceA			: Int;
	static var e_faceB			: Int;
	
	static var e_vertex			: Int;
	static var e_face			: Int;
	
	var type					: Int;
	var localNormal				: Vec2;
	var localPoint				: Vec2;
	var points					: Array<ManifoldPoint>;
	var pointCount				: Int;
	
	function new();
	
	function getWorldManifold( ?wm : WorldManifold, xfA : Transform, radiusA : Float, xfB : Transform, radiusB : Float) : WorldManifold;
}