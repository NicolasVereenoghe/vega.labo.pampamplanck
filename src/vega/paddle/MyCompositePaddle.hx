package vega.paddle;
import vega.utils.PointIJ;

/**
 * paddle directionnel avec controle tactile et au clavier
 * 
 * @author nico
 */
class MyCompositePaddle implements IDirectionPaddle {
	/** tag de mode de controle touch pad */
	public static inline var MODE_TOUCH	: String							= "touch";
	/** tag de mode controle keyboard */
	public static inline var MODE_KEYS	: String							= "keys";
	
	/** tag du dernier mode de controle enregistré */
	var lastControlMode					: String;
	
	/** paddle de clavier */
	var paddleKeys						: MyKeyPaddle;
	/** paddle de touch */
	var paddleTouch						: MyTouchPaddle;
	
	/** construction */
	public function new() {
		paddleKeys	= new MyKeyPaddle();
		paddleTouch	= new MyTouchPaddle();
		
		lastControlMode = MODE_KEYS;
	}
	
	/** @inheritDoc */
	public function getCurDir() : PointIJ {
		var lTouch	: PointIJ	= paddleTouch.getCurDir();
		var lKeys	: PointIJ	= paddleKeys.getCurDir();
		var lRes	: PointIJ	= new PointIJ();
		
		if ( lTouch.i != 0){
			if ( lKeys.i != 0){
				if ( lKeys.i == lTouch.i) lRes.i = lTouch.i;
			}else lRes.i = lTouch.i;
		}else lRes.i = lKeys.i;
		
		if ( lTouch.j != 0){
			if ( lKeys.j != 0){
				if ( lKeys.j == lTouch.j) lRes.j = lTouch.j;
			}else lRes.j = lTouch.j;
		}else lRes.j = lKeys.j;
		
		return lRes;
	}
	
	/** @inheritDoc */
	public function lockDir( pLock : PointIJ) : Void {
		paddleKeys.lockDir( pLock.clone());
		paddleTouch.lockDir( pLock.clone());
	}
	
	/** @inheritDoc */
	public function doFrame( pDT : Float) : Void {
		var lTouch	: PointIJ;
		var lKeys	: PointIJ;
		
		paddleKeys.doFrame( pDT);
		paddleTouch.doFrame( pDT);
		
		lTouch	= paddleTouch.getCurDir();
		lKeys	= paddleKeys.getCurDir();
		
		if ( lKeys.i != 0 || lKeys.j != 0) lastControlMode = MODE_KEYS;
		else if ( lTouch.i != 0 || lTouch.j != 0) lastControlMode = MODE_TOUCH;
	}
	
	/** @inheritDoc */
	public function destroy() : Void {
		paddleKeys.destroy();
		paddleKeys = null;
		
		paddleTouch.destroy();
		paddleTouch = null;
	}
}