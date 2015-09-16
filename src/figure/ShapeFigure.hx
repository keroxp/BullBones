package figure;

import util.BrowserUtil;
import geometry.Vertex;
import createjs.easeljs.Rectangle;
import createjs.easeljs.Point;
import geometry.Vector2D;
import geometry.FuzzyPoint;
import createjs.easeljs.Shape;
using util.RectangleUtil;

class ShapeFigure extends Shape {
    // 図形を構成する点（スケールは反映されてない）
    public var points(default, null): Array<FuzzyPoint> = new Array<FuzzyPoint>();
    // 図形を構成する点（スケール反映済み）
    public var transformedPoints(default, null) : Array<FuzzyPoint> = new Array<FuzzyPoint>();
    // 頂点っぽい点
    public var vertexes(default, null): Array<Vertex> = new Array<Vertex>();
    // 補完係数
    public var supplementLength = 5;
    // 直線フラグ
    private var isLine: Bool = false;
    // 図形のbounds
    private var mBounds: Rectangle;
    // 内部的なスケール値
    public var shapeScaleX(default,null): Float = 1.0;
    public var shapeScaleY(default,null): Float = 1.0;
    // 色
    public var color: String = "#000000";
    // 描画の点の半径
    public var width: Float = 2;

    public function new(x: Float, y: Float) {
        super();
        addPoint(x,y);
    }

