package util;
import createjs.easeljs.Point;
import util.RectangleUtil;
import createjs.easeljs.Rectangle;
using util.RectangleUtil;
class RectangleUtil {
    public static function center (rect: Rectangle, ?pt: Point): Point {
        if (pt == null) {
            pt = new Point();
        }
        pt.x = rect.x+rect.width/2;
        pt.y = rect.y+rect.height/2;
        return pt;
    }
    public static function intersects (r1: Rectangle, r2: Rectangle): Bool {
        return containsPoint(r1,r2.x,r2.y)
            || containsPoint(r1,r2.right(),r2.y)
            || containsPoint(r1,r2.x,r2.bottom())
            || containsPoint(r1,r2.right(),r2.bottom());
    }
    public inline static function right (r: Rectangle): Float return r.x+r.width;
    public inline static function bottom(r: Rectangle): Float return r.y+r.height;
    public static function contains (r1: Rectangle, r2: Rectangle): Bool {
        return containsPoint(r1,r2.x,r2.y)
                && containsPoint(r1,right(r2),r2.y)
                && containsPoint(r1,r2.x,bottom(r2))
                && containsPoint(r1,r2.right(),r2.bottom());
    }
    public static function containsPoint (r: Rectangle, x: Float, y: Float): Bool {
        return r.x <= x && x <= r.right() && r.y <= y && y <= r.bottom();
    }
    public static function scale (r: Rectangle, scaleX: Float, scaleY: Float): Rectangle {
        r.width *= scaleX;
        r.height *= scaleY;
        return r;
    }
    public static function reset(r: Rectangle): Rectangle {
        return r.setValues(0,0,0,0);
    }
    public static function padAll(r: Rectangle, pad: Float): Rectangle {
        return r.pad(pad,pad,pad,pad);
    }
    private inline static function call(o: Dynamic, method: String, args: Array<Dynamic>): Dynamic {
        return Reflect.callMethod(o, Reflect.field(o, method), args);
    }
    public static function setValues(r: Rectangle, x: Float = 0, y: Float = 0,width: Float = 0, height: Float = 0): Rectangle {
        return call(r,"setValues", [x,y,width,height]);
    }
    public static function extendWithRect(r: Rectangle, s: Rectangle): Rectangle {
        return r.extend(s.x,s.y,s.width,s.height);
    }
}
