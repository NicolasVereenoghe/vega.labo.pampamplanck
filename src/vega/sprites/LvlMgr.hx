package vega.sprites;

/**
 * dictionnaire de descripteurs de levels
 * 
 * @author nico
 */
class LvlMgr {
	/** réf sur le singleton */
	static var current									: LvlMgr;
	
	/** identifiuant de level par défaut */
	var LVL_DEFAULT_ID									: String							= "default";
	
	/** map de descripteurs de levels indexés par id de level */
	var lvls											: Map<String,LvlDesc>;
	
	/**
	 * on récupère le singleton ; si n'existe pas, on le crée
	 * @return	instance singleton
	 */
	public static function getInstance() : LvlMgr {
		if ( current == null) current = new LvlMgr();
		
		return current;
	}
	
	/**
	 * construction
	 */
	public function new() { lvls = new Map<String,LvlDesc>(); }
	
	/**
	 * ajout d'un descripteur de plan à un level ; si le level n'existe pas, on crée on descripteur vide pour contenir le plan
	 * @param	pGroundId	id de plan
	 * @param	pGrnd		instance de descripteur de plan
	 * @param	pLvlId		id de level ; null pour id par défaut
	 * @return	descripteur de plan ajouté
	 */
	public function addLvlGround( pGroundId : String, pGrnd : LvlGroundMgr, pLvlId : String = null) : LvlGroundMgr {
		if ( pLvlId == null) pLvlId = LVL_DEFAULT_ID;
		
		if ( ! lvls.exists( pLvlId)) lvls[ pLvlId] = new LvlDesc();
		
		return lvls[ pLvlId].addLvlGround( pGroundId, pGrnd);
	}
	
	/**
	 * on vérifie si un level est défini
	 * @param	pLvlId		id de level ; null pour id par défaut
	 */
	public function exists( pLvlId : String = null) : Bool {
		if ( pLvlId == null) pLvlId = LVL_DEFAULT_ID;
		
		return lvls.exists( pLvlId);
	}
	
	/**
	 * on récupère un ground en fonction de son identifiant
	 * @param	pId		identifiant du ground recherché
	 * @param	pLvlId	identifiant de level auquel appartient ce ground (doit exister si spécifié), ou laisser null pour rechercher dans le seul level défini
	 * @return	ground ou null si pas trouvé
	 */
	public function getLvlGroundMgrById( pId : String, pLvlId : String = null) : LvlGroundMgr {
		if ( pLvlId == null) pLvlId = LVL_DEFAULT_ID;
		
		return lvls[ pLvlId].getLvlGroundById( pId);
	}
	
	/**
	 * on récupère un ground en fonction de son indice d'ajout
	 * @param	pI		indice d'ajout (0 .. n-1)
	 * @param	pLvlId	identifiant de level auquel appartient ce ground (doit exister si spécifié), ou laisser null pour rechercher dans le seul level défini
	 * @return	ground, ou null si indice hors limite
	 */
	public function getLvlGroundMgr( pI : Int, pLvlId : String = null) : LvlGroundMgr {
		if ( pLvlId == null) pLvlId = LVL_DEFAULT_ID;
		
		return lvls[ pLvlId].getLvlGroundByIndex( pI);
	}
}

/**
 * descripteur de level
 */
class LvlDesc {
	/** map de descripteurs de plans indiexés par id de plan */
	var lvlById									: Map<String,LvlGroundMgr>;
	/** pile de descripteurs de plans empilé par ordre d'ajout */
	var lvlByIndex								: Array<LvlGroundMgr>;
	
	/**
	 * construction
	 */
	public function new() {
		lvlById		= new Map<String,LvlGroundMgr>();
		lvlByIndex	= new Array<LvlGroundMgr>();
	}
	
	/**
	 * ajoute un descripteur de plan au level
	 * @param	pId		identifiant de plan
	 * @param	pGrnd	descripteur de plan ajouté
	 * @return	descripteur ajouté
	 */
	public function addLvlGround( pId : String, pGrnd : LvlGroundMgr) : LvlGroundMgr {
		lvlById[ pId] = pGrnd;
		lvlByIndex.push( pGrnd);
		
		return pGrnd;
	}
	
	/**
	 * récupère un descripteur de plan par identifiant
	 * @param	pId	identifiant de ground
	 * @return	instance de descripteur de ground ou null si aucun
	 */
	public function getLvlGroundById( pId : String) : LvlGroundMgr { return lvlById.get( pId); }
	
	/**
	 * récupère un descripteur de plan par index d'ajout
	 * @param	pI	index d'ajout de plan
	 * @return	instance de descripteur de ground ou null si aucun
	 */
	public function getLvlGroundByIndex( pI : Int) : LvlGroundMgr {
		if ( pI >= lvlByIndex.length) return null;
		else return lvlByIndex[ pI];
	}
}