package figure;
import util.RectangleUtil;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Rectangle;
import createjs.easeljs.Container;
using figure.Figures;
using util.RectangleUtil;
class ShapeFigureSet extends Container implements Figure {
    private static var sTempRect = new Rectangle();
    public var leftShape(default,null): ShapeFigure;
    public var topShape(default,null): ShapeFigure;
    public var rightShape(default,null): ShapeFigure;
    public var bottomShape(default,null): ShapeFigure;
    public function new() {
        super();
    }

    override public function clone():ShapeFigureSet {
        var ret = new ShapeFigureSet();
        for (s in children) {
            s.asShapeFigure(function(shape: ShapeFigure) {
               ret.addChild(shape.clone().render());
            });
        }
        return ret;
    }

    public static function createWithShapes(shapes: Array<ShapeFigure>): ShapeFigureSet {
        var ret = new ShapeFigureSet();
        for (s in shapes) {
            ret.addShape(s);
        }
        return ret;
    }

    public function addShape(shape: ShapeFigure) {
        var hasNoChild = getNumChildren() == 0;
        var ex: Float = 0;
        var ey: Float = 0;
        if (hasNoChild) {
            leftShape = rightShape = topShape = bottomShape = shape;
        } else {
            if (shape.x < x) { leftShape = shape; }
            if (getTransformedBounds().right() < shape.x) { rightShape = shape; }
            if (shape.y < y) { topShape = shape; }
            if (getTransformedBounds().bottom() < shape.y) { bottomShape = shape; }
        }
        if (shape.x < x || hasNoChild) {
            var diff = x - shape.x;
            x = shape.x;
            shape.x = 0;
            for (child in children) {
                child.x += diff;
                if (ex < child.x) {
                    ex = child.x;
                }
            }
        } else {
            shape.x -= x;
            ex = shape.x;
        }
        if (shape.y < y || hasNoChild) {
            var diff = y - shape.y;
            y = shape.y;
            shape.y = 0;
            for (child in children) {
                child.y += diff;
                if (ey < child.y) {
                    ey = child.y;
                }
            }
        } else {
            shape.y -= y;
            ey = shape.y;
        }
        addChild(shape);
        var b = getBounds();
        var cb = shape.getBounds();
        if (hasNoChild) {
            b = cb.clone();
        } else {
            b.extend(ex,ey,cb.width,cb.height);
        }
        setBounds(0,0,~~b.width,~~b.height);
    }

    override public function toString():String {
        return '[ShapeFigureSet id="$id"]';
    }

    public function getShape(index: Int): ShapeFigure {
        return cast getChildAt(index);
    }

    public function render():Dynamic {
        for (c in children) {
            cast(c, Figure).render();
        }
        return this;
    }

    public function setActive(bool:Bool):Void {
        for (c in children) {
            cast(c, Figure).setActive(bool);
        }
    }

    public function type():FigureType {
        return FigureType.ShapeSet;
    }

    public function onScale(sx:Float, sy:Float):Void {
        scaleX = sx;
        scaleY = sy;
    }

    public function onMove(dx:Float, dy:Float):Void {
        x += dx;
        y += dy;
    }

}
