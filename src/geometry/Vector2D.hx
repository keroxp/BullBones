package geometry;
import performance.GeneralObjectPool;
import createjs.easeljs.Point;
import performance.Poolable;
class Vector2D implements Poolable {
    public var dx: Float;
    public var dy: Float;
    static public function createPool(size: Int): GeneralObjectPool<Vector2D> {
        return new GeneralObjectPool<Vector2D>(size, function() {
            return new Vector2D();
        }, function (v: Vector2D) {
            v.dx = v.dy = 0;
        });
    }
    public function new(dx: Float = 0, dy: Float = 0) {
        set(dx,dy);
    }
    public static function v(from :Point, to:Point): Vector2D {
        return new Vector2D(to.x-from.x,to.y-from.y);
    }
    public function set(dx: Float, dy: Float): Vector2D {
        this.dx = dx;
        this.dy = dy;
        return this;
    }
    public function dot (vec: Vector2D): Float {
        return dx*vec.dx + dy*vec.dy;
    }
    public function cross(vec: Vector2D): Float {
        return dx*vec.dy-vec.dx*dy;
    }
    public function add (vec: Vector2D): Vector2D {
        return new Vector2D(dx+vec.dx,dy+vec.dy);
    }
    public function sub (vec: Vector2D): Vector2D {
        return new Vector2D(dx-vec.dx,dy-vec.dy);
    }
    public function power (): Float {
        return Math.sqrt(rawPower());
    }
    public function rawPower (): Float {
        return Math.pow(dx,2) + Math.pow(dy,2);
    }
    public function multiply (a: Float, ?vec: Vector2D): Vector2D {
        var ret = vec;
        if (ret == null) {
            ret = new Vector2D();
        }
        return ret.set(dx*a,dy*a);
    }
    public function unit (?vec: Vector2D): Vector2D {
        var ret = vec;
        if (vec == null) {
            ret = new Vector2D();
        }
        return multiply(1/power(), ret);
    }
    static var PI_2 = Math.PI*.5;
    public function normalize(?vec: Vector2D): Vector2D {
        var ret = vec;
        if (ret == null) {
            vec = new Vector2D();
        }
        return ret.set(
            dx*Math.cos(PI_2) - dy*Math.sin(PI_2),
            dx*Math.sin(PI_2) + dy*Math.cos(PI_2)
        ).unit(ret);
    }

    public function recycle():Void {
        dx = dy = 0;
    }

}
