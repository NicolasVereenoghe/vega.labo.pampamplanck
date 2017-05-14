package vega.sound;
import vega.shell.ApplicationMatchSize;
import vega.shell.VegaFramer;

/**
 * instance de son ( descripteur de canal sonore ouvert)
 * @author nico
 */
class SndInstance {
	/** délai max d'attente en ms pour reprise de lecture une fois le chargement effectué */
	var PLAY_DELAI_MAX					: Float							= 1500;
	
	/** ref sur la piste sonore en charge de cette instance de son */
	var _track							: SndTrack						= null;
	public var track( get, null)		: SndTrack;
	/** id de canal sonore de son ; -1 si pas encore défini */
	var _chan							: Int							= -1;
	public var chan( get, null)			: Int;
	
	/** mode de lecture ; null si aucun de particulier */
	var mode							: SndPlayMode					= null;
	
	/** timestamp en ms de création de l'instance de son */
	var createTimestamp					: Float							= -1;
	/** timestamp en ms de demande de lancement avant chargement ; < 0 si pas défini */
	var playTimestamp					: Float							= -1;
	/** timestamp en ms d'ouverture de canal sonore ; < 0 si pas défini */
	var openTimestamp					: Float							= -1;
	
	/** itération de frame ; null si pas d'itération en cours */
	var doMode							: Void->Void					= null;
	
	/** coef appliqué au volume de base de ce son (de base : celui trouvé dans l'objet Howl du descripteur) ; [ 0 .. 1] */
	public var volume( get, set)		: Float;
	var _volume							: Float							= 1;
	
	/**
	 * construction
	 * @param	pTrack	piste sonore en charge de cette instance de son
	 */
	public function new( pTrack : SndTrack) {
		_track	= pTrack;
		
		VegaFramer.getInstance().addIterator( onFrame);
		
		createTimestamp = Date.now().getTime();
	}
	
	/**
	 * on effectue une lecture simple
	 * @param	pMode	mode de lecture du son, laisser null pour une lecture par défaut
	 */
	public function play( pMode : SndPlayMode = null) : Void {
		mode	= pMode;
		
		checkMax();
		
		if ( Std.is( mode, ISndPlayModeDelayed)) setModeDelayed();
		else if ( ! regChainedTracks()) tryUnloadedTrackOpenChan();
	}
	
	/**
	 * on lance une lecture virtuelle d'un canal invalide
	 * @param	pMode	mode de lecture du son, laisser null pour une lecture par défaut
	 */
	public function playInvalid( pMode : SndPlayMode = null) : Void {
		ApplicationMatchSize.instance.traceDebug( "WARNING : SndInstance::playInvalid : " + _track.getDesc().getId());
		
		mode	= pMode;
		
		checkMax();
		
		if ( Std.is( mode, ISndPlayModeDelayed)) setModeDelayedInvalid();
		else{
			regChainedTracks();
			
			setModeOpenChanInvalid();
		}
	}
	
	/**
	 * on récupère un timestamp du son
	 * @return	timestamp en ms
	 */
	public function getTimestamp() : Float {
		if ( openTimestamp >= 0) return openTimestamp;
		else if ( playTimestamp >= 0) return playTimestamp;
		else return createTimestamp;
	}
	
	/**
	 * on force la mise à jour du volume du son
	 */
	public function updateVolume() : Void {
		if ( _chan >= 0){
			if ( _track.volumeCoef >= 0) _track.getDesc().getHowl().volume( _track.getDesc().getHowl().volume() * _track.volumeCoef * _volume, _chan);
			else _track.getDesc().getHowl().volume( _track.getDesc().getHowl().volume() * _volume, _chan);
		}
	}
	
	function get_volume() : Float { return _volume; }
	function set_volume( pVol : Float) : Float {
		_volume = pVol;
		
		updateVolume();
		
		return _volume;
	}
	
