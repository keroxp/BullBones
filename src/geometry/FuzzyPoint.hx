package geometry;
import performance.Poolable;
class FuzzyPoint extends Point {
    public var timestamp(default, null): Date;
    public var prev(default,null): FuzzyPoint;
    public var velocity(default, null): Float = 0;
    function get_velocity():Float {
        if (prev != null) {
            var d = timestamp.getTime()-prev.timestamp.getTime();
            return distance(prev)*100/d; // ms
        }
        return 0;
    }
    override public function clone(): FuzzyPoint {
        var ret = new FuzzyPoint(x,y,prev);
        ret.timestamp = timestamp;
        return ret;
    }
    public function new(x: Float, y: Float, ?prev: FuzzyPoint = null) {
        super(x,y);
        this.timestamp = Date.now();
        this.prev = prev;
    }

    override public function recycle():Void {
        timestamp = null;
        prev = null;
        velocity = 0;
    }

}
