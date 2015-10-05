package figure;

import geometry.Geometries;
import performance.ObjectPool;
import geometry.Scalar;
import geometry.Point;
import geometry.Vertex;
import createjs.easeljs.Rectangle;
import geometry.Vector2D;
import geometry.FuzzyPoint;
import createjs.easeljs.Shape;
using util.RectangleUtil;
using util.ArrayUtil;

class ShapeFigure extends Shape {
    public static var DEFAULT_COLOR = "#000000";
    public static var DEFAULT_WIDTH = Scalar.valueOf(2);
    private static var CLOSE_THRESH: Float = 20*20;
    private static var sTempRect = new Rectangle();
    private static var sPointPool: ObjectPool<Point>
        = new ObjectPool<Point>(5, function() { return new Point(); });
    private static var sVectorPool: ObjectPool<Vector2D>
        = new ObjectPool<Vector2D>(5, function() { return new Vector2D(); });
    // non-scaled points
    public var points(default, null): Array<FuzzyPoint> = new Array<FuzzyPoint>();
    // scaled-points
    public var transformedPoints(default, null) : Array<FuzzyPoint> = new Array<FuzzyPoint>();
    public var vertexes(default, null): Array<Vertex> = new Array<Vertex>();
    public var supplementLength = 5;
    @:isVar public var isLine(default, set) = false;
    function set_isLine(value) {
        if (!isLine && value) {
            points[1] = points.last();
            transformedPoints[1] = transformedPoints.last();
            points.splice(2,points.length-2);
            transformedPoints.splice(2,transformedPoints.length-2);
            mBounds.setValues(points[0].x,points[0].y,0,0);
            calcBounds(points.last().x,points.last().y);
        }
        return this.isLine = value;
    }
    private var mBounds: Rectangle;
    // local scale
    public var shapeScaleX(default,null): Float = 1.0;
    public var shapeScaleY(default,null): Float = 1.0;
    public var color: String = DEFAULT_COLOR;
    public var width: Scalar = DEFAULT_WIDTH;

    public function new() {
        super();
    }

    public function recycle() {
        shapeScaleX = 1.0;
        shapeScaleY = 1.0;
        supplementLength = 5;
        points.clear();
        transformedPoints.clear();
        vertexes.clear();
        color = DEFAULT_COLOR;
        width = DEFAULT_WIDTH;
        mBounds.reset();
        setTransform();
        uncache();
        setBounds(0,0,0,0);
    }

    public function getGlobalBounds(?rect: Rectangle): Rectangle {
        return rect == null ? mBounds.clone() : rect.copy(mBounds);
    }

