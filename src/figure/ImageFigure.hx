package figure;
import util.StringUtil;
import util.Log;
import createjs.easeljs.DisplayObject;
import cv.ImageWrap;
import deferred.Deferred;
import deferred.Promise;
import event.MouseEventCapture;
import hammer.HammerEvent;
import js.html.ImageElement;
import cv.ImageUtil;
import cv.Filter;
import cv.FilterFactory;
import js.html.CanvasElement;
import js.html.ImageData;
import js.html.MouseEvent;
import createjs.easeljs.Bitmap;
class ImageFigure extends Bitmap {
    public var imageWrap(default,null): ImageWrap;
    public function new (img: ImageWrap) {
        super(cast img.image.cloneNode(true));
        imageWrap = img;
    }

    override public function clone(): ImageFigure {
        var ret = new ImageFigure(imageWrap.clone());
        var _clone = Reflect.field(this, "_cloneProps");
        return Reflect.callMethod(this,_clone,[ret]);
    }

    override function toString(): String {
        return '[ImageFigure name="$name"]';
    }

    public var filter(default, null):Filter;

    public function setFilterAsync(filter: Filter): Promise<ImageElement,Dynamic,Float> {
        this.filter = filter;
        var pr = new Deferred<ImageElement,Dynamic,Float>();
        this.image.onload = function (e) {
            var w = this.image.width;
            var h = this.image.height;
            this.cache(0,0,w,h);
            this.updateCache();
            pr.resolve(this.image);
        };
        this.image.onerror = function (e) {
            pr.reject(e);
        };
        var filterd = filter.applyToImageData(imageWrap.getImageData());
        this.image.src = ImageUtil.toDataUrl(filterd);
        return pr;
    }

    function get_filter():Filter {
        return filter;
    }
}
