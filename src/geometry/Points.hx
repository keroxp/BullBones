package geometry;
import createjs.easeljs.Point;
class Points {
    public static function setValues (p: Point, x: Float, y: Float): Point {
        p.x = x; p.y = y; return p;
    }
    public static function distance (p: Point, s: Point): Float {
        return Math.sqrt(rawDistance(p,s));
    }
    public static function rawDistance(p: Point, s: Point): Float {
        return Math.pow(s.x-p.x,2)+Math.pow(s.y-p.y,2);
    }
}
