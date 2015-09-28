package util;
import js.html.Window;
import js.html.Document;
import js.Browser;
class BrowserUtil {
    private static function ua (): String {
        return window.navigator.userAgent.toLowerCase();
    }
    public static var window: Window =  Browser.window;
    public static var document: Document = Browser.document;
    public static var dpr: Float = window.devicePixelRatio;

    private static function _isMobile () {
        return !_isBrowser();
    }
    private static function _isBrowser() {
        return !_isMobilePhone() && !_isTablet();
    }

    private static function _isMobilePhone () {
        var u = ua();
        return (u.indexOf("windows") != -1 && u.indexOf("phone") != -1)
        || u.indexOf("iphone") != -1
        || u.indexOf("ipod") != -1
        || (u.indexOf("android") != -1 && u.indexOf("mobile") != -1)
        || (u.indexOf("firefox") != -1 && u.indexOf("mobile") != -1)
        || u.indexOf("blackberry") != -1;
    }
    private static function _isTablet () {
        var u = ua();
        return (u.indexOf("windows") != -1 && u.indexOf("touch") != -1)
        || u.indexOf("ipad") != -1
        || (u.indexOf("android") != -1 && u.indexOf("mobile") == -1)
        || (u.indexOf("firefox") != -1 && u.indexOf("tablet") != -1)
        || u.indexOf("kindle") != -1
        || u.indexOf("silk") != -1
        || u.indexOf("playbook") != -1;
    }
    private static function _isFireFox () {
        return ua().indexOf("firefox") > -1;
    }
    private static function _isWebKit() {
        return ua().indexOf("webkit") > -1;
    }

    public static var isMobilePhone: Bool = _isMobilePhone();
    public static var isMobile: Bool = _isMobile();
    public static var isBrowser: Bool = _isBrowser();
    public static var isTablet: Bool = _isTablet();
    public static var isFireFox: Bool = _isFireFox();
    public static var isWebKit: Bool = _isWebKit();

}
