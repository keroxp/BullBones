package ajax;
import deferred.Promise;
import deferred.Deferred;
import js.html.Image;
class Loader {
    public static function loadImage(src: String): Promise<js.html.Image, Dynamic, Int> {
        var def = new Deferred<js.html.Image, Dynamic, Int>();
        var img = new Image();
        img.onload = function (e) {
            try {
                def.resolve(img);
            } catch (e: js.Error) {
                def.reject(e);
            }
        };
        img.onerror = function (e) {
            def.reject(e);
        }
        if (src.substr(0,4) == "http") {
            img.src = "proxy/"+src;
        } else {
            img.src = src;
        }
        return def;
    }
}
