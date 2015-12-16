package canvas.tools;
import canvas.CanvasMouseEvent;
import canvas.MainCanvas;
import model.StampModel;
import figure.ImageFigure;
class StampTool implements CanvasTool {
    var mDelta: Float = -1;
    public function new() {
    }

    public function onMouseDown(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        mDelta = -1;
        insertStamp(mainCanvas,e);
    }

    public function onMouseMove(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        insertStamp(mainCanvas,e);
    }

    public function onMouseUp(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
    }

    private function insertStamp(mainCanvas: MainCanvas, e: CanvasMouseEvent) {
        var stamp = mainCanvas.activeStamp;
        if (stamp == null) return;
        mDelta += e.totalDeltaX*e.totalDeltaX + e.totalDeltaY*e.totalDeltaY;
        if (mDelta < 0 || mDelta > Math.pow(stamp.space,2)) {
            var p = e.getLocal(mainCanvas.mMainContainer);
            var fig = new ImageFigure(stamp.image);
            var bounds = fig.getTransformedBounds();
            fig.scaleX = stamp.scaleX;
            fig.scaleY = stamp.scaleY;
            fig.x = p.x - bounds.width * fig.scaleX * .5;
            fig.y = p.y - bounds.height * fig.scaleY * .5;
            mainCanvas.insertFigure(fig);
            mDelta = 0;
        }
    }
}
