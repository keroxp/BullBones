package ;
import createjs.easeljs.Matrix2D;
import geometry.FuzzyPoint;
import geometry.Rect;
import createjs.easeljs.Shape;

class Figure {
    public function new(x: Float, y: Float) {
        addPoint(x,y);
    }
    // 図形を構成する点
    @:protected var mPoints: Array<FuzzyPoint> = new Array();
    // 描画につかうShape
    public var shape(default, null): Shape = new Shape();
    function get_shape() return shape;
    @:protected var mDirtyFlags: Array<Bool> = new Array();
    // 色
    public var color(default, set): String = "#000000";
    function set_color (c) {
        color = c;
        shape.graphics.clear();
        markAsDirtyAll();
        return color;
    }
    // 描画の点の半径
    public var width(default, set): Float = 2;
    function set_width (r: Float) {
        width = r;
        shape.graphics.clear();
        markAsDirtyAll();
        return width;
    }
    // bounds
    public var bounds(default, null): Rect;
    function get_bounds () return bounds;
    public var scaleX(default, null): Float = 1.0;
    public var scaleY(default, null): Float = 1.0;
    public function setScale (sx: Float, sy: Float, px: Float, py: Float) {
        var m = new Matrix2D();
        for (p in mPoints) {
            var vx = px-p.x;
            var vy = py-p.y;
            m.identity();
            m.translate(vx,vy);
            m.scale(sx,sy);
            m.translate(-vx,-vy);
            m.transformPoint(p.x,p.y,p);
        }
        bounds = null;
        for (p in mPoints) {
            calcBounds(p.x,p.y);
        }
        scaleX = sx;
        scaleY = sy;
        shape.graphics.clear();
        markAsDirtyAll();
    }
    // 再描画フラグ
    public function markAsDirtyAll() {
        for (i in 0...mDirtyFlags.length-1) {
            markAsDirty(i);
        }
    }
    public function markAsDirty(index: Int) {
        mDirtyFlags[index] = true;
    }
    public function addPoint (x: Float, y: Float) {
        calcBounds(x,y);
        if (mPoints.length == 0) {
            mPoints.push(new FuzzyPoint(x,y));
        } else {
            mPoints.push(new FuzzyPoint(x,y,mPoints[mPoints.length-1]));
        }
        mDirtyFlags.push(true);
    }
    private function calcBounds (x: Float, y: Float) {
        if (bounds == null) bounds = new Rect(x,y,x,y);
        if (x < bounds.left) bounds.left = x;
        if (bounds.right < x) bounds.right = x;
        if (y < bounds.top) bounds.top = y;
        if (bounds.bottom < y) bounds.bottom = y;
    }
    public function moveBy (dx: Float, dy: Float) {
        for (p in mPoints) {
            p.x += dx;
            p.y += dy;
        }
        bounds.offset(dx,dy);
        shape.graphics.clear();
        markAsDirtyAll();
    }
    public function render () {
        var i = 0;
        var s = mPoints[0];
        shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
        shape.graphics.moveTo(s.x,s.y);
        for (i in 1...mPoints.length-2) {
            var p = mPoints[i];
            if (mDirtyFlags[i]) {
                var n = mPoints[i+1];
                var c = (p.x+n.x)/2;
                var d = (p.y+n.y)/2;
                shape.graphics.quadraticCurveTo(p.x,p.y,c,d);
            } else {
                shape.graphics.moveTo(p.x,p.y);
            }
            mDirtyFlags[i] = false;
        }
        shape.graphics.endStroke();
    }
}
