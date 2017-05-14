package vega.effect.particles;

import pixi.particles.ParticleContainer;
import pixi.particles.ParticleContainer.ParticleContainerProperties;

/**
 * ...
 * @author nico
 */
class MyParticleMgr {
	public var container( get, null)			: ParticleContainer;
	var _container								: ParticleContainer							= null;
	function get_container() : ParticleContainer { return _container; }
	
	var particles								: Array<MyParticle>							= null;
	
	public function new() { particles = new Array<MyParticle>(); }
	
	public function init( pCont : ParticleContainer) : Void { _container = pCont; }
	
	public function addParticle( pParticle : MyParticle) : Void {
		pParticle.initDisplayOn( this);
		
		particles.push( pParticle);
	}
	
	public function remParticle( pP : MyParticle) : Void { particles.remove( pP); }
	
	public function doFrame( pDt : Float) : Void {
		var lParts	: Array<MyParticle>	= particles.copy();
		var lPart	: MyParticle;
		
		for ( lPart in lParts) lPart.doFrame( pDt);
	}
	
	public function destroy() : Void {
		var lPs	: Array<MyParticle>	= particles.copy();
		var lP	: MyParticle;
		
		for ( lP in lPs) lP.destroy();
		
		_container = null;
		particles = null;
	}
}