package figure;
import util.RectangleUtil;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Rectangle;
import createjs.easeljs.Point;
import createjs.easeljs.Shape;
import createjs.easeljs.Container;
using util.FigureUtil;
using util.RectangleUtil;
class ShapeFigureSet extends Container  {
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
        if (shape.x < x || hasNoChild) {
            x = shape.x;
            shape.x = 0;
        } else {
            shape.x -= x;
        }
        if (shape.y < y || hasNoChild) {
            y = shape.y;
            shape.y = 0;
        } else {
            shape.y -= y;
        }
        addChild(shape);
        var b = getBounds();
        var cb = shape.getBounds();
        if (hasNoChild) {
            b = cb.clone();
        } else {
            b.extend(shape.x,shape.y,cb.width,cb.height);
        }
        trace(b);
        setBounds(0,0,b.width,b.height);
    }

    override public function toString():String {
        return "[ShapeFigureSet]";
    }

    public function getShape(index: Int): ShapeFigure {
        return cast getChildAt(index);
    }

    public function render():Dynamic {
        for (c in children) {
            c.asShapeFigure(function(shape: ShapeFigure) {
                shape.render();
            });
        }
        var pad = 10;
        var padded = getTransformedBounds().clone().pad(pad,pad,pad,pad);
        cache(-pad,-pad,padded.width,padded.height);
        updateCache();
        return this;
    }

}
