package ;
import geometry.MouseEventCapture;
import js.html.Document;
import figure.Draggable;
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
    var mFocusedFigure: Draggable;
    var mFigures: Array<Draggable> = new Array();
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
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
    function drawBoundingBox () {
        mBoundingBox.clear();
        mBoundingBox.shape.x = 0;
        mBoundingBox.shape.y = 0;
        if (isEditing && mFocusedFigure != null) {
            mBoundingBox.render(mFocusedFigure.bounds);
        }
    }
    public function onSelectImage (src: String) {
        var img = new Image();
        img.onload = function (a) {
            var document: Document = cast js.Browser.document;
            var dummyCanvas: CanvasElement = cast document.createElement("canvas");
            var dummyContext = dummyCanvas.getContext2d();
            var w = img.width;
            var h = img.height;
            dummyCanvas.width = w;
            dummyCanvas.height = h;
            dummyContext.drawImage(img,0,0);
            var input = dummyContext.getImageData(0,0,w,h);
            var out = new cv.Filter(input,w,h).applyEdge2().applyNegaposi().applyGray().get();
            dummyContext.putImageData(out,0,0);
            var bm = new figure.Image(dummyCanvas.toDataURL("image/png"),w,h);
            mFigures.push(bm);
            mMainLayer.addChild(bm.display);
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
        drawBoundingBox();
        draw();
    }
    private var mDragBegan = false;
    private var mCapture = new MouseEventCapture();
    function onCanvasMouseDown (e: MouseEvent) {
        mPressed = true;
        if (!isEditing) {
            if (mFocusedFigure != null) {
                mFocusedFigure = null;
                drawBoundingBox();
            } else {
                var f =  new Figure(e.clientX, e.clientY);
                f.width = 3;
                mFigures.push(f);
                mContext.beginPath();
                f.render();
                mContext.stroke();
                mContext.closePath();
                mMainLayer.addChild(f.display);
                drawFuzzyPointGraph(f.points[0],0);
                mDrawingFigure = f;
            }
        } else {
            var i = mFigures.length-1;
            while (i > -1) {
                var d = mFigures[i];
                if (d.bounds.containsPoint(e.clientX,e.clientY)) {
                    d.onDragStart(e);
                    mFocusedFigure = d;
                    mDragBegan = true;
                    drawBoundingBox();
                    break;
                }
                i--;
            }
        }
        mCapture.down(e);
        draw();
    }
    function onCanvasMouseMove (e: MouseEvent) {
        if (mPressed) {
            if (!isEditing && mDrawingFigure != null) {
                mDrawingFigure.addPoint(e.clientX,e.clientY);
                var i = mDrawingFigure.points.length-1;
                var fp = mDrawingFigure.points[i];
                haxe.Timer.delay(function(){
                    drawFuzzyPointGraph(fp,i);
                },0);
                draw();
            } else {
                if (mDragBegan) {
                    mFocusedFigure.onDragMove(e);
                    mBoundingBox.shape.x += mCapture.getMoveX(e);
                    mBoundingBox.shape.y += mCapture.getMoveY(e);
                    draw();
                }
            }
        }
        mCapture.move(e);
    }
    function onCanvasMouseUp (e: MouseEvent) {
        if (!isEditing && mDrawingFigure != null) {
            mDrawingFigure.addPoint(e.clientX, e.clientY);
            mDrawingFigure.calcVertexes();
            mDrawingFigure.isDrawing = false;
            mDrawingFigure = null;
            draw();
        } else {
            if (mDragBegan) {
                mFocusedFigure.onDragEnd(e);
                drawBoundingBox();
                draw();
            }
        }
        mCapture.up(e);
        mDrawingFigure = null;
        mPressed = false;
        mDragBegan = false;
    }
    public function onCornerDown (e: createjs.easeljs.MouseEvent, corner: Corner): Void {

    }
    public function onCornerMove (e: createjs.easeljs.MouseEvent, corner: Corner, dx: Float, dy: Float): Void {
        var f: Draggable = cast mFocusedFigure;
        var w = f.bounds.width();
        var h = f.bounds.height();
        var px: Float = 0;
        var py: Float = 0;
        var b = f.bounds;
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
        var scaleX = f.bounds.width()/w;
        var scaleY = f.bounds.height()/h;
//        mFocusedFigure.setScale(scaleX,scaleY,px,py);
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
            mMainLayer.removeChild(mFocusedFigure.display);
            mBoundingBox.clear();
            mFocusedFigure = null;
            draw();
        }
    }
}
