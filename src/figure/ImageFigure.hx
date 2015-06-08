package figure;
import js.html.ImageElement;
import cv.ImageUtil;
import cv.Filter;
import cv.FilterFactory;
import js.html.CanvasElement;
import js.html.ImageData;
import geometry.MouseEventCapture;
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

    public function new(img: ImageElement) {
        this.src = img.src;
        this.thumbSrc = src;
        bitmap = new Bitmap(src);
    }

    private var mCapture: MouseEventCapture = new MouseEventCapture();
    public function onDragStart(e:MouseEvent):Void {
        bitmap.cache(0,0,bitmap.image.width,bitmap.image.height);
        mCapture.down(e);
    }

    public function onDragMove(e:MouseEvent):Void {
        bitmap.x += mCapture.getMoveX(e);
        bitmap.y += mCapture.getMoveY(e);
        mCapture.move(e);
    }

    public function onDragEnd(e:MouseEvent):Void {
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
