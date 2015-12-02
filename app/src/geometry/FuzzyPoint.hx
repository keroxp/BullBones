package geometry;
import protocol.Clonable;
import createjs.easeljs.Point;
using geometry.Points;

class FuzzyPoint extends Point implements Clonable {
    public var timestamp(default, null): Date;
    public var prev(default,null): FuzzyPoint;
    // speed between the previous
    @:isVar public var speed(default, null): Float = 0;
    function get_speed():Float {
        if (prev != null) {
            var d = timestamp.getTime()-prev.timestamp.getTime();
            return this.distance(prev)*100/d; // ms
        }
        return 0;
    }
    override public function clone(): FuzzyPoint {
        var ret = new FuzzyPoint(x,y,prev);
        ret.timestamp = timestamp;
        return ret;
    }
    public function new(x: Float, y: Float, prev: FuzzyPoint = null) {
        super(x,y);
        this.timestamp = Date.now();
        this.prev = prev;
    }
}
