package canvas.tools;
import canvas.CanvasMouseEvent;
import canvas.MainCanvas;
import model.StampModel;
import figure.ImageFigure;
class StampTool implements CanvasTool {
    var mDelta: Float = 0;
    public function new() {
    }

    public function onMouseDown(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        insertStamp(mainCanvas,e,mainCanvas.activeStamp);
    }

    public function onMouseMove(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
        mDelta += e.totalDeltaX*e.totalDeltaX + e.totalDeltaY*e.totalDeltaY;
        if (mDelta > Math.pow(mainCanvas.activeStamp.space,2)) {
            insertStamp(mainCanvas,e,mainCanvas.activeStamp);
            mDelta = 0;
        }
    }

    public function onMouseUp(mainCanvas:MainCanvas, e:CanvasMouseEvent):Void {
    }

    private function insertStamp(mainCanvas: MainCanvas, e: CanvasMouseEvent, stamp: StampModel) {
        var p = e.getLocal(mainCanvas.mMainContainer);
        var fig = new ImageFigure(stamp.image.clone());
        var bounds = fig.getBounds();
        fig.x = p.x - bounds.width * .5;
        fig.y = p.y - bounds.height * .5;
        mainCanvas.insertFigure(fig);
    }
}
