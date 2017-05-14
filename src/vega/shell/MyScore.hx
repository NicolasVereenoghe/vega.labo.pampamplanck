package vega.shell;

/**
 * descripteur de score obtenu en fin de partie
 * @author	nico
 */
class MyScore {
	/** représentation par valeur numérique de score obtenu en fin de partie */
	var _score						: Float						= -1;

	/**
	 * constructeur
	 * @param	pScore	représentation par valeur numérique de score obtenu en fin de partie
	 */
	public function new( pScore : Float) { _score = pScore; }
	
	/**
	 * on récupère la valeur numérique du score obtenu en fin de partie
	 * @return	valeur de score
	 */
	public function getScore() : Float { return _score; }
}