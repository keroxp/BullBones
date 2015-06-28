package figure;
import util.Log;
import createjs.easeljs.Rectangle;
import createjs.easeljs.DisplayObject;
import figure.Draggable.DraggableType;
import event.MouseEventCapture;
import createjs.easeljs.Point;
import geometry.Vector2D;
import geometry.FuzzyPoint;
import createjs.easeljs.Shape;
using util.RectangleUtil;
class Figure implements Draggable {
    public function new(x: Float, y: Float) {
        addPoint(x,y);
    }

    public function clone(): Figure {
        var ret = new Figure(this.points[0].x,this.points[0].y);
        ret.shape = shape.clone(true);
        ret.points = this.points.map(function(p: FuzzyPoint) { return p.clone(); });
        ret.vertexes = this.vertexes.map(function(vtx: Vertex) { return vtx.clone(); });
        ret.color = color;
        ret.width = width;
        ret.supplementLength = supplementLength;
        ret.isLine = isLine;
        ret.mBounds = mBounds.clone();
        return ret.render();
    }

    // 図形を構成する点
    public var points(default, null): Array<FuzzyPoint> = new Array();
    // 頂点っぽい点
    public var vertexes(default, null): Array<Vertex> = new Array();
    // 描画につかうShape
    private var shape(default, null): Shape = new Shape();
    // 補完係数
    public var supplementLength = 5;
    // 直線フラグ
    private var isLine: Bool = false;
    // 図形のbounds
    private var mBounds: Rectangle;
    // 色
    public var color: String = "#000000";
    // 描画の点の半径
    public var width: Float = 2;
    @:isVar public var type(get, null):DraggableType;
    function get_type():DraggableType {
        return Figure;
    }

    @:isVar public var display(get, null): DisplayObject;
    function get_display(): DisplayObject {
        return this.shape;
    }
    private static var CLOSE_THRESH: Float = 20*20;
    public function getClosedPoint (): Point {
        var last = points.length;
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
    public function addPoint (x: Float, y: Float) {
        calcBounds(x,y);
        if (points.length == 0) {
            points.push(new FuzzyPoint(x,y));
        } else {
            var fp = new FuzzyPoint(x,y,points[points.length-1]);
            // 同じ位置は追加しない
            if (fp.rawDistance(points[points.length-1]) > 0) {
                points.push(fp);
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
        shape.setBounds(0,0,mBounds.width,mBounds.height);
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
        shape.setBounds(0,0,r-l,b-t);
    }
    public function s2e (): Vector2D {
        var s = points[0];
        var e = points[points.length-1];
        return Vector2D.v(s,e);
    }
    private static var LINE_LENGTH_THRESH: Float = 150*150;
    private static var LINE_RECOGNIZE_THRESH = 20;

    public function applyScale(): Figure {
        var px = mBounds.x;
        var py = mBounds.y;
        var sx = shape.scaleX;
        var sy = shape.scaleY;
        for (p in this.points) {
            p.x = (p.x-px)*sx+px;
            p.y = (p.y-py)*sy+py;
        }
        mBounds.width *= sx;
        mBounds.height *= sy;
        shape.setBounds(0,0,mBounds.width,mBounds.height);
        shape.scaleX = shape.scaleY = 1.0;
        return this;
    }

    private inline function xx(x: Float): Float return x-mBounds.x;
    private inline function yy(y: Float): Float return y-mBounds.y;
    private var isFirstRendering = true;
    public function render (?arg: Dynamic): Figure {
        if (points.length < 2) return this;
        var s = points[0];
        var e = points[points.length-1];
        shape.graphics.clear();
        shape.graphics.setStrokeStyle(width,"round",1).beginStroke(color);
        shape.graphics.moveTo(xx(s.x),yy(s.y));
        if (Main.App.v.brush.supplemnt) {
            // 平均係数
            var m = supplementLength;
            for (i in m-1...points.length) {
                var avp = new Point();
                var seg: Array<FuzzyPoint> = points.slice(i-m+1,i+1);
                for (p in seg){
                    avp.x += p.x;
                    avp.y += p.y;
                }
                shape.graphics.lineTo(xx(avp.x/m),yy(avp.y/m));
            }
            var e = points[points.length-1];
            shape.graphics.lineTo(xx(e.x),yy(e.y));
        } else {
            for (i in 1...points.length-1) {
                var p = points[i];
                var n = points[i+1];
                shape.graphics.lineTo(xx(p.x),yy(p.y));
            }
        }
        shape.graphics.endStroke();
        if (Main.App.v.isDebug) {
            shape.graphics
            .beginFill("blue")
            .drawCircle(xx(s.x),yy(s.y),3)
            .drawCircle(xx(e.x),yy(e.y),3)
            .endFill();
            for (vec in vertexes) {
                shape.graphics.setStrokeStyle(3).beginStroke("red");
                shape.graphics.drawCircle(xx(vec.point.x),yy(vec.point.y),5);
                shape.graphics.endStroke();
            }
            var cp = getClosedPoint();
            if (cp != null) {
                shape.graphics.setStrokeStyle(3).beginStroke("pink");
                shape.graphics.drawCircle(xx(cp.x),yy(cp.y),5);
                shape.graphics.endStroke();
            }
        }
        // 最初のレンダリングの際のみ、shapeのtlanslationを合わせる
        if (isFirstRendering) {
            shape.x = mBounds.x;
            shape.y = mBounds.y;
            isFirstRendering = false;
        }
        return this;
    }
}
