package figure;
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

    public function new (img: ImageWrap) {
        image = img;
        bitmap = new Bitmap(cast img.image.cloneNode(true));
    }

    public function clone(): ImageFigure {
        return new ImageFigure(image.clone());
    }

    @:isVar public var display(get, null): DisplayObject;
    function get_display():createjs.easeljs.DisplayObject {
        return bitmap;
    }

    public function render(?arg:Dynamic): ImageFigure {
        return this;
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
        var filterd = filter.applyToImageData(image.getImageData());
        this.bitmap.image.src = ImageUtil.toDataUrl(filterd);
        return pr;
    }

    function get_filter():Filter {
        return filter;
    }
}