    override public function clone(): ShapeFigure {
        var ret = new ShapeFigure(points[0].x,points[0].y);
        ret.points = points.map(function(p: FuzzyPoint) { return p.clone(); });
        ret.transformedPoints = transformedPoints.map(function(p: FuzzyPoint) { return p.clone(); });
        ret.vertexes = vertexes.map(function(vtx: Vertex) { return vtx.clone(); });
        ret.shapeScaleX = shapeScaleX;
        ret.shapeScaleY = shapeScaleY;
        ret.color = color;
        ret.width = width;
        ret.supplementLength = supplementLength;
        ret.isLine = isLine;
        ret.mBounds = mBounds.clone();
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this, _clone,[ret]);
        // easeljs.DisplayObject#cloneはboundsをdeep copyしないので自前で上書きする
        Reflect.setField(ret, "_bounds", getBounds().clone());
        return ret.render();
    }

    public override function toString(): String {
        return '[ShapeFigure id="${id}"]';
    }

    private static var CLOSE_THRESH: Float = 20*20;
    public function getClosedPoint (): Point {
        var last = transformedPoints.length;
        var pts = transformedPoints;
        for (i in 0...2) {
            for (j in last-2...last) {
                 if (pts[i].rawDistance(pts[j]) < CLOSE_THRESH) {
                     return new Point(
                        (pts[i].x+pts[j].x)/2,
                        (pts[i].y+pts[j].y)/2
                     );
                 }
            }
        }
        return null;
    }
    // 頂点っぽい点を見つける
    public function calcVertexes () {
        var pts = transformedPoints;
        vertexes = [];
        if (pts.length > 2) {
            var i = 1;
            while (i < pts.length-2) {
                var cur = pts[i];
                var prev = pts[i-1];
                var next = pts[i+1];
                var a = Vector2D.v(pts[i],pts[i+1]);
                var b = Vector2D.v(pts[i-1],pts[i]);//
                var cos = a.dot(b)/(a.power()*b.power());
                var rad = Math.acos(cos);
                if (PI_4_5 < rad && rad < PI_1_5) {
                    var vtx = new Vertex(cur,rad);
                    var THRESH = 10*10;
                    var isFirst = vertexes.length == 0;
                    var isFarFromPrev = !isFirst && vertexes[vertexes.length-1].point.rawDistance(cur) > THRESH;
                    var isFarFromStart= pts[0].rawDistance(cur) > THRESH;
                    var isFarFromEnd = pts[pts.length-1].rawDistance(cur) > THRESH;
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
    public function addPoint (x: Float, y: Float) {
        calcBounds(x,y);
        if (points.length == 0) {
            var fp = new FuzzyPoint(x,y);
            points.push(fp);
            transformedPoints.push(fp);
        } else {
            var fp = new FuzzyPoint(x,y,points[points.length-1]);
            // 同じ位置は追加しない
            if (fp.rawDistance(points[points.length-1]) > 0) {
                points.push(fp);
                transformedPoints.push(fp);
            }
        }
    }
    private function calcBounds (x: Float, y: Float) {
        if (mBounds == null) {
            mBounds = new Rectangle(x,y,0,0);
        }
        if (x < mBounds.x) {
            mBounds.width += mBounds.x-x;
            mBounds.x = x;
        }
        if (mBounds.right() < x){
            mBounds.width = x-mBounds.x;
        }
        if (y < mBounds.y) {
            mBounds.height += mBounds.y - y;
            mBounds.y = y;
        }
        if (mBounds.bottom() < y) {
            mBounds.height = y-mBounds.y;
        }
        setBounds(0,0,mBounds.width,mBounds.height);
    }
    private function resetBounds () {
        var l = points[0].x;
        var t = points[0].y;
        var r = l;
        var b = t;
        for (p in points) {
            if (p.x < l) l = p.x;
            if (r < p.x) r = p.x;
            if (p.y < t) t = p.y;
            if (b < p.y) b = p.y;
        }
        setBounds(0,0,r-l,b-t);
    }
    public function s2e (): Vector2D {
        var s = points[0];
        var e = points[points.length-1];
        return Vector2D.v(s,e);
    }
    private static var LINE_LENGTH_THRESH: Float = 150*150;
    private static var LINE_RECOGNIZE_THRESH = 20;

    public function applyScale(sx: Float, sy: Float): ShapeFigure {
        // apply scale
        var px = mBounds.x;
        var py = mBounds.y;
        transformedPoints = points.map(function(p: FuzzyPoint) {
            var tp = p.clone();
            tp.x = (p.x-px)*sx+px;
            tp.y = (p.y-py)*sy+py;
            return tp;
        });
        calcVertexes();
        mBounds.width *= sx/shapeScaleX;
        mBounds.height *= sy/shapeScaleY;
        shapeScaleX = sx;
        shapeScaleY = sy;
        setBounds(0,0,mBounds.width,mBounds.height);
        scaleX = scaleY = 1.0;
        return this;
    }

    private inline function xx(x: Float): Float return x-mBounds.x;
    private inline function yy(y: Float): Float return y-mBounds.y;
    private var isFirstRendering = true;
    public function render (): ShapeFigure {
        if (points.length < 2) return this;
        // render
        var s = transformedPoints[0];
        var e = transformedPoints[transformedPoints.length-1];
        var dpr = BrowserUtil.window.devicePixelRatio;
        graphics.clear();
        graphics.setStrokeStyle(width*dpr,"round",1).beginStroke(color);
        graphics.moveTo(xx(s.x),yy(s.y));
        if (Main.App.model.brush.supplemnt) {
            // 平均係数
            var m = supplementLength;
            for (i in m-1...transformedPoints.length) {
                var avp = new Point();
                var seg: Array<FuzzyPoint> = transformedPoints.slice(i-m+1,i+1);
                for (p in seg){
                    avp.x += p.x;
                    avp.y += p.y;
                }
                var x = avp.x/m;
                var y = avp.y/m;
                graphics.lineTo(xx(x),yy(y));
            }
            var e = transformedPoints[transformedPoints.length-1];
            graphics.lineTo(xx(e.x),yy(e.y));
        } else {
            for (i in 1...transformedPoints.length) {
                var p = transformedPoints[i];
                graphics.lineTo(xx(p.x),yy(p.y));
            }
        }
        graphics.endStroke();
        if (Main.App.model.isDebug) {
            graphics
            .beginFill("blue")
            .drawCircle(xx(s.x),yy(s.y),3*dpr)
            .drawCircle(xx(e.x),yy(e.y),3*dpr)
            .endFill();
            for (vec in vertexes) {
                graphics.setStrokeStyle(3*dpr).beginStroke("red");
                graphics.drawCircle(xx(vec.point.x),yy(vec.point.y),5*dpr);
                graphics.endStroke();
            }
            var cp = getClosedPoint();
            if (cp != null) {
                graphics.setStrokeStyle(3*dpr).beginStroke("pink");
                graphics.drawCircle(xx(cp.x),yy(cp.y),5*dpr);
                graphics.endStroke();
            }
        }
        // 最初のレンダリングの際のみ、shapeのtlanslationを合わせる
        if (isFirstRendering) {
            x = mBounds.x;
            y = mBounds.y;
            isFirstRendering = false;
        }
        var pad = 10;
        var padded = mBounds.clone().pad(pad,pad,pad,pad);
        cache(-pad,-pad,padded.width,padded.height);
        updateCache();
        return this;
    }

}
