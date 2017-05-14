package vega.loader.file;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class MyFile {
	public static inline var NO_VERSION			: String			= "NO-VERSION";
	public static inline var VERSION_NO_CACHE	: String			= "NO-CACHE";
	
	var _name									: String;
	var _path									: String;
	var _version								: String;
	
	public function new( pName : String, pPath : String = null, pVersion : String = null) {
		_name		= pName;
		_path		= pPath;
		_version	= pVersion != null ? pVersion : ApplicationMatchSize.instance.version;
	}
	
	public function getId() : String { return ( _path != null ? _path + ":" : "") + _name; }
	
	public function getName() : String { return _name; }
	
	public function getPath() : String { return _path; }
	
	public function getVersion() : String { return _version; }
}