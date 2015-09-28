package util;
class Log {
    public static inline function d(msg: Dynamic) {
        BrowserUtil.window.console.debug(msg);
    }
    public static inline function e(msg: Dynamic) {
        BrowserUtil.window.console.error(msg);
    }
    public static inline function i(msg: Dynamic) {
        BrowserUtil.window.console.info(msg);
    }
    public static inline function l(msg: Dynamic) {
        BrowserUtil.window.console.log(msg);
    }
    public static inline function w(msg: Dynamic) {
        BrowserUtil.window.console.warn(msg);
    }
}
