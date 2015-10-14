package figure;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Rectangle;
using util.RectangleUtil;
using util.ArrayUtil;
class Selection extends DisplayObject implements Figure {
    public var figures: Array<DisplayObject> = new Array<DisplayObject>();
    private var mBounds: Rectangle = new Rectangle();
    public function new() {
        super();
    }

    public function addFigure(fig: DisplayObject) {
        if (figures.length == 0) {
            mBounds.copy(fig.getTransformedBounds());
        } else {
            mBounds.extendWithRect(fig.getTransformedBounds());
        }
        figures.push(fig);
        x = mBounds.x;
        y = mBounds.y;
        setBounds(0,0,mBounds.width,mBounds.height);
    }

    public function removeFigure(fig: DisplayObject) {
        figures.remove(fig);
        if (figures.length > 0) {
            mBounds.copy(figures[0].getTransformedBounds());
            for (fig in figures) {
                mBounds.extendWithRect(fig.getTransformedBounds());
            }
        } else {
            mBounds.reset();
        }
        x = mBounds.x;
        y = mBounds.y;
        setBounds(0,0,mBounds.width,mBounds.height);
    }

    public function clear() {
        figures.clear();
        mBounds.reset();
    }

    public function setActive(bool:Bool):Void {
        for (fig in figures) {
            cast(fig, Figure).setActive(bool);
        }
    }

    public function render():Dynamic {
        return this;
    }

    public function onScale(sx:Float, sy:Float):Void {
        var _sx = sx/scaleX;
        var _sy = sy/scaleY;
        for (fig in figures) {
            fig.scaleX *= _sx;
            fig.scaleY *= _sy;
        }
        scaleX = sx;
        scaleY = sy;
    }

    public function type():FigureType {
        return FigureType.Selection;
    }

    public function onMove(dx:Float, dy:Float):Void {
        for (fig in figures) {
            fig.x += dx;
            fig.y += dy;
        }
        x += dx;
        y += dy;
    }

    override public function toString():String {
        return "[Selection]";
    }
}
