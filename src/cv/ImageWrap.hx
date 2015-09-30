package cv;
import protocol.Clonable;
import util.StringUtil;
import js.html.Image;

class ImageWrap implements Clonable {
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
