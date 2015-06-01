package figure;
import recognition.Recognition;
import createjs.easeljs.Point;
import geometry.Vector2D;
import createjs.easeljs.Matrix2D;
import geometry.FuzzyPoint;
import geometry.Rect;
import createjs.easeljs.Shape;

class Vertex {
    public var point: FuzzyPoint;
    public var radian: Float;
    public function new (?p: FuzzyPoint = null, ?rad: Float = -1) {
        point = p;
        radian = rad;
    }
}
class Figure {
    public function new(x: Float, y: Float) {
        addPoint(x,y);
    }
    // 図形を構成する点
    public var points(default, null): Array<FuzzyPoint> = new Array();
    // 頂点っぽい点
    public var vertexes(default, null): Array<Vertex> = new Array();
    // 描画につかうShape
    public var shape(default, null): Shape = new Shape();
    // 再描画フラグ
    public var isDirty: Bool;
    // 色
    public var color(default, set): String = "#000000";
    function set_color (c) {
        color = c;
        shape.graphics.clear();
        isDirty = true;
        return color;
    }
    // 描画の点の半径
    public var width(default, set): Float = 2;
    function set_width (r: Float) {
        width = r;
        shape.graphics.clear();
        isDirty = true;
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
        isDirty = true;
    }
    // 描画中か？
    public var isDrawing: Bool = true;
    // 直線フラグ
    private var isLine: Bool = false;
    //　デバッグ中？
    public var isDebug: Bool = true;
    // 閉じているか
    private static var CLOSE_THRESH: Float = 20*20;
    public function getClosedPoint (): Point {
        var last = points.length-1;
        for (i in 0...2) {
            for (j in last-2...last) {
                 if (points[i].rawDistance(points[j]) < CLOSE_THRESH) {
                     return new Point(
                        (points[i].x+points[j].x)/2,
                        (points[i].y+points[j].y)/2
                     );
                 }
            }
        }
        return null;
    }
    // 頂点っぽい点を見つける
    public function calcVertexes () {
        if (points.length > 2) {
            var i = 1;
            while (i < points.length-2) {
                var cur = points[i];
                var prev = points[i-1];
                var next = points[i+1];
                var a = Vector2D.v(points[i],points[i+1]);
                var b = Vector2D.v(points[i-1],points[i]);//
                var cos = a.dot(b)/(a.power()*b.power());
                var rad = Math.acos(cos);
//                trace(rad);
                if (PI_4_5 < rad && rad < PI_1_5) {
                    var vtx = new Vertex(cur,rad);
                    var THRESH = 10*10;
                    var isFirst = vertexes.length == 0;
                    var isFarFromPrev = !isFirst && vertexes[vertexes.length-1].point.rawDistance(cur) > THRESH;
                    var isFarFromStart= points[0].rawDistance(cur) > THRESH;
                    var isFarFromEnd = points[points.length-1].rawDistance(cur) > THRESH;
                    if (isFarFromStart && isFarFromEnd && (isFirst || isFarFromPrev)) {
                        vertexes.push(vtx);
                    }
                }
                i++;
            }
        }
    }
    private static var PI_1_5 = Math.PI/1.5;
    private static var PI_2 = Math.PI/2;
    private static var PI_2_5 = Math.PI/2.5;
    private static var PI_3 = Math.PI/3;
    private static var PI_3_5 = Math.PI/3.5;
    private static var PI_4 = Math.PI/4;
    private static var PI_4_5 = Math.PI/4.5;
    public var mDirtyPoints: Array<Int> = new Array();
    public function addPoint (x: Float, y: Float) {
        calcBounds(x,y);
        if (points.length == 0) {
            points.push(new FuzzyPoint(x,y));
        } else {
            var fp = new FuzzyPoint(x,y,points[points.length-1]);
            // 同じ位置は追加しない
            if (fp.rawDistance(points[points.length-1]) > 0) {
                points.push(fp);
                mDirtyPoints.push(points.length-1);
            }
        }
        isDirty = true;
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
        isDirty = true;
    }
    public function s2e (): Vector2D {
        var s = points[0];
        var e = points[points.length-1];
        return Vector2D.v(s,e);
    }
    private static var LINE_LENGTH_THRESH: Float = 150*150;
    private static var LINE_RECOGNIZE_THRESH = 20;
    public function render () {
        if (points.length < 2) return;
        var i = 0;
        var s = points[0];
        var e = points[points.length-1];
//        if (isLine || (s2e().rawPower() > LINE_LENGTH_THRESH
//            && Recognition.line(cast points) < LINE_RECOGNIZE_THRESH))
//        {
//            if (!isLine) {
//                isLine = true;
//            }
//            shape.graphics.clear();
//            shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
//            shape.graphics.moveTo(s.x,s.y);
//            shape.graphics.lineTo(e.x,e.y);
//        } else {
            renderPolygon();
//        }
        shape.graphics.endStroke();
    }
    private function renderPolygon () {
        var s = points[0];
        var e = points[points.length-1];
        if (isDrawing && mDirtyPoints.length > 0) {
            var ds = points[mDirtyPoints[0]-1];
            shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
            shape.graphics.moveTo(ds.x,ds.y);
            for (i in mDirtyPoints) {
                var dp = points[i];
                shape.graphics.lineTo(dp.x,dp.y);
            }
            mDirtyPoints = new Array();
        } else {
            shape.graphics.clear();
            shape.graphics.setStrokeStyle(width,"round").beginStroke(color);
            shape.graphics.moveTo(s.x,s.y);
            drawMovingAverage();
        }
        shape.graphics.endStroke();
        if (!isDrawing) {
            if (isDebug) {
                shape.graphics
                .beginFill("blue")
                .drawCircle(s.x,s.y,3)
                .drawCircle(e.x,e.y,3)
                .endFill();
                for (v in vertexes) {
                    shape.graphics.setStrokeStyle(3).beginStroke("red");
                    shape.graphics.drawCircle(v.point.x,v.point.y,5);
                    shape.graphics.endStroke();
                }
                var cp = getClosedPoint();
                if (cp != null) {
                    shape.graphics.setStrokeStyle(3).beginStroke("pink");
                    shape.graphics.drawCircle(cp.x,cp.y,5);
                    shape.graphics.endStroke();
                }
            }
        }
    }
    private function drawQuadraticCurve () {
        for (i in 1...points.length-2) {
            var p = points[i];
            var n = points[i+1];
            var c = (p.x+n.x)/2;
            var d = (p.y+n.y)/2;
            shape.graphics.quadraticCurveTo(p.x,p.y,c,d);
        }
    }
    public var supplementLength = 5;
    private function drawMovingAverage () {
        // 平均係数
        var m = supplementLength;
        var i = m-1;
        while (i < points.length) {
            var avp = new Point();
            var seg: Array<FuzzyPoint> = points.slice(i-m+1,i+1);
            for (p in seg){
                avp.x += p.x;
                avp.y += p.y;
            }
            avp.x = avp.x/m;
            avp.y = avp.y/m;
            shape.graphics.lineTo(avp.x,avp.y);
            i++;
        }
        var e = points[points.length-1];
        shape.graphics.lineTo(e.x,e.y);
    }
}
