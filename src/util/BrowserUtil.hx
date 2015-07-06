package util;
import js.html.Document;
import js.Browser;
import js.html.DOMWindow;
class BrowserUtil {
    private static function ua (): String {
        return window.navigator.userAgent.toLowerCase();
    }
    public static var window: DOMWindow =  Browser.window;
    public static var document: Document = Browser.document;

    public static function isMobile () {
        return !isBrowser();
    }
    public static function isBrowser() {
        return !isMobilePhone() && !isTablet();
    }
    public static function isMobilePhone () {
        var u = ua();
        return (u.indexOf("windows") != -1 && u.indexOf("phone") != -1)
        || u.indexOf("iphone") != -1
        || u.indexOf("ipod") != -1
        || (u.indexOf("android") != -1 && u.indexOf("mobile") != -1)
        || (u.indexOf("firefox") != -1 && u.indexOf("mobile") != -1)
        || u.indexOf("blackberry") != -1;
    }
    public static function isTablet () {
        var u = ua();
        return (u.indexOf("windows") != -1 && u.indexOf("touch") != -1)
        || u.indexOf("ipad") != -1
        || (u.indexOf("android") != -1 && u.indexOf("mobile") == -1)
        || (u.indexOf("firefox") != -1 && u.indexOf("tablet") != -1)
        || u.indexOf("kindle") != -1
        || u.indexOf("silk") != -1
        || u.indexOf("playbook") != -1;
    }
    public static function isFireFox () {
        return ua().indexOf("firefox") > -1;
    }
    public static function isWebKit() {
        return ua().indexOf("webkit") > -1;
    }
    public static function grabCursor(): String {
        if (isFireFox()) return "-moz-grab";
        if (isWebKit()) return "-webkit-grab";
        return "pointer";
    }
    public static function grabbingCursor(): String {
        if (isFireFox()) return "-moz-grabbing";
        if (isWebKit()) return "-webkit-grabbing";
        return "pointer";
    }
}
