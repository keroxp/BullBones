package geometry;
class Vector2D {
    public var dx: Float;
    public var dy: Float;
    public function new(?dx: Float = 0, ?dy: Float = 0) {
        this.dx = dx;
        this.dy = dy;
    }
    public static function v(from :Point, to:Point): Vector2D {
        return new Vector2D(to.x-from.x,to.y-from.y);
    }
    public function dot (v: Vector2D): Float {
        return dx*v.dx + dy*v.dy;
    }
    public function add (v: Vector2D): Vector2D {
        return new Vector2D(dx+v.dx,dy+v.dy);
    }
    public function sub (v: Vector2D): Vector2D {
        return new Vector2D(dx-v.dx,dy-v.dy);
    }
    public function power (): Float {
        return Math.sqrt(rawPower());
    }
    public function rawPower (): Float {
        return Math.pow(dx,2) + Math.pow(dy,2);
    }
    public function multiply (a: Float): Vector2D {
        return new Vector2D(dx*a,dy*a);
    }
    public function normalize (): Vector2D {
        return multiply(power());
    }
}
