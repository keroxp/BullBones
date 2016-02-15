package canvas.tools;
import command.Undoable;
import command.AffineCommand;
import command.MirroringPivotMoveCommand;
import createjs.easeljs.DisplayObject;
using util.RectangleUtil;
class DragTool implements CanvasTool{
    var target: DisplayObject;
    public function new(target: DisplayObject) {
        this.target = target;
    }

    public function onMouseDown(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        if (target == mcanvas.mMirrorPivotShape) {
            mcanvas.mUndoCommand = new MirroringPivotMoveCommand(target, mcanvas);
        } else {
            mcanvas.mUndoCommand = new AffineCommand<DisplayObject>(target, mcanvas);
        }
        mcanvas.setCursor("move");
    }

    public function onMouseMove(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        if (!mcanvas.isEditing) {
            target.x += e.deltaX;
            target.y += e.deltaY;
            if (target == mcanvas.mMirrorPivotShape) {
                var ms = mcanvas.mMirrorPivotShape;
                var w = ms.totalRadius.toFloat();
                var piv = mcanvas.mFgContainer.localToLocal(
                    ms.x+w,
                    ms.y+w,
                    mcanvas.mLayerContainer
                );
                mcanvas.mirroringInfo.pivotX = piv.x;
                mcanvas.mirroringInfo.pivotY = piv.y;
                mcanvas.extendDirtyRectWithDisplayObject(ms);
            }
        } else {
            mcanvas.extendDirtyRectWithDisplayObject(mcanvas.activeLayer);
            target.x += e.deltaX/mcanvas.scale;
            target.y += e.deltaY/mcanvas.scale;
            mcanvas.mBoundingBox.x += e.deltaX;
            mcanvas.mBoundingBox.y += e.deltaY;
            mcanvas.extendDirtyRectWithDisplayObject(target);
            mcanvas.mDirtyRect.padAll(mcanvas.mBoundingBox.cornerRadius.toFloat()*2);
            mcanvas.mPopupMenu.dismiss(200);
        }
    }

    public function onMouseUp(mc:MainCanvas, e:CanvasMouseEvent):Void {
        mc.drawBoundingBox(cast target);
    }

    public function toString():String {
        return "[DragTool]";
    }
}
