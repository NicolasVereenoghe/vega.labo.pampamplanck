package vega.shell;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.renderers.webgl.WebGLRenderer;
import pixi.core.sprites.Sprite;
import vega.shell.MyFPS.MyFPSCtr;

/**
 * fps léger
 * @author nico
 */
class MyFPS {
	static var pixelW		: Float										= 3;
	static var pixelH		: Float										= 4;
	
	static var digitsData	: Array<Array<Array<Dynamic>>>				= [
		[
			[ 0, 0, 0],
			[ 0, 0, 0],
			[ 0, 0, 0],
			[ 0, 1, 0]
		],
		[
			[ 0, 1, 1],
			[ 0, 0, 1],
			[ 0, 0, 1],
			[ 0, 0, 1]
		],
		[
			[ 1, 1, 0],
			[ 0, 0, 1],
			[ 0, 1, 0],
			[ 1, 1, 1]
		],
		[
			[ 1, 1, 1],
			[ 0, 1, 0],
			[ 0, 0, 1],
			[ 1, 1, 0]
		],
		[
			[ 1, 0, 0],
			[ 1, 0, 1],
			[ 1, 1, 1],
			[ 0, 0, 1]
		],
		[
			[ 1, 1, 1],
			[ 1, 0, 0],
			[ 0, 1, 0],
			[ 1, 0, 0]
		],
		[
			[ 0, 1, 1],
			[ 1, 1, 0],
			[ 1, 0, 1],
			[ 0, 1, 0]
		],
		[
			[ 1, 1, 1],
			[ 0, 0, 1],
			[ 0, 1, 1],
			[ 0, 0, 1]
		],
		[
			[ 1, 1, 1],
			[ 1, 0, 1],
			[ 1, 1, 1],
			[ 1, 1, 1]
		],
		[
			[ 1, 1, 1],
			[ 1, 0, 1],
			[ 1, 1, 1],
			[ 0, 0, 1]
		],
		[
			[ 1, 1, 1],
			[ 1, 0, 1],
			[ 1, 0, 1],
			[ 1, 1, 1]
		]
	];
	
	static var bmps			: Array<Graphics>						= null;
	
	var deltFpsPixelX		: Float									= 6;
	var digitPixelW			: Float									= 3;
	var digitPixelH			: Float									= 4;
	var digitSpacePixelW	: Float									= 2;
	var borderPixelW		: Float									= 1;
	var borderPixelH		: Float									= 1;
	var nbDigitsUnits		: Int									= 2;
	var nbDigitsDec			: Int									= 1;
	
	var colorDigit			: Int									= 0xff0088;
	var colorBg				: Int									= 0;
	
	var fps1				: MyFPSCtr;
	var fps2				: MyFPSCtr;
	var fps3				: MyFPSCtr;
	var ctrMin				: MySimpleCtr;
	
	var NB_CTR				: Int									= 4;
	
	var renderer			: Dynamic;
	
	var _content			: Container;
	
	var lastTime			: Float;
	
	public function new( pCont : Container, pRenderer : Dynamic)  {
		var lBmp	: Graphics;
		var lI		: Int;
		var lLine	: Int;
		var lCol	: Int;
		
		_content = cast pCont.addChild( new Container());
		
		renderer = pRenderer;
		
		if ( bmps == null){
			bmps = new Array<Graphics>();
			
			lI = 0;
			while( lI < digitsData.length){
				lBmp = new Graphics();
				
				lBmp.beginFill( colorBg, 1);
				lBmp.drawRect( 0, 0, pixelW * digitPixelW, pixelH * digitPixelH);
				lBmp.endFill();
				
				bmps.push( lBmp);
				
				lLine = 0;
				while ( lLine < digitsData[ lI].length){
					lCol = 0;
					while ( lCol < digitsData[ lI][ lLine].length){
						if ( Std.string( digitsData[ lI][ lLine][ lCol]) == "1"){
							lBmp.beginFill( colorDigit, 1);
							lBmp.drawRect( lCol * pixelW, lLine * pixelH, pixelW, pixelH);
							lBmp.endFill();
						}
						
						lCol++;
					}
					
					lLine++;
				}
				
				lI++;
			}
		}
		
		lBmp = cast _content.addChild( new Graphics());
		
		lBmp.beginFill( colorBg, 1);
		lBmp.drawRect( 0, 0, ( NB_CTR * ( digitPixelW * ( nbDigitsDec + nbDigitsUnits + 1) + digitSpacePixelW * ( nbDigitsDec + nbDigitsUnits)) + ( NB_CTR - 1) * deltFpsPixelX + 2 * borderPixelW) * pixelW, ( 2 * borderPixelH + digitPixelH) * pixelH);
		lBmp.endFill();
		
		buildFPS();
		
		lastTime = Date.now().getTime();
	}
	
