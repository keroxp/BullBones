package ;
import js.html.DOMWindow;
import jQuery.JQuery;
import js.Error;
import js.html.MouseEvent;
import createjs.easeljs.Container;
import js.html.ImageData;
import js.html.Image;
import geometry.FuzzyPoint;
import figure.BoundingBox;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import figure.Figure;
import createjs.easeljs.Stage;
import createjs.easeljs.Shape;
import createjs.easeljs.Bitmap;

class MainCanvas implements BoundingBox.OnChangeListener {
    var mStage: Stage;
    var jCanvas: JQuery;
    var mFgLayer: Container;
    var mMainLayer: Container;
    var mBoundingBox: BoundingBox;
    var mFuzzySketchGraph: Shape;
    var mBackground: Shape;
    var mDrawingFigure: Figure;
    var mFocusedFigure: Figure;
    var mFigures: Array<Figure> = new Array();
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    public function new(canvasId: String, w: Float, h: Float) {

        var window: DOMWindow = js.Browser.window;
        window.addEventListener("keyup", onKeyUp);

        jCanvas = new JQuery('#$canvasId');

        var document = js.Browser.document;
        var canvas: CanvasElement = cast(document.getElementById(canvasId));
        canvas.addEventListener("mousedown", onCanvasMouseDown);
        canvas.addEventListener("mousemove", onCanvasMouseMove);
        canvas.addEventListener("mouseup", onCanvasMouseUp);
        mCanvas = canvas;
        mContext = canvas.getContext("2d");

        mFgLayer = new Container();
        mMainLayer = new Container();
        mStage = new Stage(canvasId);

        mBackground = new Shape();
        mStage.addChild(mBackground);

        mBoundingBox = new BoundingBox();
        mBoundingBox.listener = this;
        mFgLayer.addChild(mBoundingBox.shape);

        mFuzzySketchGraph = new Shape();
        mFgLayer.addChild(mFuzzySketchGraph);

        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);

        mStage.update();
    }
    function draw () {
        mContext.beginPath();
        for (f in mFigures) {
            if (f.isDirty) {
                f.render();
                f.isDirty = false;
            }
        }
        mContext.stroke();
        mContext.closePath();
        mBoundingBox.clear();
        if (editing && mFocusedFigure != null) {
            mBoundingBox.render(mFocusedFigure.bounds);
        }
        mStage.update();
    }
    function drawFuzzyPointGraph (p: FuzzyPoint, i: Int) {
        if (i == 0) {
            mFuzzySketchGraph.graphics.clear();
            mFuzzySketchGraph.graphics.setStrokeStyle(1).beginStroke("red").moveTo(0,mCanvas.height);
        }
        mFuzzySketchGraph.graphics.lineTo(i*3, mCanvas.height-p.velocity/3);
    }

    public function onSelectImage (src: String) {
        var img = new Image();
        img.onload = function (a) {
            var dummyCanvas: CanvasElement = cast js.Browser.document.createElement("canvas");
            var dummyContext = dummyCanvas.getContext2d();
            var w = img.width;
            var h = img.height;
            dummyCanvas.width = w;
            dummyCanvas.height = h;
            dummyContext.drawImage(img,0,0);
            var input = dummyContext.getImageData(0,0,w,h);
            var out = new cv.Filter(input,w,h).applyEdge2().applyNegaposi().applyGray().get();
            dummyContext.putImageData(out,0,0);
            var bm = new Bitmap(dummyCanvas.toDataURL("image/png"));
            mMainLayer.addChild(bm);
            mStage.update();
        }
        img.onerror = function (e: Error) {
            js.Lib.alert("画像の読み込みに失敗しました");
            trace(e);
        }
        img.src = 'proxy/$src';
    }
    public var editing(default,null): Bool = false;
    public function setEdit(edit: Bool) {
        editing = edit;
        mFocusedFigure = edit ? mFigures[mFigures.length-1] : null;
        jCanvas.css("background-color", edit ? "#333" : "#fff");
        draw();
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
        mPrevX = e.layerX;
        mPrevY = e.layerY;
        mFocusedFigure = f;
        trace(e);
        draw();
    }
    function onFigurePressMove (e: MouseEvent) {
        var dx = e.layerX - mPrevX;
        var dy = e.layerY - mPrevY;
        var f = findFigure(cast e.target);
        f.moveBy(dx,dy);
        mPrevX = e.layerX;
        mPrevY = e.layerY;
        draw();
    }
    function onFigurePressUp (e: MouseEvent) {
        findFigure(cast e.target).color = "#000000";
        draw();
        trace(e);
    }
    private var mPressed: Bool = false;
    function onCanvasMouseDown (e: MouseEvent) {
        mPressed = true;
        if (mFocusedFigure != null) {
            mBoundingBox.clear();
            mFocusedFigure = null;
        } else {
            mDrawingFigure = new Figure(e.layerX, e.layerY);
            mDrawingFigure.width = 3;
            mFigures.push(mDrawingFigure);
            mMainLayer.addChild(mDrawingFigure.shape);
            drawFuzzyPointGraph(mDrawingFigure.points[0],0);
        }
        draw();
    }
    function onCanvasMouseMove (e: MouseEvent) {
        if (mPressed) {
            if (mDrawingFigure != null) {
                mDrawingFigure.addPoint(e.layerX,e.layerY);
                var i = mDrawingFigure.points.length-1;
                var fp = mDrawingFigure.points[i];
                haxe.Timer.delay(function(){
                    drawFuzzyPointGraph(fp,i);
                },0);
                draw();
            }
        }
    }
    function onCanvasMouseUp (e: MouseEvent) {
        if (mDrawingFigure != null) {
            mDrawingFigure.addPoint(e.layerX, e.layerY);
            mDrawingFigure.calcVertexes();
            mDrawingFigure.isDrawing = false;
            mDrawingFigure = null;
            draw();
        }
        mDrawingFigure = null;
        mPressed = false;
    }
    public function onCornerDown (e: createjs.easeljs.MouseEvent, corner: Corner): Void {

    }
    public function onCornerMove (e: createjs.easeljs.MouseEvent, corner: Corner, dx: Float, dy: Float): Void {
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
    public function onCornerUp (e: createjs.easeljs.MouseEvent, corner: Corner): Void {

    }
    function onKeyUp (e: KeyboardEvent) {
        e.preventDefault();
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
