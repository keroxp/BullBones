package util;
import createjs.easeljs.Rectangle;
import createjs.easeljs.DisplayObject;
class CreateJSExt {
    public static function getRight<T: DisplayObject>(d: T): Float {
        return d.x + getWidth(d);
    }
    public static function getBottom<T: DisplayObject>(d: T): Float {
        return d.y + getHeight(d);
    }
    public static function getWidth<T : DisplayObject>(d: T): Float {
        return d.getTransformedBounds().width;
    }
    public static function getHeight<T : DisplayObject>(d: T): Float {
        return d.getTransformedBounds().height;
    }
    public static function setWidth<T : DisplayObject>(d: T,w: Float): Rectangle {
        return setSize(d,w,getHeight(d));
    }
    public static function setHeight<T : DisplayObject>(d: T,h: Float): Rectangle {
        return setSize(d,getWidth(d),h);
    }
    public static function setSize<T : DisplayObject>(d: T,w: Float, h :Float): Rectangle {
        var b = d.getBounds();
        d.setBounds(b.x,b.y,w,h);
        return d.getBounds();
    }
    public static function extendBounds<T : DisplayObject>(d: T, x: Float, y: Float, w: Float = 0, h: Float = 0) : Rectangle {
        var b = d.getBounds().clone();
        b.extend(x,y,w,h);
        return setSize(d,b.width,b.height);
    }
}
