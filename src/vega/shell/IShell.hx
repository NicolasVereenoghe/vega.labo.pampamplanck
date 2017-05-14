package vega.shell;
import vega.screen.MyScreen;

/**
 * @author nico
 */
interface IShell {
	public function onScreenReady( pScreen : MyScreen) : Void;
	
	public function onScreenClose( pScreen : MyScreen, pNext : MyScreen = null) : Void;
	
	public function onScreenEnd( pScreen : MyScreen) : Void;
	
	public function switchLock( pIsLock : Bool) : Void;
	
	/**
	 * on récupère les données sauvées correspondant à un identifiant de données
	 * @param	pId		identifiant de données recherchées ; laisser null pour des propriétés globales
	 * @param	pForce	true pour forcer la création de données vierges si aucune données trouvées à cet identifiant ; laisser false pour retourner null si données absentes
	 * @return	données sauvées correspondant à cet identifiant, ou null si rien de trouvé
	 */
	function getSavedDatas( pId : String, pForce : Bool = false) : SavedDatas;
	
	/**
	 * on sauvegarde un jeu de données correspondant à un identifant de données
	 * @param	pId		identifiant du jeu de données à sauver ; laisser null pour des propriétés globales
	 * @param	pDatas	jeu de données à sauver ; null pour supprimer les données à cet identifiant
	 */
	function setSavedDatas( pId : String, pDatas : SavedDatas) : Void;
}