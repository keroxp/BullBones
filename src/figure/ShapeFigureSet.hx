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
        if (shape.parent != null) {
            var p = shape.parent.localToLocal(shape.x,shape.y,this);
            shape.x = p.x;
            shape.y = p.y;
        }
        addChild(shape);
        var b = getBounds();
        var cb = shape.getBounds();
        if (b == null) {
            b = cb.clone();
        } else {
            b.extend(shape.x,shape.y,cb.width,cb.height);
        }
        setBounds(b.x,b.y,b.width,b.height);
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
        return this;
    }

}
