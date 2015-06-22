package figure;
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
import figure.Draggable.DraggableType;
import js.html.MouseEvent;
import createjs.easeljs.Bitmap;
class ImageFigure implements Draggable {
    public var bitmap: Bitmap;
    public var image(default,null): ImageWrap;

    @:isVar public var type(get, null):DraggableType;
    function get_type():DraggableType {
        return DraggableType.Image;
    }

    public static function fromUrl (dataurl: String): ImageFigure {
        var ret = new ImageFigure(dataurl);
        if (dataurl.substr(0,4) != "data") {
            throw new js.Error("dataUrl should be 'data' format, but got $dataurl");
        }
        ret.bitmap = new Bitmap(dataurl);
        ret.bitmap.cache(0,0,ret.bitmap.image.width,ret.bitmap.image.height);
        ret.bitmap.updateCache();
        return ret;
    }

    public static function fromImage (img: ImageElement): ImageFigure {
        var ret = new ImageFigure(img.src);
        ret.bitmap = new Bitmap(img);
        ret.bitmap.cache(0,0,img.width,img.height);
        ret.bitmap.updateCache();
        return ret;
    }

    private function new (src: String) {
        image = new ImageWrap(src);
    }

    public function onDragStart(e:MouseEventCapture):Void {
    }

    public function onDragMove(e:MouseEventCapture):Void {
        bitmap.x += e.deltaX;
        bitmap.y += e.deltaY;
    }

    public function onDragEnd(e:MouseEventCapture):Void {
    }

    @:isVar public var display(get, null): DisplayObject;
    function get_display():createjs.easeljs.DisplayObject {
        return bitmap;
    }

    public var filter(default, null):Filter;

    public function setFilterAsync(filter: Filter): Promise<ImageElement,Dynamic,Float> {
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
        this.bitmap.image.src = ImageUtil.toDataUrl(filter.applyToImageData(image.getImageData()));
        return pr;
    }

    function get_filter():Filter {
        return filter;
    }
}
