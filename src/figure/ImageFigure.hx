package figure;
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

    private var mCapture: MouseEventCapture = new MouseEventCapture();
    public function onDragStart(e:HammerEvent):Void {
        bitmap.cache(0,0,bitmap.image.width,bitmap.image.height);
        mCapture.down(e);
    }

    public function onDragMove(e:HammerEvent):Void {
        bitmap.x += mCapture.getMoveX(e);
        bitmap.y += mCapture.getMoveY(e);
        mCapture.move(e);
    }

    public function onDragEnd(e:HammerEvent):Void {
        mCapture.up(e);
    }

    @:isVar public var display(get, null):createjs.easeljs.DisplayObject;
    function get_display():createjs.easeljs.DisplayObject {
        return bitmap;
    }

    @:isVar public var filter(get, set):Filter;

    function set_filter(value:Filter) {
        if (orgCache == null) {
            orgCache = ImageUtil.getImageData(bitmap.image);
        }
        var out = value.applyToImageData(orgCache);
        this.bitmap.image.src = ImageUtil.toDataUrl(out, "image/png");
        this.bitmap.cache(0,0,out.width,out.height);
        this.bitmap.updateCache();
        return this.filter = value;
    }

    function get_filter():Filter {
        return filter;
    }

}
