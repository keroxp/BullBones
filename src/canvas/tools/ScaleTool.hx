package canvas.tools;
import command.LayerAffineCommand;
import figure.BoundingBox.Corner;
using util.RectangleUtil;
class ScaleTool implements CanvasTool {
    var corner: Corner;

    public function new(corner: Corner) {
        this.corner = corner;
    }

    public function onMouseDown(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        mcanvas.mUndoCommand = new LayerAffineCommand(mcanvas.activeLayer, mcanvas);
    }

    public function onMouseMove(mc:MainCanvas, e:CanvasMouseEvent):Void {
        var tb = mc.activeLayer.getTransformedBounds().clone();
        var lpmn = e.getLocal(mc.mMainContainer);
        var lpmnprev = e.getLocalPrev(mc.mMainContainer);
        inline function doScaleX (width: Float) {
            var sx = width/tb.width;
            if (0 < sx) {
                mc.activeLayer.scaleX *= sx;
            }
        }
        inline function doScaleY (height: Float) {
            var sy = height/tb.height;
            if (0 < sy) {
                mc.activeLayer.scaleY *= sy;
            }
        }
        inline function constrainScaleX () {
            if (lpmn.x < tb.right()) {
                if (tb.right() < lpmnprev.x) {
                    doScaleX(tb.right()-e.x);
                } else {
                    doScaleX(tb.width-e.deltaX/mc.scale);
                }
                mc.activeLayer.x = lpmn.x;
            }
        }
        inline function constrainScaleY () {
            if (lpmn.y < tb.bottom()) {
                if (tb.bottom() < lpmnprev.y) {
                    doScaleY(tb.bottom()-lpmn.y);
                } else {
                    doScaleY(tb.height-e.deltaY/mc.scale);
                }
                mc.activeLayer.y = lpmn.y;
            }
        }
        mc.extendDirtyRectWithDisplayObject(mc.activeLayer);
        corner.isLeft? constrainScaleX() : doScaleX(tb.width+e.deltaX/mc.scale);
        corner.isTop? constrainScaleY() : doScaleY(tb.height+e.deltaY/mc.scale);
        if (mc.modifiedByShift()) {
            var d = mc.activeLayer;
            var s = (d.scaleX+d.scaleY)*0.5;
            var oBounds = d.getBounds();
            d.scaleX = d.scaleY = s;
            var w = oBounds.width*s;
            var h = oBounds.height*s;
            if (corner.isLeft) {
                d.x = tb.right()-w;
            }
            if (corner.isTop) {
                d.y = tb.bottom()-h;
            }
        }
        mc.extendDirtyRectWithDisplayObject(mc.activeLayer);
        mc.drawBoundingBox(mc.activeLayer);
    }

    public function onMouseUp(mc:MainCanvas, e:CanvasMouseEvent):Void {
        mc.activeLayer.applyScale(1.0,1.0);
        mc.drawBoundingBox(mc.activeLayer);
        Main.App.layerView.invalidate(mc.activeLayer);
    }

    public function toString():String {
        return "[ScaleTool]";
    }

}
