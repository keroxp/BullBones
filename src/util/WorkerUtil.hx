package util;
import js.RegExp;
import js.html.URL;
import js.html.Blob;
import js.html.Worker;
class WorkerUtil {
    static var reg = new RegExp("^function\\s*\\w*\\s*\\([\\w\\s,]*\\)\\s*{([\\w\\W]*?)}$", "i");
    public static function createInlineWorker(workerFunc: Dynamic): Worker {
        var func = workerFunc.toString().trim().match(reg)[1];
        var blob = new Blob([ func ], { type: "text/javascript" });
        var url = URL.createObjectURL(blob);
        return new Worker(url);
    }
}
