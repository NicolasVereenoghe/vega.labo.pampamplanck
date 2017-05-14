package vega.sound;
import howler.Howl;
import howler.Howler;
import js.Browser;
import vega.shell.ApplicationMatchSize;
import vega.shell.VegaFramer;

/**
 * getionnaire de sons
 * @author	nico
 */
class SndMgr {
	/** le singleton */
	static var current					: SndMgr							= null;
	
	/** liste d'extensions de sons supportées, par défaut si non spécifié dans les options d'une piste */
	var exts							: Array<String>						= [ ".mp3", ".ogg"];
	
	/** map de pistes sonores utilisées, indexées par id de piste */
	var tracks							: Map<String,SndTrack>				= null;
	
	/** verrou de premier son joué ; true si le son est verrouillé, false si le son est déverrouillé */
	var firstSndLock					: Bool								= false;
	
	/** volume global */
	var _vol							: Float								= 1;
	
	/** flag indiquand si howler a fini son init (true) ou pas (false) */
	var _isInitEnd						: Bool								= false;
	
	/** flag indiquant si le son doit être mute (true) ou pas (false) */
	var isMute							: Bool								= false;
	
	/**
	 * getter de singleton ; on le crée si inexistant
	 * @param	pVol	volume global, [ 0 .. 1] ; passé au constructeur lors de la création du singleton
	 * @return	ref sur le singleton
	 */
	public static function getInstance( pVol : Float = 1) : SndMgr {
		if ( current == null) current = new SndMgr( pVol);
		
		return current;
	}
	
	/**
	 * construction
	 * @param	pVol	volume global, [ 0 .. 1]
	 */
	function new( pVol) {
		_vol = pVol;
		
		Howler.init();
		
		
		
		//ApplicationMatchSize.instance.traceDebug( "" + Howler.ctx, true);
		
		/*ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::SndMgr : iOSAutoEnable : " + Howler.iOSAutoEnable, true);
		
		Howler.iOSAutoEnable = true;
		
		ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::SndMgr : iOSAutoEnable : " + Howler.iOSAutoEnable, true);*/
		
		//Howler.iOSAutoEnable = true;
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::SndMgr : webAudio : " + Howler.usingWebAudio, true);
		//ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::SndMgr : webAudio : " + Howler.ctx.currentTime, true);
		
		//Howler.iOSAutoEnable
		
		//ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::SndMgr : ");
		//Howler.unload();
		/*Howler.usingWebAudio;
		Howler.iOSAutoEnable = true;*/
		
		/*if ( Browser.supported && Browser.navigator.maxTouchPoints > 0 && ! Howler.usingWebAudio){
			ApplicationMatchSize.instance.traceDebug( "WARNING : SndMgr::SndMgr : mobile device, sound locked !");
			firstSndLock = true;
			
			//Howler.ctx.currentTime
		}*/
		
		
		
		
		/*
		//test audiocontext state to see if audio is running or suspended(iOS)
		  if (!System.touch.supported || (WebAudioSound.supported && WebAudioSound.ctx.state == "running")) {
		   //playMusic("blaze_st_titletheme_openingloop");
		   Global.vFirstSound = true;
		   goIntro1();
		  }else {
		   Global.vFirstSound = false;
		   trace("pointer.up.connect");
		   System.pointer.up.connect(goIntro1).once();
		  }
		*/
		
		
		
		
		
		
		
		tracks = new Map<String,SndTrack>();
		
		if ( ! isHowlerEndInit()) VegaFramer.getInstance().addIterator( checkHolwerEndInit);
	}
	
	/**
	 * on rend le son inaudible ou on le rétablit ; peut être appelé alors que le composant n'a pas fini son init
	 * @param	pIsMute	true pour le rendre inaudible, false pour le rétablir
	 */
	public function switchMute( pIsMute : Bool) : Void {
		if( _isInitEnd) Howler.mute( pIsMute);
		
		isMute = pIsMute;
	}
	
	/**
	 * on récupère la liste d'extensions supportées
	 * @return	liste d'extensions avec le "." devant
	 */
	public function getExts() : Array<String> { return exts; }
	