	public function doFrame( pDT : Float) : Void {
		var lTime	: Float	= Date.now().getTime();
		
		pDT			= lTime - lastTime;
		lastTime	= lTime;
		
		fps1.doFrame( pDT);
		fps2.doFrame( pDT);
		fps3.doFrame( pDT);
		
		ctrMin.setVal( ApplicationMatchSize.instance.fps);
	}
	
	public function getContent() : Container { return _content; }
	
	function buildFPS() : Void {
		fps1 = new MyFPSCtr( cast _content.addChild( new Container()), this, 300);
		fps1.getContent().x = borderPixelW * pixelW;
		fps1.getContent().y = borderPixelH * pixelH;
		
		fps2 = new MyFPSCtr( cast _content.addChild( new Container()), this, 1500);
		fps2.getContent().x = ( borderPixelW + digitPixelW * ( nbDigitsDec + nbDigitsUnits + 1) + digitSpacePixelW * ( nbDigitsDec + nbDigitsUnits) + deltFpsPixelX) * pixelW;
		fps2.getContent().y = borderPixelH * pixelH;
		
		fps3 = new MyFPSCtr( cast _content.addChild( new Container()), this, 4000);
		fps3.getContent().x = ( borderPixelW + 2 * ( digitPixelW * ( nbDigitsDec + nbDigitsUnits + 1) + digitSpacePixelW * ( nbDigitsDec + nbDigitsUnits) + deltFpsPixelX)) * pixelW;
		fps3.getContent().y = borderPixelH * pixelH;
		
		ctrMin = new MySimpleCtr( cast _content.addChild( new Container()), this);
		ctrMin.getContent().x = ( borderPixelW + 3 * ( digitPixelW * ( nbDigitsDec + nbDigitsUnits + 1) + digitSpacePixelW * ( nbDigitsDec + nbDigitsUnits) + deltFpsPixelX)) * pixelW;
		ctrMin.getContent().y = borderPixelH * pixelH;
	}
}

class MyFPSCtr extends MySimpleCtr {
	var dts					: Array<Int>;
	var tmpCtr				: Int;
	var timeLimit			: Int;
	
	public function new( pCont : Container, pFPS : MyFPS, pTmpTime : Float) {
		super( pCont, pFPS);
		
		tmpCtr		= 0;
		dts			= new Array<Int>();
		timeLimit	= Std.int( pTmpTime);
	}
	
	public function doFrame( pDT : Float) : Void {
		var lDT	: Int	= Std.int( pDT);
		
		dts.push( lDT);
		tmpCtr += lDT;
		
		if ( tmpCtr > timeLimit){
			setVal( 1000 * dts.length / tmpCtr);
			
			while ( tmpCtr - dts[ 0] > timeLimit){
				tmpCtr -= dts[ 0];
				dts.splice( 0, 1);
			}
		}
	}
}

@:access(vega.shell.MyFPS)
class MySimpleCtr {
	var _content		: Container;
	var _myFPS			: MyFPS;
	
	var _val			: Int					= -1;
	var _strVal			: String;
	
