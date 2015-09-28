package util;
import util.BrowserUtil;
class CursorUtil {
    public static var NONE = "none";
    public static var MOVE = "move";
    public static var POINTER = "pointer";
    public static var RESIZE_LT = "nw-resize";
    public static var RESIZE_RT = "ne-resize";
    public static var RESIZE_LB = "sw-resize";
    public static var RESIZE_RB = "se-resize";
    public static var GRAB_MOZ = "-moz-grab";
    public static var GRAB_WEBKIT = "-webkit-grab";
    public static var GRABBING_MOZ = "-moz-grabbing";
    public static var GRABBING_WEBKIT = "-webkit-grabbing";
    public static function resizeCursor(isLeft: Bool, isTop: Bool): String {
        if (isLeft) {
            return isTop ? RESIZE_LT : RESIZE_LB;
        } else {
            return isTop ? RESIZE_RT : RESIZE_RB;
        }
    }
    public static function grabCursor(): String {
        if (BrowserUtil.isFireFox) return GRAB_MOZ;
        if (BrowserUtil.isWebKit) return GRAB_WEBKIT;
        return POINTER;
    }
    public static function grabbingCursor(): String {
        if (BrowserUtil.isFireFox) return GRABBING_MOZ;
        if (BrowserUtil.isWebKit) return GRAB_WEBKIT;
        return POINTER;
    }
}
