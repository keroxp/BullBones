package util;
import createjs.easeljs.Rectangle;
import geometry.Point;
using util.RectangleUtil;
class RectangleUtil {
    public static function center (rect: Rectangle): Point {
        return new Point(rect.x+rect.width/2,rect.y+rect.height/2);
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
}