	public function new( pCont : Container, pFPS : MyFPS){
		var lI		: Int;
		var lJ		: Int;
		var lDigit	: Container;
		
		_content	= pCont;
		_myFPS		= pFPS;
		
		_strVal = "";
		while ( _strVal.length < _myFPS.nbDigitsDec + _myFPS.nbDigitsUnits) _strVal += "0";
		
		lI = 0;
		while ( lI < _myFPS.nbDigitsUnits){
			lDigit = cast _content.addChild( new Container());
			lDigit.x = lI * ( _myFPS.digitPixelW + _myFPS.digitSpacePixelW) * MyFPS.pixelW;
			
			lJ = 1;
			while ( lJ < MyFPS.bmps.length){
				lDigit.addChild( new Sprite( MyFPS.bmps[ lJ].generateTexture( _myFPS.renderer))).visible = ( lJ == 10);
				
				lJ++;
			}
			
			lI++;
		}
		
		lDigit = cast _content.addChild( new Container());
		lDigit.x = lI * ( _myFPS.digitPixelW + _myFPS.digitSpacePixelW) * MyFPS.pixelW;
		lDigit.addChild( new Sprite( MyFPS.bmps[ 0].generateTexture( _myFPS.renderer)));
		
		lI++;
		while ( lI < _myFPS.nbDigitsUnits + _myFPS.nbDigitsDec + 1){
			lDigit = cast _content.addChild( new Container());
			lDigit.x = lI * ( _myFPS.digitPixelW + _myFPS.digitSpacePixelW) * MyFPS.pixelW;
			
			lJ = 1;
			while ( lJ < MyFPS.bmps.length){
				lDigit.addChild( new Sprite( MyFPS.bmps[ lJ].generateTexture( _myFPS.renderer))).visible = ( lJ == 10);
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	public function getVal() : Float {
		if ( _val < 0) return -1;
		else return _val / Math.round( Math.pow( 10, _myFPS.nbDigitsDec));
	}
	
	public function setVal( pVal : Float) : Void {
		var lVal	: Int		= Math.round( Math.round( Math.pow( 10, _myFPS.nbDigitsDec)) * pVal);
		var lDigit	: Container;
		var lStr	: String;
		var lI		: Int;
		
		if ( lVal != _val){
			lStr	= toStrVal( lVal);
			
			lI = 0;
			while ( lI < _myFPS.nbDigitsUnits){
				if ( lStr.charAt( lI) != _strVal.charAt( lI)){
					lDigit = cast _content.getChildAt( lI);
					
					lDigit.getChildAt( ( Std.parseInt( _strVal.charAt( lI)) + 9) % 10).visible = false;
					lDigit.getChildAt( ( Std.parseInt( lStr.charAt( lI)) + 9) % 10).visible = true;
				}
				
				lI++;
			}
			
			lI++;
			while ( lI < _myFPS.nbDigitsUnits + _myFPS.nbDigitsDec + 1){
				if ( lStr.charAt( lI - 1) != _strVal.charAt( lI - 1)){
					lDigit = cast _content.getChildAt( lI);
					
					lDigit.getChildAt( ( Std.parseInt( _strVal.charAt( lI - 1)) + 9) % 10).visible = false;
					lDigit.getChildAt( ( Std.parseInt( lStr.charAt( lI - 1)) + 9) % 10).visible = true;
				}
				
				lI++;
			}
			
			_val	= lVal;
			_strVal	= lStr;
		}
	}
	
	public function getContent() : Container { return _content; }
	
	function toStrVal( pInt) : String {
		var lStr	: String	= Std.string( pInt);
		
		if ( lStr.length > _myFPS.nbDigitsDec + _myFPS.nbDigitsUnits) return lStr.substr( lStr.length - _myFPS.nbDigitsDec - _myFPS.nbDigitsUnits);
		else{
			while ( lStr.length < _myFPS.nbDigitsDec + _myFPS.nbDigitsUnits) lStr = "0" + lStr;
			
			return lStr;
		}
	}
}