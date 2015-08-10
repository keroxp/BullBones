package geometry;
import protocol.Clonable;
class Point implements Clonable {
    public var x: Float;
    public var y: Float;
    public function new(?x: Float = 0, ?y: Float = 0) {
        this.x = x;
        this.y = y;
    }

    public function clone():Point {
        return new Point(x,y);
    }

    public function distance (p: Point): Float {
        return Math.sqrt(rawDistance(p));
    }
    public function rawDistance(p: Point): Float {
        return Math.pow(x-p.x,2)+Math.pow(y-p.y,2);
    }
}
