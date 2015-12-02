package figure;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Rectangle;
using util.RectangleUtil;
using util.ArrayUtil;
class MultipleFigures extends DisplayObject {
    public var figures: Array<DisplayObject> = [];
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

    public function type():FigureType {
        return FigureType.Internal;
    }

    public function setActive(bool:Bool):Void {
        for (fig in figures) {
            fig.setActive(bool);
        }
    }


}
