package vega.sound;

/**
 * on lance un son dès qu'un autre s'est arrêté
 * @author	nico
 */
class SndPlayModeChained extends SndPlayMode implements ISndPlayModeChained {
	/** pattern de recherche d'identifiants de son à vérifier la fin de lecture avant de lancer notre son ; laisser null pour tout vérifier */
	var _subId							: String							= null;
	
	/**
	 * @inheritDoc
	 * @param		pSubId	pattern de recherche d'identifiants de son à vérifier la fin de lecture avant de lancer notre son ; laisser null pour tout vérifier
	 */
	public function new( pSubId : String = null) {
		super();
		
		_subId = pSubId;
	}
	
	/** @inheritDoc */
	public function getChainedSubId() : String { return _subId; }
}