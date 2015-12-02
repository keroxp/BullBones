package util;
import js.Lib;
class StringUtil {
    public static function UUID(len: Int = 4): String {
        var ret = "";
        for (i in 0...len) {
            var base = Math.floor(Math.random()*0x1000000);
            var tos = Reflect.field(Lib.eval("Number.prototype"), "toString");
            ret += Reflect.callMethod(base,tos,[16]);
            if (i < len-1) {
                ret += "-";
            }
        }
        return ret;
    }
}
