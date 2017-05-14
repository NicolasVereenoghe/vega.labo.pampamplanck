package planck;

@:native("planck.internal.Settings")
extern class Settings {
	static var maxManifoldPoints		: Int;
	static var maxPolygonVertices		: Int;
	static var aabbExtension			: Float;
	static var aabbMultiplier			: Float;
	static var linearSlop				: Float;
	static var linearSlopSquared		: Float;
	static var angularSlop				: Float;
	static var polygonRadius			: Float;
	static var maxSubSteps				: Int;
	static var maxTOIContacts			: Int;
	static var maxTOIIterations			: Int;
	static var maxDistnceIterations		: Int;
	static var velocityThreshold		: Float;
	static var maxLinearCorrection		: Float;
	static var maxAngularCorrection		: Float;
	static var maxTranslation			: Float;
	static var maxTranslationSquared	: Float;
	static var maxRotation				: Float;
	static var maxRotationSquared		: Float;
	static var baumgarte				: Float;
	static var toiBaugarte				: Float;
	static var timeToSleep				: Float;
	static var linearSleepTolerance		: Float;
	static var linearSleepToleranceSqr	: Float;
	static var angularSleepTolerance	: Float;
	static var angularSleepToleranceSqr	: Float;
}