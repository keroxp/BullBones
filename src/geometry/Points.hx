package geometry;
import performance.GeneralObjectPool;
import createjs.easeljs.Point;
class Points {
    public static function setValues (p: Point, x: Float, y: Float): Point {
        p.x = x; p.y = y; return p;
    }
    public static function distance (p: Point, s: Point): Float {
        return Math.sqrt(poweredDistance(p,s));
    }
    public static function poweredDistance(p: Point, s: Point): Float {
        return Math.pow(s.x-p.x,2)+Math.pow(s.y-p.y,2);
    }
    public static function createPool(size: Int): GeneralObjectPool<Point> {
        return new GeneralObjectPool(size, function () {
            return new Point();
        }, function (p) {
            p.x = p.y = 0;
        });
    }
}
