package planck;

import planck.Body.MassData;
import planck.collision.AABB;
import planck.collision.AABB.RayCastInput;
import planck.collision.AABB.RayCastOutput;
import planck.common.Transform;
import planck.common.Vec2;

import haxe.extern.EitherType;

@:structInit
class FixtureDef {
	public var userData					: Dynamic;
	public var friction					: Float;
	public var restitution				: Float;
	public var density					: Float;
	public var isSensor					: Bool;
	
	public var filterGroupIndex			: Int;
	public var filterCategoryBits		: Int;
	public var filterMaskBits			: Int;
	
	public var shape					: Shape;
	
	public function new( ?userData : Dynamic, ?friction : Float, ?restitution : Float, ?density : Float, ?isSensor : Bool, ?filterGroupIndex : Int, ?filterCategoryBits : Int, ?filterMaskBits : Int, ?shape : Shape) {
		this.userData				= userData;
		this.friction				= friction != null ?					friction					: 0.2;
		this.restitution			= restitution != null ?					restitution					: 0;
		this.density				= density != null ?						density						: 0;
		this.isSensor				= isSensor != null ?					isSensor					: false;
		this.filterGroupIndex		= filterGroupIndex != null ?			filterGroupIndex			: 0;
		this.filterCategoryBits		= filterCategoryBits != null ?			filterCategoryBits			: 0x0001;
		this.filterMaskBits			= filterMaskBits != null ?				filterMaskBits				: 0xFFFF;
		
		this.shape					= shape;
	}
}

@:structInit
class Filter {
	public var groupIndex				: Int;
	public var categoryBits				: Int;
	public var maskBits					: Int;
	
	public function new( ?groupIndex : Int, ?categoryBits : Int, ?maskBits : Int) {
		this.groupIndex		= groupIndex != null ?		groupIndex		: 0;
		this.categoryBits	= categoryBits != null ?	categoryBits	: 0x0001;
		this.maskBits		= maskBits != null ?		maskBits		: 0xFFFF;
	}
}

@:native("planck.Fixture")
extern class Fixture {
	function new( body : Body, shape : EitherType<Shape,FixtureDef>, ?def : EitherType<FixtureDef,Float>);
	
	function getType() : String;
	
	function getShape() : Shape;
	
	function isSensor() : Bool;
	
	function setSensor( sensor : Bool) : Void;
	
	function getUserData() : Dynamic;
	
	function setUserData( data : Dynamic) : Void;
	
	function getBody() : Body;
	
	function getNext() : Fixture;
	
	function getDensity() : Float;
	
	function setDensity( density : Float) : Void;
	
	function getFriction() : Float;
	
	function setFriction( friction : Float) : Void;
	
	function getRestitution() : Float;
	
	function setRestitution( restitution : Float) : Void;
	
	function testPoint( p : Vec2) : Bool;
	
	function rayCast( output : RayCastOutput, input : RayCastInput, childIndex : Int) : Bool;
	
	function getMassData( massData : MassData) : Void;
	
	function getAABB( childIndex : Int) : AABB;
	
	function setFilterData( filter : Filter) : Void;
	
	function getFilterGroupIndex() : Int;
	
	function getFilterCategoryBits() : Int;
	
	function getFilterMaskBits() : Int;
	
	function refilter() : Void;
	
	function shouldCollide( that : Fixture) : Bool;
}