    override public function clone(): ShapeFigure {
        var ret = new ShapeFigure();
        ret.points = points.cloneArray();
        ret.transformedPoints = transformedPoints.cloneArray();
        ret.vertexes = vertexes.cloneArray();
        ret.shapeScaleX = shapeScaleX;
        ret.shapeScaleY = shapeScaleY;
        ret.color = color;
        ret.width = width;
        ret.supplementLength = supplementLength;
        ret.mBounds = mBounds.clone();
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this, _clone,[ret]);
        // do depp copy _bounds because easeljs.DisplayObject#clone does not :(
        Reflect.setField(ret, "_bounds", getBounds().clone());
        return ret.render();
    }

    public override function toString(): String {
        return '[ShapeFigure id="${id}"]';
    }

    public function getClosedPoint (dest: Point): Bool {
        var last = transformedPoints.length;
        var pts = transformedPoints;
        for (i in 0...2) {
            for (j in last-2...last) {
                 if (pts[i].rawDistance(pts[j]) < CLOSE_THRESH) {
                     dest.x = (pts[i].x+pts[j].x)*.5;
                     dest.y = (pts[i].y+pts[j].y)*.5;
                     return true;
                 }
            }
        }
        return false;
    }
    // find points that is like vertex
    public function calcVertexes () {
        var pts = transformedPoints;
        vertexes = [];
        if (pts.length > 2) {
            var i = 1;
            while (i < pts.length-2) {
                var cur = pts[i];
                var prev = pts[i-1];
                var next = pts[i+1];
                var a = sVectorPool.take();
                a.set(
                    pts[i+1].x-pts[i].x,
                    pts[i+1].y-pts[i].y
                );
                var b = sVectorPool.take();
                b.set(
                    pts[i].x-pts[i-1].x,
                    pts[i].y-pts[i-1].y
                );
                var cos = a.dot(b)/(a.power()*b.power());
                var rad = Math.acos(cos);
                if (Geometries.PI_4_5 < rad && rad < Geometries.PI_1_5) {
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
    public function addPoint (x: Float, y: Float) {
        if (points.length == 0) {
            var fp = new FuzzyPoint(~~(x+.5),~~(y+.5));
            points.push(fp);
            transformedPoints.push(fp);
        } else {
            var fp = new FuzzyPoint(~~(x+.5),~~(y+.5),points.last());
            // don't apend point that is very close to last
            if (fp.rawDistance(points[points.length-1]) > 0) {
                if (isLine) {
                    // In the Line mode, we always put new point as the last.
                    points[1] = fp;
                    transformedPoints[1] = fp;
                    mBounds.setValues(points[0].x,points[0].y);
                } else {
                    points.push(fp);
                    transformedPoints.push(fp);
                }
            }
        }
        calcBounds(x,y);
    }
    private function calcBounds (x: Float, y: Float) {
        if (mBounds == null) {
            mBounds = new Rectangle(x,y,0,0);
        }
        if (x < mBounds.x) {
            mBounds.width += mBounds.x-x;
            mBounds.x = x;
            this.x = x;
        }
        if (mBounds.right() < x){
            mBounds.width = x-mBounds.x;
        }
        if (y < mBounds.y) {
            mBounds.height += mBounds.y - y;
            mBounds.y = y;
            this.y = y;
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

    private inline function xx(x: Float): Float return ~~(x-mBounds.x);
    private inline function yy(y: Float): Float return ~~(y-mBounds.y);
    private var isFirstRendering = true;
    public function render (): ShapeFigure {
        if (points.length < 2) return this;
        var s = transformedPoints[0];
        var e = transformedPoints[transformedPoints.length-1];
        graphics.clear();
        graphics.setStrokeStyle(width,"round","round").beginStroke(color);
        graphics.moveTo(xx(s.x),yy(s.y));
        if (points.length == 2) {
            graphics.lineTo(xx(e.x), yy(e.y));
            graphics.endStroke();
        } else {
            if (Main.App.model.brush.supplemnt) {
                var m = supplementLength;
                for (i in m-1...transformedPoints.length) {
                    var avp = sPointPool.take();
                    var seg = transformedPoints.slice(i-m+1,i+1);
                    for (p in seg){
                        avp.x += p.x;
                        avp.y += p.y;
                    }
                    graphics.lineTo(xx(avp.x/m),yy(avp.y/m));
                }
                var e = transformedPoints[transformedPoints.length-1];
                graphics.lineTo(xx(e.x),yy(e.y));
            } else {
                var i = 1;
                while (i < transformedPoints.length-2) {
                    var p = transformedPoints[i];
                    var n = transformedPoints[i+1];
                    var c = (p.x+n.x)*.5;
                    var d = (p.y+n.y)*.5;
                    graphics.quadraticCurveTo(
                        xx(p.x),
                        yy(p.y),
                        xx(c),
                        yy(d)
                    );
                    i = i+1|0;
                }
                // last 2 points
                graphics.quadraticCurveTo(
                    xx(transformedPoints[i].x),
                    yy(transformedPoints[i].y),
                    xx(transformedPoints[i+1].x),
                    yy(transformedPoints[i+1].y)
                );
            }
        }
        graphics.endStroke();
        if (Main.App.model.isDebug) {
            graphics
            .beginFill("blue")
            .drawCircle(xx(s.x),yy(s.y),Scalar.valueOf(3))
            .drawCircle(xx(e.x),yy(e.y),Scalar.valueOf(3))
            .endFill();
            for (vec in vertexes) {
                graphics.setStrokeStyle(Scalar.valueOf(3)).beginStroke("red");
                graphics.drawCircle(xx(vec.point.x),yy(vec.point.y),Scalar.valueOf(5));
                graphics.endStroke();
            }
            var p = sPointPool.take();
            if (getClosedPoint(p)) {
                graphics.setStrokeStyle(Scalar.valueOf(3)).beginStroke("pink");
                graphics.drawCircle(xx(p.x),yy(p.y),Scalar.valueOf(5));
                graphics.endStroke();
            }
            graphics.setStrokeStyle(Scalar.valueOf(2)).beginFill("green")
            .drawCircle(0,0,Scalar.valueOf(5)).endFill();
        }
        // Only first rendering, adjust x and y axis with local bounds.
        // it is nesessary because just calling drawXX mehthod does not define actual bounds.
        if (isFirstRendering) {
            x = mBounds.x;
            y = mBounds.y;
            isFirstRendering = false;
        }
        var pad = width.toFloat();
        cache(
            -pad,-pad,
            mBounds.width+pad*2,
            mBounds.height+pad*2
        );
        setBounds(0,0,mBounds.width+pad,mBounds.height+pad);
        return this;
    }
}
