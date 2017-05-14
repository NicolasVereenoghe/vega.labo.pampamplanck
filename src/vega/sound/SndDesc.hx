package vega.sound;
import howler.Howl;
import howler.Howl.HowlOptions;
import vega.loader.file.LoadingFile;
import vega.loader.file.MyFile;

/**
 * descripteur de piste
 * @author nico
 */
class SndDesc {
	/** identifiant de son */
	var _id								: String							= null;
	
	/** les options de son */
	var _options						: HowlOptions						= null;
	
	/** instance de son Howl décrit ; null si pas défini */
	var _howl							: Howl								= null;
	
	/** descripteur de fichier utilisé pour identifier la ressource chargée du son */
	var _fileResId						: MyFile							= null;
	
	/** listes d'extensions supportées ; laisser null pour n'avoir que celles par défaut (SndMgr::exts) */
	var _localExts						: Array<String>						= null;
	
	/** mode de lecture par défaut ; null si aucun particulier */
	var _playMode						: SndPlayMode						= null;
	public var playMode( get, null)		: SndPlayMode;
	
	/**
	 * construction de descripteur de son
	 * @param	pId			identifiant de son
	 * @param	pFile		descripteur de fichier sans extension ; la racine du nom sert à construire les urls des différents formats du son ; laisser null si ces url sont renseignées dans les options "Howl" ou construites à partir de l'identifiant de son qui peut servir d'url sans extension
	 * @param	pOtions		les options "Howl" du son ; si les urls (HowlOptions::src) ne sont pas renseignées, elles seront remplies à partir du descripteur de fichier sans extension et des extensions précisées ou par défaut ; laisser null pour par d'options spécifiques (instance d'options sera créé ici)
	 * @param	pExts		listes d'extensions supportées ; laisser null pour n'avoir que celles par défaut (SndMgr::exts)
	 * @param	pPlayMode	mode de lecture par défaut ; laisser null pour aucun
	 */
	public function new( pId : String, pFile : MyFile = null, pOtions : HowlOptions = null, pExts : Array<String> = null, pPlayMode : SndPlayMode = null) {
		var lName		: String;
		var lPath		: String;
		var lUrl		: String;
		
		_id			= pId;
		_playMode	= pPlayMode;
		
		if ( pOtions == null) _options = {};
		else _options = pOtions;
		
		if ( pExts != null) _localExts = pExts;
		
		if ( _options.src == null) {
			if ( pFile == null) pFile = new MyFile( _id);
			else if ( pFile.getName() == "" || pFile.getName() == null) pFile = new MyFile( pId, pFile.getPath(), pFile.getVersion());
			
			lName	= pFile.getName();
			lPath	= pFile.getPath() != null ? pFile.getPath() : "";
			
			if( lName.indexOf( "://") != -1) lUrl = lName;
			else lUrl = lPath + lName;
			
			if ( pExts == null) pExts = SndMgr.getInstance().getExts();
			
			_options.src = new Array<String>();
			
			while ( _options.src.length < pExts.length) _options.src.push( LoadingFile.addVersionToUrl( lUrl + pExts[ _options.src.length], LoadingFile.getVersionUrl( pFile)));
		}
		
		if ( pFile == null) _fileResId = new MyFile( pId);
		else _fileResId = pFile;
		
		//_options.html5 = true;
	}
	
	/**
	 * on réécrit les urls de sources de sons pour y forcer une nouvelle variable anti-cache
	 */
	public function forceAntiCache() : Void {
		var lExts	: Array<String>	= _localExts != null ? _localExts : SndMgr.getInstance().getExts();
		var lFile	: MyFile;
		var lName	: String;
		var lPath	: String;
		var lUrl	: String;
		
		if ( _fileResId.getName() == "" || _fileResId.getName() == null) lFile = new MyFile( _id, _fileResId.getPath(), _fileResId.getVersion());
		else lFile = _fileResId;
		
		lName	= lFile.getName();
		lPath	= lFile.getPath() != null ? lFile.getPath() : "";
		
		if( lName.indexOf( "://") != -1) lUrl = lName;
		else lUrl = lPath + lName;
		
		_options.src = new Array<String>();
		
		while ( _options.src.length < lExts.length) _options.src.push( LoadingFile.addVersionToUrl( lUrl + lExts[ _options.src.length], LoadingFile.getVersionUrl( lFile, true)));
	}
	
	/**
	 * on vérifie si le son est chargé
	 * @return	true si chargé, false sinon
	 */
	public function getIsLoaded() : Bool { return _howl != null && _howl.state() == "loaded"; }
	
	/**
	 * destruction du descripteur ; le son Howl n'est pas détruit, on clean juste les réf
	 */
	public function destroy() : Void {
		_options = null;
		_howl = null;
		_fileResId = null;
	}
	
	/**
	 * on enregistre un son Howl décrit par ce descripteur
	 * @param	pHowl	son howl associé
	 */
	public function regHowl( pHowl : Howl) : Void { _howl = pHowl; }
	
	/**
	 * on récupère le son howl associé à ce descripteur
	 * @return	son howl ou null si pas encore défini
	 */
	public function getHowl() : Howl { return _howl; }
	
	/**
	 * on récupère l'id de son
	 * @return	id de son
	 */
	public function getId() : String { return _id; }
	
	/**
	 * on récupère les options de son
	 * @return	descripteur de son Howl
	 */
	public function getOptions() : HowlOptions { return _options; }
	
	/**
	 * on récupère le descripteur de fichier utilisé pour identifier la ressource chargée du son
	 * @return	descripteur de fichier
	 */
	public function getFileResId() : MyFile { return _fileResId; }
	
	/**
	 * getter sur mode de lecture
	 * @return	mode de lecture par défaut, null si aucun de particulier
	 */
	function get_playMode() : SndPlayMode { return _playMode; }
}