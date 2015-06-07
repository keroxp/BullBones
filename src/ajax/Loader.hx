package ajax;
import jQuery.Deferred;
import js.html.Image;
class Loader {
    public static function loadImage(src: String): Deferred {
        var def = new Deferred();
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
