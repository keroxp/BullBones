package figure;
import recognition.Recognition;
import geometry.Vector2D;
import createjs.easeljs.Matrix2D;
import geometry.FuzzyPoint;
import geometry.Rect;
import createjs.easeljs.Shape;

class Figure {
    public function new(x: Float, y: Float) {
        addPoint(x,y);
    }
    // 図形を構成する点
    public var points(default, null): Array<FuzzyPoint> = new Array();
    // 描画につかうShape
    public var shape(default, null): Shape = new Shape();
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
        for (p in points) {
            var vx = px-p.x;
            var vy = py-p.y;
            m.identity();
            m.translate(vx,vy);
            m.scale(sx,sy);
            m.translate(-vx,-vy);
            m.transformPoint(p.x,p.y,p);
        }
        bounds = null;
        for (p in points) {
            calcBounds(p.x,p.y);
        }
        scaleX = sx;
        scaleY = sy;
        shape.graphics.clear();
        markAsDirtyAll();
    }
    private var isLine: Bool = false;
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
        if (points.length == 0) {
            points.push(new FuzzyPoint(x,y));
        } else {
            points.push(new FuzzyPoint(x,y,points[points.length-1]));
        }
        mDirtyFlags.push(true);
    }
    public function removePoint (i: Int) {
        points.remove(points[i]);
        mDirtyFlags.remove(mDirtyFlags[i]);
        markAsDirtyAll();
        resetBounds();
    }
    private function calcBounds (x: Float, y: Float) {
        if (bounds == null) bounds = new Rect(x,y,x,y);
        if (x < bounds.left) bounds.left = x;
        if (bounds.right < x) bounds.right = x;
        if (y < bounds.top) bounds.top = y;
        if (bounds.bottom < y) bounds.bottom = y;
    }
    private function resetBounds () {
        var l,t,r,b: Float = 0;
        var _bounds = new Rect();
        for (p in points) {
            if (p.x < _bounds.left) _bounds.left = p.x;
            if (_bounds.right < p.x) _bounds.right = p.x;
            if (p.y < _bounds.top) _bounds.top = p.y;
            if (_bounds.bottom < p.y) _bounds.bottom = p.y;
        }
        bounds = _bounds;
    }
    public function moveBy (dx: Float, dy: Float) {
        for (p in points) {
            p.x += dx;
            p.y += dy;
        }
        bounds.offset(dx,dy);
        shape.graphics.clear();
        markAsDirtyAll();
    }
    public function s2e (): Vector2D {
        var s = points[0];
        var e = points[points.length-1];
        return Vector2D.v(s,e);
    }
    private static var LINE_LENGTH_THRESH: Float = 150*150;
    private static var LINE_RECOGNIZE_THRESH = 20;
    public function render () {
        var i = 0;
        var s = points[0];
        var e = points[points.length-1];
        if (isLine || (s2e().rawPower() > LINE_LENGTH_THRESH
            && Recognition.line(cast points) < LINE_RECOGNIZE_THRESH))
        {
            if (!isLine) {
                isLine = true;
            }
            shape.graphics.clear();
            shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
            shape.graphics.moveTo(s.x,s.y);
            shape.graphics.lineTo(e.x,e.y);
        } else {
            renderPolygon();
        }
        shape.graphics.endStroke();
    }
    private function renderPolygon () {
        var s = points[0];
        shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
        shape.graphics.moveTo(s.x,s.y);
        for (i in 1...points.length-2) {
            var p = points[i];
            if (mDirtyFlags[i]) {
                var n = points[i+1];
                var c = (p.x+n.x)/2;
                var d = (p.y+n.y)/2;
                shape.graphics.quadraticCurveTo(p.x,p.y,c,d);
            } else {
                shape.graphics.moveTo(p.x,p.y);
            }
            mDirtyFlags[i] = false;
        }
    }
}
