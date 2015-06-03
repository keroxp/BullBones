package figure;
import js.html.MouseEvent;
import geometry.Rect;
import createjs.easeljs.Bitmap;
class Image implements Draggable {
    private var mBitmap: Bitmap;
    public var src(default,null): String;
    private var mWidth: Int;
    private var mHeight: Int;
    public var bounds(get,null): Rect;
    function get_bounds(): Rect {
        return new Rect(mBitmap.x,mBitmap.y,mBitmap.x+mWidth,mBitmap.y+mHeight);
    }
    public function new(src: String, w: Int, h: Int) {
        this.src = src;
        mWidth = w;
        mHeight = h;
        mBitmap = new Bitmap(src);
    }

    public function onDragStart(e:MouseEvent):Void {
    }

    public function onDragMove(e:MouseEvent):Void {
        mBitmap.x += e.movementX;
        mBitmap.y += e.movementY;
    }

    public function onDragEnd(e:MouseEvent):Void {
    }

    @:isVar public var display(get, null):createjs.easeljs.DisplayObject;
    function get_display():createjs.easeljs.DisplayObject {
        return mBitmap;
    }

}
