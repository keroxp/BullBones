package ;
import js.html.Document;
import js.html.Element;
import js.html.DOMWindow;
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
    var mFgLayer: Container;
    var mBgLayer: Container;
    var mMainLayer: Container;
    var mBoundingBox: BoundingBox;
    var mFuzzySketchGraph: Shape;
    var mBackground: Shape;
    var mGrid: Shape;
    var mDrawingFigure: Figure;
    var mFocusedFigure: Figure;
    var mFigures: Array<Figure> = new Array();
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var vPressed = false;
    var vBackgroundColor = "#ddd";
    public var isEditing(default,null): Bool = false;
    public function new(canvasId: String, w: Float, h: Float) {
        var window: DOMWindow = js.Browser.window;
        window.addEventListener("keyup", onKeyUp);
        var document: Document = js.Browser.document;
        var canvas: CanvasElement = cast(document.getElementById(canvasId));
        canvas.addEventListener("mousedown", onCanvasMouseDown);
        canvas.addEventListener("mousemove", onCanvasMouseMove);
        canvas.addEventListener("mouseup", onCanvasMouseUp);
        mCanvas = canvas;
        mContext = canvas.getContext("2d");
        mBgLayer = new Container();
        mFgLayer = new Container();
        mMainLayer = new Container();
        mStage = new Stage(canvasId);
        // 背景
        mBackground = new Shape();
        mBackground.visible = false;
        drawBackground();
        mBgLayer.addChild(mBackground);
        // グリッド
        mGrid = new Shape();
        mGrid.visible = false;
        drawGrid();
        mBgLayer.addChild(mGrid);
        // バウンディングボックス
        mBoundingBox = new BoundingBox();
        mBoundingBox.listener = this;
        mFgLayer.addChild(mBoundingBox.shape);
        // ファジィグラフ
        mFuzzySketchGraph = new Shape();
        mFgLayer.addChild(mFuzzySketchGraph);

        mStage.addChild(mBgLayer);
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
        if (isEditing && mFocusedFigure != null) {
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
    function drawBackground () {
        mBackground.graphics
        .beginFill(vBackgroundColor)
        .drawRoundRect(0,0,mCanvas.width,mCanvas.height,0)
        .endFill();
    }
    function drawGrid () {
        mGrid.graphics
        .setStrokeStyle(1)
        .beginStroke("#fff");
        var i = vGridUnit;
        var max = Math.max(mCanvas.width,mCanvas.height);
        while (i < max) {
            if (i < mCanvas.width) {
                mGrid.graphics.moveTo(i,0).lineTo(i,mCanvas.height);
            }
            if (i < mCanvas.height) {
                mGrid.graphics.moveTo(0,i).lineTo(mCanvas.width,i);
            }
            i += vGridUnit*vGridDivision;
        }
        mGrid.graphics.endStroke();
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
    public function toggleEditing() {
        isEditing = !isEditing;
        mFocusedFigure = isEditing ? mFigures[mFigures.length-1] : null;
        mBackground.visible = isEditing;
        mGrid.visible = isEditing;
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
    function onCanvasMouseDown (e: MouseEvent) {
        vPressed = true;
        if (!isEditing) {
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
        } else {

        }
        draw();
    }
    function onCanvasMouseMove (e: MouseEvent) {
        if (vPressed) {
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
        vPressed = false;
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
        e.stopPropagation();
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
