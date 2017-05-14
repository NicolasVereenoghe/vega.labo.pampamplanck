package vega.effect.skew;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Matrix;
import pixi.core.math.Point;
import pixi.flump.Movie;

/**
 * déformation d'un clip avec effet de cisaillement : 3d homothétique
 * on joue sur le skew et le scale du contenu passé au manager, et compensation de déformation sur le layer "draw" du contenu passé
 * l'orientation du clip est donnée par son conteneur (content.parent.skew.x), ce qui correspond au layer du movie orienté
 * 
 * 
 * @author nico
 */
class MySkewMgr {
	/** construction */
	public function new() { }
	
	/** défomation en scale dite extrême ; on utilise le contenu en-dessous de ça, sinon on masque */
	var SCALE_LIMIT							: Float									= .15;
	
	/** cos d'orientation du motif */
	var motifCos							: Float									= 0;
	/** sin d'orientation du motif */
	var motifSin							: Float									= 0;
	/** orientation du motif en rad */
	var motifA								: Float									= 0;
	/** distance du point de fuite */
	var motifFuiteX							: Float									= 0;
	/** distance de point de fuite du motif 2 ; -1 si non définie */
	var motifFuiteX2						: Float									= -1;
	
	/** contenu à déformer ; contient un mcFuite dont le x marque la position du point de fuite au repos ; le rotation du contenu donne l'orientation du motif */
	var content								: Movie							= null;
	
	/** contenu alternatif à utiliser quand la déformation est trop forte, sinon null pour rien afficher dans un cas extrême */
	var content2							: Movie							= null;
	
	/**
	 * initialisation
	 * @param	pContent	contenu à déformer ; contient un layer "fuite" dont l'origine marque la position du point de fuite au repos et un layer "draw" qui sera déformé
	 * @param	pContent2	contenu alternatif à utiliser quand la déformation est trop forte, sinon null pour rien afficher dans un cas extrême
	 */
	public function init( pContent : Movie, pContent2 : Movie = null) : Void {
		content		= pContent;
		motifFuiteX	= getSkewFuite().x;
		motifA		= pContent.parent.skew.x;
		motifCos	= Math.cos( motifA);
		motifSin	= Math.sin( motifA);
		
		getSkewFuite().visible = false;
		
		if ( pContent2 != null) {
			content2		= pContent2;
			motifFuiteX2	= getSkewFuite2().x;
			
			getSkewFuite2().visible = false;
		}
	}
	
	/**
	 * destruction
	 */
	public function destroy() : Void {
		content = null;
		content2 = null;
	}
	
	/**
	 * forcer l'état invisible
	 */
	public function hide() : Void {
		content.visible = false;
		
		if ( motifFuiteX2 > 0) content2.visible = false;
	}
	
	/**
	 * on effectue le cisaillement
	 * @param	pToCenter	coordonnées du nouveau point de fuite dans le 
	 */
	public function doSkew( pToCenter : Point) : Void {
		var lScalarX	: Float		= motifCos * pToCenter.x + motifSin * pToCenter.y;
		var lScalarY	: Float		= motifCos * pToCenter.y - motifSin * pToCenter.x;
		var lMtrx		: Matrix;
		
		if ( Math.abs( lScalarX / motifFuiteX) >= SCALE_LIMIT) {
			content.skew.y		= Math.atan( lScalarY / motifFuiteX);
			content.scale.x		= ( lScalarX / motifFuiteX);
			getDraw().scale.x	= 1 / Math.cos( content.skew.y);
			
			content.visible = true;
			
			if ( motifFuiteX2 > 0) content2.visible = false;
		}else {
			content.visible = false;
			
			if ( motifFuiteX2 > 0) {
				if ( Math.abs( lScalarX / motifFuiteX2) >= SCALE_LIMIT) {
					content2.skew.y		= Math.atan( lScalarY / motifFuiteX2);
					content2.scale.x	= ( lScalarX / motifFuiteX2);
					getDraw2().scale.x	= 1 / Math.cos( content2.skew.y);
					
					content2.visible = true;
				}else content2.visible = false;
			}
		}
	}
	
	/**
	 * récupère ref sur point de fuite du contenu
	 * @return	mc point de fuite dont x donne distance de celui-ci
	 */
	function getSkewFuite() : Container { return content.getLayer( "fuite"); }
	
	/**
	 * récupère ref sur point de fuite du contenu 2
	 * @return	mc point de fuite dont x donne distance de celui-ci
	 */
	function getSkewFuite2() : Container { return content2.getLayer( "fuite"); }
	
	/**
	 * récupère ref sur dessin du motif du contenu
	 * @return	contenu de dessin à déformé
	 */
	function getDraw() : DisplayObject { return content.getLayer( "draw").getChildAt( 0); }
	
	/**
	 * récupère ref sur dessin du motif du contenu 2
	 * @return	contenu de dessin à déformé
	 */
	function getDraw2() : DisplayObject { return content2.getLayer( "draw").getChildAt( 0); }
}