	/**
	 * on effectue l'enregistrement des écouteurs de son chainés si le mode de lecture le requiert
	 * @return	true si il y a eu chaînage, false  sinon
	 */
	function regChainedTracks() : Bool {
		var lTracks	: Array<SndTrack>;
		var lTrack	: SndTrack;
		
		if ( Std.is( mode, ISndPlayModeChained)){
			if ( SndMgr.getInstance().isPlaying( cast( mode, ISndPlayModeChained).getChainedSubId())){
				lTracks = SndMgr.getInstance().getSndTracks( cast( mode, ISndPlayModeChained).getChainedSubId());
				
				for ( lTrack in lTracks){
					if ( lTrack.isPlaying()) lTrack.addEndListener( onSndChainEnd);
				}
				
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * itération de frame
	 * @param	pDT	dt en ms
	 */
	function onFrame( pDT : Float) : Void { if ( doMode != null) doMode(); }
	
	/**
	 * on essaye d'ouvrir un canal qui est potentiellement pas chargé ; si c'est le cas on essaye de le faire tourner virtuellement
	 */
	function tryUnloadedTrackOpenChan() : Void {
		if ( ! _track.getDesc().getIsLoaded()) setModeOpenChanInvalid();
		else openChan();
	}
	
	/**
	 * on passe en mode itération d'un canal pas prêt ; on surveille quand il le sera, on le stope si trop tard
	 */
	function setModeOpenChanInvalid() : Void {
		openTimestamp = -1;
		playTimestamp = Date.now().getTime();
		
		doMode = doModeOpenChanInvalid;
	}
	
	/**
	 * on agit en mode itération d'un canal pas prêt ; on surveille quand il le sera, on le stope si trop tard
	 */
	function doModeOpenChanInvalid() : Void {
		if ( _track.getDesc().getIsLoaded() && SndMgr.getInstance().isUnlocked()) checkTimestampPlay();
		else checkTimestampStop();
	}
	
	/**
	 * on passe en mode lecture différée ; on surveille quand il faudra le lancer
	 */
	function setModeDelayed() : Void {
		openTimestamp = cast( mode, ISndPlayModeDelayed).getDelayedStartTime();
		
		doMode = doModeDelayed;
	}
	
	/**
	 * on agit en mode lecture différée ; on surveille quand il faudra le lancer
	 */
	function doModeDelayed() : Void {
		if ( Date.now().getTime() >= cast( mode, ISndPlayModeDelayed).getDelayedStartTime()){
			if ( ! regChainedTracks()) tryUnloadedTrackOpenChan();
		}
	}
	
	/**
	 * on passe en mode lecture différée d'un canal invalide ; on surveille quand il faudra le lancer
	 */
	function setModeDelayedInvalid() : Void {
		openTimestamp = cast( mode, ISndPlayModeDelayed).getDelayedStartTime();
		
		doMode = doModeDelayedInvalid;
	}
	
	/**
	 * on agit en mode lecture différée d'un canal invalide ; on surveille quand il faudra le lancer
	 */
	function doModeDelayedInvalid() : Void {
		if ( Date.now().getTime() >= cast( mode, ISndPlayModeDelayed).getDelayedStartTime()){
			regChainedTracks();
			
			setModeOpenChanInvalid();
		}
	}
	
	/**
	 * on stope le canal
	 */
	public function stop() : Void {
		var lTracks	: Array<SndTrack>;
		var lTrack	: SndTrack;
		
		if ( _chan >= 0){
			_track.getDesc().getHowl().stop( _chan);
			_chan = -1;
		}
		
		if ( Std.is( mode, ISndPlayModeChained)) {
			lTracks = SndMgr.getInstance().getSndTracks( cast( mode, ISndPlayModeChained).getChainedSubId());
			
			for ( lTrack in lTracks) lTrack.remEndListener( onSndChainEnd);
		}
		
		onSndEnd();
	}
	
	/**
	 * on vérifie le timestamp et si on est hors délai on stope
	 */
	public function checkTimestampStop() : Void {
		if ( playTimestamp > 0){
			if( ( ! _track.getDesc().getOptions().loop) && Date.now().getTime() - playTimestamp > PLAY_DELAI_MAX) {
				ApplicationMatchSize.instance.traceDebug( "WARNING : SndInstance::checkTimestampStop : too late, stop : " + _track.getDesc().getId());
				
				stop();
			}
		}
	}
	
	/**
	 * on vérifie le timestamp et si on est toujours dans les délais, on lance la lecture, sinon on stope
	 */
	public function checkTimestampPlay() : Void {
		if ( playTimestamp > 0){
			if( _track.getDesc().getOptions().loop || Date.now().getTime() - playTimestamp <= PLAY_DELAI_MAX) {
				ApplicationMatchSize.instance.traceDebug( "INFO : SndInstance::checkTimestampPlay : loaded, resume play : " + _track.getDesc().getId());
				
				if ( Std.is( mode, ISndPlayModeChained)) onSndChainEnd();
				else openChan();
			}else {
				ApplicationMatchSize.instance.traceDebug( "WARNING : SndInstance::checkTimestampPlay : loaded, too late, stop : " + _track.getDesc().getId());
				
				stop();
			}
		}
	}
	
	/**
	 * si le mode de lecture est de type SndPlayModeMax, on arrête les sons configurés en trop, en commencçant par les plus anciens
	 */
	function checkMax() : Void {
		var lChans		: Array<SndInstance>;
		var lTracks		: Array<SndTrack>;
		var lTrack		: SndTrack;
		var lInstance	: SndInstance;
		var lMax		: Int;
		var lI			: Int;
		
		if ( Std.is( mode, ISndPlayModeMax)){
			lMax	= cast( mode, ISndPlayModeMax).getMaxNb();
			lTracks = SndMgr.getInstance().getSndTracks( cast( mode, ISndPlayModeMax).getMaxSubId());
			lChans	= [];
			
			for ( lTrack in lTracks){
				for ( lInstance in lTrack.channels){
					if ( lInstance != this){
						lChans.push( lInstance);
					}
				}
			}
			
			if ( lChans.length > lMax){
				lChans.sort( cmpTimestamp);
				
				lI		= 0;
				lMax	= lChans.length - lMax;
				while ( lI < lMax){
					lChans[ lI++].stop();
				}
			}
		}
	}
	
	/**
	 * comparaison du temps de vie de 2 instances de son
	 * @param	pSndI1	instance de son 1
	 * @param	pSndI2	instance de son 2
	 * @return	-1 si pSndI1 lancé avant, 1 si lancé après, 0 si en même temps
	 */
	function cmpTimestamp( pSndI1 : SndInstance, pSndI2 : SndInstance) : Int {
		if ( pSndI1.getTimestamp() > pSndI2.getTimestamp()) return 1;
		else if ( pSndI1.getTimestamp() < pSndI2.getTimestamp()) return -1;
		else return 0;
	}
	
	/**
	 * on ouvre un canal de lecture
	 */
	function openChan() : Void {
		var lTime	: Float	= Date.now().getTime();
		
		doMode = null;
		
		if( ! SndMgr.getInstance().isUnlocked()) ApplicationMatchSize.instance.traceDebug( "WARNING : SndInstance::openChan : unlocker ? : " + _track.getDesc().getId());
		
		if( ( ! Std.is( mode, ISndPlayModeSync)) || _track.getDesc().getOptions().loop || lTime - cast( mode, ISndPlayModeSync).getSyncStartedAtTime() < _track.getDesc().getHowl().duration() * 1000){
			_chan = _track.getDesc().getHowl().play();
		}
		
		if ( _chan >= 0){
			_track.getDesc().getHowl().on( "end", onSndEnd, _chan);
			
			playTimestamp	= -1;
			
			if ( Std.is( mode, ISndPlayModeSync)){
				_track.getDesc().getHowl().seek( ( ( lTime - cast( mode, ISndPlayModeSync).getSyncStartedAtTime()) / 1000) % _track.getDesc().getHowl().duration(), _chan);
				
				openTimestamp = cast( mode, ISndPlayModeSync).getSyncStartedAtTime();
			}else openTimestamp	= lTime;
			
			updateVolume();
			
			ApplicationMatchSize.instance.traceDebug( "INFO : SndInstance::openChan : " + _track.getDesc().getId() + " : " + _chan);
		}else{
			ApplicationMatchSize.instance.traceDebug( "ERROR : SndInstance::openChan : " + _track.getDesc().getId() + " : " + _chan);
			
			onSndEnd();
		}
	}
	
	/**
	 * on capture la fin de lecture du canal sonore ; si pas de boucle, on détruit ce canal
	 */
	function onSndEnd() : Void {
		if( _track != null){
			if ( _chan >= 0) {
				if ( _track.getDesc().getOptions().loop){
					if ( _track.getDesc().getHowl().playing( _chan)){
						ApplicationMatchSize.instance.traceDebug( "INFO : SndInstance::onSndEnd : loop " + _track.getDesc().getId() + " : " + _chan);
						
						if( ! Std.is( mode, ISndPlayModeSync)) _track.getDesc().getHowl().seek( 0.0, _chan);
					}else{
						ApplicationMatchSize.instance.traceDebug( "WARNING : SndInstance::onSndEnd : broken loop, restart : " + _track.getDesc().getId() + " : " + _chan);
						
						_chan = _track.getDesc().getHowl().play();
					}
					
					if( Std.is( mode, ISndPlayModeSync)) _track.getDesc().getHowl().seek( ( ( Date.now().getTime() - cast( mode, ISndPlayModeSync).getSyncStartedAtTime()) / 1000) % _track.getDesc().getHowl().duration(), _chan);
					
					return;
				}
				
				_track.getDesc().getHowl().off( "end", onSndEnd, _chan);
			}
			
			doMode = null;
			VegaFramer.getInstance().remIterator( onFrame);
			
			ApplicationMatchSize.instance.traceDebug( "INFO : SndInstance::onSndEnd : " + _track.getDesc().getId() + " : " + _chan);
			
			_track.onChanStop( this);
			
			_track = null;
			mode = null;
			_chan = -1;
		}
	}
	
	/**
	 * on capture la fin de lecture d'un canal chainé
	 */
	function onSndChainEnd() : Void {
		var lTracks	: Array<SndTrack>;
		var lTrack	: SndTrack;
		
		if ( _track.getDesc().getIsLoaded() && SndMgr.getInstance().isUnlocked() && ! SndMgr.getInstance().isPlaying( cast( mode, ISndPlayModeChained).getChainedSubId())) {
			lTracks = SndMgr.getInstance().getSndTracks( cast( mode, ISndPlayModeChained).getChainedSubId());
			
			for ( lTrack in lTracks) lTrack.remEndListener( onSndChainEnd);
			
			ApplicationMatchSize.instance.traceDebug( "INFO : SndInstance::onSndChainEnd : play " + _track.getDesc().getId());
			
			tryUnloadedTrackOpenChan();
		}
	}
	
	/**
	 * getter sur num de cannal ouvert par l'instance
	 * @return	num de cannal ou -1 si pas ouvert
	 */
	function get_chan() : Int { return _chan; }
	
	/**
	 * getter sur la piste responsable de cette instance de son
	 * @return	piste sonore de l'instance
	 */
	function get_track() : SndTrack { return _track; }
}