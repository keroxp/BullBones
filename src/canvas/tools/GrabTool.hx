package canvas.tools;
import util.CursorUtil;
class GrabTool implements CanvasTool {
    public function new() {
    }

    public function onMouseDown(mcanvas:MainCanvas, e:CanvasMouseEvent):Void {
        mcanvas.setCursor(CursorUtil.grabbingCursor());
    }

    public function onMouseMove(mc:MainCanvas, e:CanvasMouseEvent):Void {
        mc.mMainContainer.x += e.deltaX;
        mc.mMainContainer.y += e.deltaY;
        mc.mFgContainer.x += e.deltaX;
        mc.mFgContainer.y += e.deltaY;
        mc.extendDirtyRect(0,0,mc.mCanvas.width,mc.mCanvas.height);
        mc.drawGrid(e.deltaX,e.deltaY);
        mc.mPopupMenu.dismiss(200);
    }

    public function onMouseUp(mc:MainCanvas, e:CanvasMouseEvent):Void {
        mc.setCursor(CursorUtil.grabCursor());
    }

    public function toString():String {
        return "[GrabTool]";
    }

}
