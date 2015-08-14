package util;
class ArrayUtil {
    public static function findFirst<T>(arr: Array<T>, callback: T -> Bool): T {
        for (i in 0...arr.length) {
            if (callback(arr[i])) {
                return arr[i];
            }
        }
        return null;
    }
    public static function findLast<T>(arr: Array<T>, callback: T -> Bool): T {
        for (i in 0...arr.length) {
            var el = arr[arr.length-1-i];
            if (callback(el)) {
                return el;
            }
        }
        return null;
    }
    public static function removeFirst<T>(arr: Array<T>, callback: T -> Bool): T {
        var tgt: T = null;
        for (v in arr) {
            if (callback(v)) {
                tgt = v;
                break;
            }
        }
        if (tgt != null) {
            arr.remove(tgt);
            return tgt;
        }
        return null;
    }
}