	/**
	 * on ajoute un son à la collection de pistes
	 * @param	pDesc	descripteur de son
	 * @param	pDoLoad	true pour faire le chargement si le son n'est pas tagué "loaded", sinon laisser false pour juste ajouter un descripteur ; /!\ : sur android, un son qui vient d'être chargé peut toujours être tagué "unloaded", risque de tout casser si on le recharge de suite
	 */
	public function addSndDesc( pDesc : SndDesc, pDoLoad : Bool = false) : Void {
		if ( tracks.exists( pDesc.getId())) {
			ApplicationMatchSize.instance.traceDebug( "WARNING : SndMgr::addSndDesc : sound already defined, ignore : " + pDesc.getId());
			
			return;
		}
		
		tracks[ pDesc.getId()] = new SndTrack( pDesc, pDoLoad);
	}
	
	/**
	 * vire un son de la mémoire
	 * @param	pSubId		pattern de recherche d'identifiants de son à virer ; laisser null pour tout virer
	 */
	public function unload( pSubId : String) : Void {
		var lTrack	: SndTrack;
		
		for ( lTrack in tracks){
			if ( pSubId == null || lTrack.getDesc().getId().indexOf( pSubId) != -1) {
				tracks.remove( lTrack.getDesc().getId());
				lTrack.destroy();
			}
		}
	}
	
	/**
	 * on joue un son
	 * @param	pSndId		identifiant de son
	 * @param	pMode		mode de lecture du son, laisser null pour une lecture par défaut
	 * @param	pDoUnlock	true pour désigner un son qui déverrouille les autres sons (iOS), sinon laisser false
	 * @return	instance de son ouvert, null si échec
	 */
	public function play( pSndId : String, pMode : SndPlayMode = null, pDoUnlock : Bool = false) : SndInstance {
		var lDesc	: SndDesc;
		
		ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::play : " + pSndId);
		
		if ( ! tracks.exists( pSndId)) {
			ApplicationMatchSize.instance.traceDebug( "WARNING : SndMgr::play : unregistered sound, create new record : " + pSndId);
			
			lDesc = new SndDesc( pSndId);
			lDesc.getOptions().preload	= false;
			lDesc.getOptions().autoplay	= false;
			
			lDesc.regHowl( new Howl( lDesc.getOptions()));
			
			tracks[ pSndId] = new SndTrack( lDesc);
		}
		
		if ( isUnlocked() || ( canUnlockSound() && pDoUnlock) || tracks[ pSndId].getDesc().getOptions().loop) return tracks[ pSndId].play( pMode, ( ! isUnlocked()) && ( ! pDoUnlock));
		else{
			ApplicationMatchSize.instance.traceDebug( "WARNING : SndMgr::play : sounds locked, ignore " + pSndId);
			return null;
		}
	}
	
	/**
	 * on arrête les sons en libérant leur cannal
	 * @param	pSubId		pattern de recherche d'identifiants de son à arrêter ; laisser null pour tout arrêter
	 * @param	pExcludeId	pattern d'exclusion d'identifiants de son ; laisser null pour aucune exclusion
	 */
	public function stop( pSubId : String = null, pExcludeId : String = null) : Void {
		var lTrack	: SndTrack;
		
		for ( lTrack in tracks) {
			if ( pSubId == null || lTrack.getDesc().getId().indexOf( pSubId) != -1) {
				if ( pExcludeId == null || lTrack.getDesc().getId().indexOf( pExcludeId) == -1) lTrack.stop();
			}
		}
	}
	
