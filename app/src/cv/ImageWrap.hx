package cv;
import deferred.Deferred;
import js.Error;
import deferred.Promise;
import protocol.Clonable;
import util.StringUtil;
import js.html.Image;

class ImageWrap implements Clonable {
    public static function load(url: String): Promise<ImageWrap,Error,Float> {
        var img = new Image();
        var def = new Deferred<ImageWrap,Error,Float>();
        img.onload = (function(_img) {
            return function () {
                def.resolve(new ImageWrap(_img));
            }
        })(img);
        img.onerror = (function(){
            return function (e: Error) {
                def.reject(e);
            }
        })();
        img.src = url;
        return def;
    }
    public var src(get, never): String;
    function get_src():String {
        return image.src;
    }
    public var width(get, never): Int;
    function get_width(): Int {
        return image.width;
    }
    public var height(get, never): Int;
    function get_height():Int {
        return image.height;
    }
    public var image: Image;
    public var id: String;
    public function new(img: Image) {
        image = img;
        id = StringUtil.UUID();
    }
    public function clone():ImageWrap {
        return new ImageWrap(cast image.cloneNode(true));
    }
}
