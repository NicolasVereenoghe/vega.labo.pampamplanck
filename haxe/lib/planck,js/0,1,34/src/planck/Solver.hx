package planck;

@:structInit
class ContactImpulse {
	public var normalImpulses		: Array<Float>;
	public var tangentImpulses		: Array<Float>;
	
	public function new( ?normalImpulses : Array<Float>, ?tangentImpulses : Array<Float>) {
		this.normalImpulses		= normalImpulses != null ?		normalImpulses		: [];
		this.tangentImpulses	= tangentImpulses != null ?		tangentImpulses		: [];
	}
}