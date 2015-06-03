package geometry;
class Rect {
    public var left: Float;
    public var top: Float;
    public var right: Float;
    public var bottom: Float;
    public function new(?left: Float = 0, ?top: Float = 0, ?right: Float = 0, ?bototm: Float = 0) {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bototm;
    }
    public function width () return right-left;
    public function height () return bottom-top;
    public function center (): Point return new Point((left+right)/2,(top+bottom)/2);
    public function offset (dx: Float, dy: Float) {
        this.left += dx;
        this.top += dy;
        this.right += dx;
        this.bottom += dy;
    }
    public function intersects (r: Rect): Bool {
        return containsPoint(r.left,r.top)
            || containsPoint(r.right,r.top)
            || containsPoint(r.left,r.bottom)
            || containsPoint(r.right,r.bottom);
    }
    public function contains (r: Rect): Bool {
        return containsPoint(r.left,r.top)
                && containsPoint(r.right,r.top)
                && containsPoint(r.left,r.bottom)
                && containsPoint(r.right,r.bottom);
    }
    public function containsPoint (x: Float, y: Float): Bool {
        return left < x && x < right && top < y && y < bottom;
    }
}
