package canvas.tools;
import geometry.Points;
import createjs.easeljs.Point;
import figure.Figure;
import createjs.easeljs.DisplayObject;
import geometry.Scalar;
import createjs.easeljs.Rectangle;
using util.RectangleUtil;
using util.ArrayUtil;
class SelectTool implements CanvasTool {
    public function new() {
    }

    private var mSelectedBouds = new Rectangle();
    private var mSelectedFigures: Array<DisplayObject> = [];
    private var sPointPool = Points.createPool(3);

    public function onMouseDown(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var p = e.getLocal(mcanvas.mMainContainer);
        mSelectedBouds.setValues(p.x,p.y);
    }

    public function onMouseMove(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var x = e.totalDeltaX < 0 ? e.startX+e.totalDeltaX : e.startX;
        var y = e.totalDeltaY < 0 ? e.startY+e.totalDeltaY : e.startY;
        var w = e.totalDeltaX < 0 ? -e.totalDeltaX : e.totalDeltaX;
        var h = e.totalDeltaY < 0 ? -e.totalDeltaY : e.totalDeltaY;
        var fgp = mcanvas.mFgContainer.globalToLocal(x,y,sPointPool.take());
        var mgp = mcanvas.mMainContainer.globalToLocal(x,y,sPointPool.take());
        var mgp2 = mcanvas.mMainContainer.globalToLocal(x+w,y+h, sPointPool.take());
        mSelectedBouds.setValues(mgp.x,mgp.y,mgp2.x-mgp.x,mgp2.y-mgp.y);
        var buf = mcanvas.getBufferShape(mcanvas.mFgContainer);
        buf.graphics
        .clear()
        .setStrokeStyle(Scalar.valueOf(1))
        .beginStroke("black")
        .drawRoundRect(~~(fgp.x)+.5, ~~(fgp.y)+.5,w,h,0);
        mSelectedFigures = mSelectedFigures.filter(function (d: DisplayObject) {
           var ret = d.getTransformedBounds().intersects(mSelectedBouds);
            if (!ret) {
                cast(d, Figure).setActive(false);
                mcanvas.extendDirtyRectWithDisplayObject(d);
            }
            return ret;
        });
        for (fig in mcanvas.mFigureContainer.children) {
            if (fig.getTransformedBounds().intersects(mSelectedBouds)
                && mSelectedFigures.indexOf(fig) == -1)
            {
                mSelectedFigures.push(fig);
                mcanvas.extendDirtyRectWithDisplayObject(fig);
                cast(fig, Figure).setActive(true);
            }
        }
        mcanvas.extendDirtyRect(x,y,w,h);
    }

    public function onMouseUp(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        var buf = mcanvas.getBufferShape(mcanvas.mFgContainer);
        trace(mSelectedFigures);
        for (fig in mSelectedFigures) {
            cast(fig, Figure).setActive(false);
        }
        for (fig in mSelectedFigures) {
            mcanvas.extendDirtyRectWithDisplayObject(fig);
        }
        mSelectedFigures.clear();
        buf.graphics.clear();
    }

}
