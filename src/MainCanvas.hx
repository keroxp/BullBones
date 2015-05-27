package ;
import recognition.Recognition;
import BoundingBox.Corner;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import figure.Figure;
import createjs.easeljs.*;
class MainCanvas implements BoundingBox.OnChangeListener {
    var mStage: Stage;
    var mFgLayer: Container;
    var mMainLayer: Container;
    var mBgLayer: Container;
    var mCanvas: Shape;
    var mBoundingBox: BoundingBox;
    var mDrawingFigure: Figure;
    var mFocusedFigure: Figure;
    var mFigures: Array<Figure> = new Array();
    var mContext: CanvasRenderingContext2D;
    var mEditMode: Bool = false;
    public function new(canvasId: String, w: Float, h: Float) {

        var window = js.Browser.window;
        window.addEventListener("keyup", onKeyUp);

        var document = js.Browser.document;
        var canvas: CanvasElement = cast(document.getElementById(canvasId));
        mContext = canvas.getContext("2d");

        mStage = new Stage(canvasId);
        mFgLayer = new Container();
        mBgLayer = new Container();
        mMainLayer = new Container();

        mCanvas = new Shape();
        mCanvas.graphics.beginFill("#ffffff").drawRect(0,0,w,h);
        mCanvas.on("mousedown", onCanvasMouseDown);
        mCanvas.on("pressmove", onCanvasPressMove);
        mCanvas.on("pressup", onCanvasMouseUp);
        mMainLayer.addChild(mCanvas);

        Touch.enable(mStage);
        var circle = new Shape();
        circle.graphics.beginFill("DeepSkyBlue").drawCircle(0, 0, 50);
        circle.x = 100;
        circle.y = 100;
        circle.on("mousedown", onCircleMouseDown);
        circle.on("pressmove", onCirclePressMove);
        mMainLayer.addChild(circle);

        mBoundingBox = new BoundingBox();
        mBoundingBox.listener = this;
        mFgLayer.addChild(mBoundingBox.shape);

        mStage.addChild(mBgLayer);
        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);

        mStage.update();
    }
    function draw () {
        for (f in mFigures) {
            f.render();
        }
        if (mFocusedFigure != null) {
            mBoundingBox.clear();
            mBoundingBox.render(mFocusedFigure.bounds);
        }
        mStage.update();
    }
    function findFigure (shape: Shape): Figure {
        for (f in mFigures) {
            if (f.shape == shape) return f;
        }
        return null;
    }
    var mPrevX: Float;
    var mPrevY: Float;
    function onFigureMouseDown (e: MouseEvent) {
        var f = findFigure(cast e.target);
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        mFocusedFigure = f;
        trace(e);
        draw();
    }
    function onFigurePressMove (e: MouseEvent) {
        var dx = e.stageX - mPrevX;
        var dy = e.stageY - mPrevY;
        var f = findFigure(cast e.target);
        f.moveBy(dx,dy);
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        draw();
    }
    function onFigurePressUp (e: MouseEvent) {
        findFigure(cast e.target).color = "#000000";
        draw();
        trace(e);
    }
    function onCanvasMouseDown (e: MouseEvent) {
        if (mFocusedFigure != null) {
            mBoundingBox.clear();
            mFocusedFigure = null;
        } else {
            mDrawingFigure = new Figure(e.stageX, e.stageY);
            mDrawingFigure.shape.addEventListener("mousedown", onFigureMouseDown);
            mDrawingFigure.shape.addEventListener("pressmove", onFigurePressMove);
            mDrawingFigure.shape.addEventListener("pressup", onFigurePressUp);
            mDrawingFigure.width = 5;
            mFigures.push(mDrawingFigure);
            mMainLayer.addChild(mDrawingFigure.shape);
        }
        draw();
    }
    function onCanvasPressMove (e: MouseEvent) {
        if (mDrawingFigure != null) {
            mDrawingFigure.addPoint(e.stageX,e.stageY);
            draw();
        }
    }
    function onCanvasMouseUp (e: MouseEvent) {
        if (mDrawingFigure != null) {
            mDrawingFigure.addPoint(e.stageX, e.stageY);
            trace(mDrawingFigure);
            recognition.Recognition.line(cast mDrawingFigure.points);
            mDrawingFigure = null;
            draw();
        }
        mDrawingFigure = null;
    }
    function onCircleMouseDown (e: MouseEvent) {
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        draw();
    }
    function onCirclePressMove (e: MouseEvent) {
        var dx = e.stageX-mPrevX;
        var dy = e.stageY-mPrevY;
        e.target.x = e.target.x + dx;
        e.target.y = e.target.y + dy;
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        draw();
    }
    public function onCornerDown (e: MouseEvent, corner: Corner): Void {

    }
    public function onCornerMove (e: MouseEvent, corner: Corner, dx: Float, dy: Float): Void {
        var w = mFocusedFigure.bounds.width();
        var h = mFocusedFigure.bounds.height();
        var px: Float = 0;
        var py: Float = 0;
        var b = mFocusedFigure.bounds;
        switch corner {
            case Corner.TopLeft: {
                b.left += dx;
                b.top += dy;
                px = b.right;
                py = b.bottom;
            }
            case Corner.TopRight: {
                b.right += dx;
                b.top += dy;
                px = b.left;
                py = b.bottom;
            }
            case Corner.BottomLeft: {
                b.left += dx;
                b.bottom += dy;
                px = b.right;
                py = b.top;
            }
            case Corner.BottomRight: {
                b.right += dx;
                b.bottom += dy;
                px = b.left;
                py = b.top;
            }
        }
        var scaleX = mFocusedFigure.bounds.width()/w;
        var scaleY = mFocusedFigure.bounds.height()/h;
        mFocusedFigure.setScale(scaleX,scaleY,px,py);
        draw();
    }
    public function onCornerUp (e: MouseEvent, corner: Corner): Void {

    }
    function onKeyUp (e: KeyboardEvent) {
        trace(e);
        switch e.keyCode {
            case 8: onDelete(e);
        }
    }
    function onDelete (e: KeyboardEvent) {
        if (mFocusedFigure != null) {
            mFigures.remove(mFocusedFigure);
            mMainLayer.removeChild(mFocusedFigure.shape);
            mBoundingBox.clear();
            mFocusedFigure = null;
            draw();
        }
    }
}
