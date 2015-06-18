package ajax;
import util.BrowserUtil;
import js.Browser;
import js.html.DOMError;
import js.html.ProgressEvent;
import js.html.File;
import js.html.FileList;
import js.html.FileReader;
import deferred.Promise;
import deferred.Deferred;
import js.html.Image;
class Loader {
    public static function loadImage(src: String): Promise<Image, Dynamic, Int> {
        var def = new Deferred<Image, Dynamic, Int>();
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
        if (src.substr(0,4) == "http" && src.indexOf(BrowserUtil.window.location.href) == -1) {
            // external resource
            img.crossOrigin = "anonymous";
            img.src = '/proxy/$src';
        } else {
            img.src = src;
        }
        return def;
    }
    public static function loadFile(file: File): Promise<String, DOMError, ProgressEvent> {
        var reader = new FileReader();
        if (file.type.indexOf("image/") > -1) {
            var def = new Deferred<String, DOMError, ProgressEvent>();
            reader.onload = function (ev) {
                def.resolve(reader.result);
            };
            reader.onprogress = function(p) {
                def.notify(p);
            }
            reader.onerror = function (ev) {
                def.reject(reader.error);
            }
            reader.readAsDataURL(file);
            return cast def;
        }
        return null;
    }
}
