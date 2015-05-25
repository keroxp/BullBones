package geometry;
class FuzzyPoint extends Point{
    public var timestamp(default, null): Date;
    public var velocity(default, null): Float = 0;
    public function new(x: Float, y: Float, ?prev: FuzzyPoint = null) {
        super(x,y);
        timestamp = Date.now();
        if (prev != null) {
            var d = timestamp.getTime()-prev.timestamp.getTime();
            velocity = distance(prev)/d;
        }
    }
}
