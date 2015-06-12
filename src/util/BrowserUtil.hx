package util;
import js.Browser;
import js.html.DOMWindow;
class BrowserUtil {
    private static var window: DOMWindow = Browser.window;
    private static function ua (): String {
        return window.navigator.userAgent.toLowerCase();
    }
    public static function isBrowser() {
        return !isMobile() && !isTablet();
    }
    public static function isMobile () {
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
}
