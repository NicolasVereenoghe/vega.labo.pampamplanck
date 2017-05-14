package vega.paddle;
import vega.utils.PointIJ;

/**
 * interface de paddle directionnel
 * 
 * @author nico
 */
interface IDirectionPaddle {
	/**
	 * on récupère vecteurs direction unitaire horizontale (i) et direction unitaire verticale (j)
	 * @return	vecteurs unitaires sur i et j dans { -1, 0, 1}
	 */
	public function getCurDir() : PointIJ;
	
	/**
	 * 
	 * @param	pLock
	 */
	public function lockDir( pLock : PointIJ) : Void;
	
	/**
	 * itération de frame
	 * @param	pDT	delta t en ms depuis dernière itération
	 */
	public function doFrame( pDT : Float) : Void;
	
	/**
	 * destruction
	 */
	public function destroy() : Void;
}