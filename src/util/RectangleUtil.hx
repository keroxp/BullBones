package util;
import util.RectangleUtil;
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
    public static function scale (r: Rectangle, scaleX: Float, scaleY: Float): Rectangle {
        var ret = r.clone();
        ret.width *= scaleX;
        ret.height *= scaleY;
        return ret;
    }
    public static function reset(r: Rectangle) {
        r.x = r.y = r.width = r.height = 0;
    }
    private inline static function call(o: Dynamic, method: String, args: Array<Dynamic>): Dynamic {
        return Reflect.callMethod(o, Reflect.field(o, method), args);
    }
    public static function extend(r: Rectangle, x: Float, y:Float, width: Float = 0, height:Float = 0):Rectangle {
        return call(r,"extend",[x,y,width,height]);
    }
    public static function pad(r: Rectangle, top: Float = 0, left: Float = 0, bottom: Float = 0, right: Float = 0):Rectangle {
        return call(r,"pad",[top,left,bottom,right]);
    }
    public static function union(r: Rectangle, rect: Rectangle):Rectangle {
        return call(r,"union",[rect]);
    }
    public static function intersection(r: Rectangle, rect: Rectangle):Rectangle {
        return call(r,"intersection",[rect]);
    }
    public static function isEmpty(r: Rectangle): Bool {
        return call(r,"isEmpty",[]);
    }
    public static function setValues(r: Rectangle, x: Float = 0, y: Float = 0,width: Float = 0, height: Float = 0): Rectangle {
        return call(r,"setValues", [x,y,width,height]);
    }
}
