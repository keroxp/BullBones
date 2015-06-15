package figure;
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
import figure.Draggable.DraggableType;
import js.html.MouseEvent;
import geometry.Rect;
import createjs.easeljs.Bitmap;
class ImageFigure implements Draggable {
    public var bitmap: Bitmap;
    public var src(default,null): String;
    public var thumbSrc: String;
    public var orgCache: ImageData;

    @:isVar public var type(get, null):DraggableType;
    function get_type():DraggableType {
        return DraggableType.Image;
    }

    @:isVar public var bounds(get,null): Rect;
    function get_bounds(): Rect {
        return new Rect(bitmap.x,bitmap.y,bitmap.x+bitmap.image.width,bitmap.y+bitmap.image.height);
    }

    public static function fromUrl (dataurl: String): ImageFigure {
        var ret = new ImageFigure();
        ret.src = dataurl;
        ret.thumbSrc = dataurl;
        ret.bitmap = new Bitmap(dataurl);
        return ret;
    }

    public static function fromImage (img: ImageElement): ImageFigure {
        var ret = new ImageFigure();
        ret.src = img.src;
        ret.thumbSrc = img.src;
        ret.bitmap = new Bitmap(img);
        return ret;
    }

    private function new () {}

    public function onDragStart(e:MouseEventCapture):Void {
        bitmap.cache(0,0,bitmap.image.width,bitmap.image.height);
    }

    public function onDragMove(e:MouseEventCapture):Void {
        bitmap.x += e.deltaX;
        bitmap.y += e.deltaY;
    }

    public function onDragEnd(e:MouseEventCapture):Void {
    }

    @:isVar public var display(get, null):createjs.easeljs.DisplayObject;
    function get_display():createjs.easeljs.DisplayObject {
        return bitmap;
    }

    public var filter(default, null):Filter;

    public function setFilterAsync(filter: Filter): Promise<ImageElement,Dynamic,Float> {
        if (orgCache == null) {
            orgCache = ImageUtil.getImageData(bitmap.image);
        }
        this.filter = filter;
        var pr = new Deferred<ImageElement,Dynamic,Float>();
        this.bitmap.image.onload = function (e) {
            var w = this.bitmap.image.width;
            var h = this.bitmap.image.height;
            this.bitmap.cache(0,0,w,h);
            this.bitmap.updateCache();
            pr.resolve(this.bitmap.image);
        };
        this.bitmap.image.onerror = function (e) {
            pr.reject(e);
        };
        this.bitmap.image.src = ImageUtil.toDataUrl(filter.applyToImageData(orgCache));
        return pr;
    }

    function get_filter():Filter {
        return filter;
    }

}