	/**
	 * on vérifie si des sons sont en train d'être joués
	 * @param	pSubId		pattern de recherche d'identifiants de son à vérifier ; laisser null pour tout vérifier
	 * @param	pExcludeId	pattern d'exclusion d'identifiants de son ; laisser null pour aucune exclusion
	 * @return	true si un son à vérifier est en train d'être joué, false sinon
	 */
	public function isPlaying( pSubId : String = null, pExcludeId : String = null) : Bool {
		var lTrack	: SndTrack;
		
		for ( lTrack in tracks) {
			if ( pSubId == null || lTrack.getDesc().getId().indexOf( pSubId) != -1) {
				if ( pExcludeId == null || lTrack.getDesc().getId().indexOf( pExcludeId) == -1) {
					if( lTrack.isPlaying()) return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * on récupère une liste d'instances de canaux de sons en cours de lecture correspondant au pattern de recherche
	 * @param	pSubId	pattern de recherche d'identifiants de son ; laisser null pour tout désigner
	 * @return	liste d'instances de sons recherchées
	 */
	public function getSndTracks( pSubId : String = null) : Array<SndTrack> {
		var lRes	: Array<SndTrack>	= new Array<SndTrack>();
		var lTrack	: SndTrack;
		
		for ( lTrack in tracks) {
			if ( pSubId == null || lTrack.getDesc().getId().indexOf( pSubId) != -1) lRes.push( lTrack);
		}
		
		return lRes;
	}
	
	/**
	 * on applique un coef contextuel de volume aux pistes désignées par le pattern de recherche
	 * @param	pSubId	pattern de recherche d'identifiants de son ; null pour tout désigner
	 * @param	pCoef	coef de volume à appliquer à la config de volume des sons ; < 0 pour virer le coef contextuel et revenir à la config initiale
	 */
	public function setVolumeCoef( pSubId : String, pCoef : Float) : Void {
		var lTrack	: SndTrack;
		
		for ( lTrack in tracks) {
			if ( pSubId == null || lTrack.getDesc().getId().indexOf( pSubId) != -1) {
				lTrack.setVolumeCoef( pCoef);
			}
		}
	}
	
	/**
	 * on vérifie si le son est déverrouillé ; contrainte iOS + test end init howler
	 * @return	true si le son est déverrouillé, false si il est verrouillé ou si on ne sait pas encore si il le sera
	 */
	public function isUnlocked() : Bool { return _isInitEnd && ( /*( Browser.supported && Browser.navigator.maxTouchPoints == 0) || */( ! Howler.usingWebAudio) || Howler.ctx != null && Howler.ctx.currentTime > 0); }
	
	/**
	 * on vérifie si Howler est prêt à déverrouiller le son
	 * @return	true si Howler est prêt à déverrouiller le son, false si Howler a besoin de plus de temps pour résoudre un éventuel déverrouillage
	 */
	function canUnlockSound() : Bool { return Howler.ctx != null; }
	
	/**
	 * itération de frame de vérification de fin d'init de Howler
	 * @param	pDT	dt en ms
	 */
	function checkHolwerEndInit( pDT : Float) : Void {
		if ( isHowlerEndInit()) {
			VegaFramer.getInstance().remIterator( checkHolwerEndInit);
			onHowlerEndInit();
		}
	}
	
	/**
	 * on effectue la vérification de fin d'init de Howler ; si fin, on set le volume global à ::_vol
	 * @return	true si fin d'init, false sinon
	 */
	function isHowlerEndInit() : Bool {
		if ( _isInitEnd) return true;
		
		try{
			Howler.volume( _vol);
			Howler.mute( isMute);
			
			_isInitEnd = true;
			
			return true;
		}catch ( pE : Dynamic){
			return false;
		}
	}
	
	/**
	 * effectue un traitement de fin d'init de howler
	 */
	function onHowlerEndInit() : Void {
		var lExt : String;
		
		ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::onHowlerEndInit", true);
		
		for ( lExt in exts) ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::onHowlerEndInit : codec " + lExt + " : " + Howler.codecs( lExt.substr( 1)), true);
		
		ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::onHowlerEndInit : ctx=" + Howler.ctx, true);
		
		if( Howler.ctx != null) ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::onHowlerEndInit : ctx.time=" + Howler.ctx.currentTime, true);
		if( Howler.ctx != null) ApplicationMatchSize.instance.traceDebug( "INFO : SndMgr::onHowlerEndInit : ctx.rate=" + Howler.ctx.sampleRate, true);
	}
}