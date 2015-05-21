package ;
import createjs.easeljs.*;
class MainCanvas {
    var mStage: Stage;
    var mCanvas: Shape;
    var mTouchedObject: DisplayObject;
    public function new() {
        mStage = new Stage("mainCanvas");
        mCanvas = new Shape();
        mCanvas.graphics.beginFill("#ffffff").drawRect(0,0,800,600);
        mStage.addChild(mCanvas);
        mCanvas.on("mousedown", onCanvasMouseDown);
        mCanvas.on("pressmove", onCanvasPressMove);
        Touch.enable(mStage);
        var circle = new Shape();
        circle.graphics.beginFill("DeepSkyBlue").drawCircle(0, 0, 50);
        circle.x = 100;
        circle.y = 100;
        circle.on("mousedown", onCircleMouseDown);
        circle.on("pressmove", onCirclePressMove);
        mStage.addChild(circle);
        mStage.update();
    }
    var mPrevX: Float;
    var mPrevY: Float;
    function onCanvasMouseDown (e: MouseEvent) {
        trace(e);
    }
    function onCanvasPressMove (e: MouseEvent) {
        trace(e);
    }
    function onCircleMouseDown (e: MouseEvent) {
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        e.bubbles = true;

    }
    function onCirclePressMove (e: MouseEvent) {
        var dx = e.stageX-mPrevX;
        var dy = e.stageY-mPrevY;
        e.target.x = e.target.x + dx;
        e.target.y = e.target.y + dy;
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        mStage.update();
    }
}
