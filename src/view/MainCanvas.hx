package view;
import figure.ImageFigure;
import model.ImageEditor;
import createjs.easeljs.Bitmap;
import cv.ImageUtil;
import cv.FilterFactory;
import view.ImageEditorView.ImageEditorListener;
import view.SearchView.SearchResultListener;
import ajax.Loader;
import jQuery.Event;
import view.ViewModel;
import ajax.BingSearch.BingSearchResult;
import jQuery.JQuery;
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

interface MainCanvasListener {
    public function onCanvasImageSelected(image: ImageFigure): Void;
}
class MainCanvas extends ViewModel
implements BoundingBox.OnChangeListener
implements SearchResultListener
implements ImageEditorListener {
    var mStage: Stage;
    var mFgLayer: Container;
    var mBgLayer: Container;
    var mMainLayer: Container;
    var mBoundingBox: BoundingBox;
    var mFuzzySketchGraph: Shape;
    var mBackground: Shape;
    var mGrid: Shape;
    var mBrushCircle: Shape;
    var mDrawingFigure: Figure;
    var mFigures: Array<Draggable> = new Array();
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    public var listener: MainCanvasListener;
    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEUP_EVENT";
    public static var ON_CANVAS_IMAGE_SELECTED_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_IMAGE_SELECTED_EVENT";

    private var mFocusedFigure(default,set):Draggable;
    function set_mFocusedFigure(value:Draggable) {
        this.mFocusedFigure = value;
        if (listener != null) {
            if (value != null && value.type == Image) {
                listener.onCanvasImageSelected(cast value);
            } else {
                listener.onCanvasImageSelected(null);
            }
        }
        return value;
    }

    public var isEditing(default,set): Bool = false;
    private function set_isEditing(value:Bool) {
        this.isEditing = value;
        jq.attr("data-editing", value+"");
        mFocusedFigure = value ? mFigures[mFigures.length-1] : null;
        mBackground.visible = value;
        mGrid.visible = value;
        mBrushCircle.visible = !value;
        drawBoundingBox();
        drawBrushCircle();
        draw();
        return value;
    }

    public function new(jq: JQuery) {
        super(jq);
        var window: DOMWindow = js.Browser.window;
        jq.on("mousedown", onCanvasMouseDown);
        jq.on("mousemove", onCanvasMouseMove);
        jq.on("mouseup", onCanvasMouseUp);
        window.addEventListener("keyup", onKeyUp);
        window.addEventListener("keydown", onKeyDown);

        mCanvas = cast jq.get()[0];
        mContext = mCanvas.getContext("2d");
        mBgLayer = new Container();
        mFgLayer = new Container();
        mMainLayer = new Container();
        mStage = new Stage(jq.attr("id"));
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
        // brush
        mBrushCircle = new Shape();
        mFgLayer.addChild(mBrushCircle);
        drawBrushCircle();
        // ファジィグラフ
        mFuzzySketchGraph = new Shape();
        mFgLayer.addChild(mFuzzySketchGraph);

        mStage.addChild(mBgLayer);
        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);

        if (Main.App.v.isDebug) {
            Loader.loadImage("img/bullbones.jpg").done(function(img: Image) {
                var bb = new ImageFigure(img);
                insertImage(bb,0,0);
            }).fail(function(e){
                trace(e);
            });
        }

        listenTo(Main.App.v, "change:brush", drawBrushCircle);
        // KVO
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
    function drawBrushCircle () {
        var w = Main.App.v.brush.width;
        mBrushCircle.graphics
        .clear()
        .setStrokeStyle(1)
        .beginStroke("#000")
        .drawCircle(0,0,w)
        .endStroke();
        mBrushCircle.x = mCapture.prevX;
        mBrushCircle.y = mCapture.prevY;
    }
    function insertImage (img: ImageFigure, x: Float, y: Float) {
        img.bitmap.x = x;
        img.bitmap.y = y;
        mFigures.push(img);
        mMainLayer.addChild(img.bitmap);
        mStage.update();
    }
    public function onImageEditorChange(editor: ImageEditor):Void {
        if (mFocusedFigure != null && mFocusedFigure.type == Image) {
            var image: ImageFigure = cast mFocusedFigure;
            image.filter = editor.createFilter();
            image.bitmap.alpha = editor.alpha;
            trace(editor);
            draw();
        }
    }

    public function onSearchResultSelected(result:BingSearchResult):Void {
        trace(result);
        Loader.loadImage(result.MediaUrl)
        .done(function(img: Image) {
            var bm = new ImageFigure(img);
            bm.thumbSrc = result.Thumbnail.MediaUrl;
            var x = (jq.width()-img.width)/2;
            var y = (jq.height()-img.height)/2;
            insertImage(bm,x,y);
        }).fail(function(e){
            js.Lib.alert("画像の読み込みに失敗しました");
            trace(e);
        });
    }

    public function toggleEditing() {
        isEditing = !isEditing;
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
                f.width = Main.App.v.brush.width;
                f.color = Main.App.v.brush.color;
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
            var tmp: Draggable = null;
            while (i > -1) {
                var d = mFigures[i];
                if (d.bounds.containsPoint(e.clientX,e.clientY)) {
                    d.onDragStart(e);
                    tmp = d;
                    mDragBegan = true;
                    break;
                }
                i--;
            }
            mFocusedFigure = tmp;
            drawBoundingBox();
        }
        mCapture.down(e);
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        draw();
    }
    function onCanvasMouseMove (e: MouseEvent) {
        var toDraw = false;
        if (!isEditing) {
            mBrushCircle.x = e.clientX;
            mBrushCircle.y = e.clientY;
            toDraw = true;
        }
        if (mPressed) {
            if (!isEditing) {
                if (mDrawingFigure != null) {
                    mDrawingFigure.addPoint(e.clientX,e.clientY);
                    var i = mDrawingFigure.points.length-1;
                    var fp = mDrawingFigure.points[i];
                    toDraw = true;
                }
            } else {
                if (mDragBegan) {
                    mFocusedFigure.onDragMove(e);
                    mBoundingBox.shape.x += mCapture.getMoveX(e);
                    mBoundingBox.shape.y += mCapture.getMoveY(e);
                    toDraw = true;
                }
            }
        }
        if (toDraw) draw();
        mCapture.move(e);
        trigger(ON_CANVAS_MOUSEMOVE_EVENT);
    }
    function onCanvasMouseUp (e: MouseEvent) {
        var toDraw = false;
        if (!isEditing) {
            if (mDrawingFigure != null) {
                mDrawingFigure.addPoint(e.clientX, e.clientY);
                mDrawingFigure.calcVertexes();
                mDrawingFigure.isDrawing = false;
                mDrawingFigure = null;
                toDraw = true;
            }
        } else {
            if (mDragBegan) {
                mFocusedFigure.onDragEnd(e);
                drawBoundingBox();
                toDraw = true;
            }
        }
        mCapture.up(e);
        mDrawingFigure = null;
        mPressed = false;
        mDragBegan = false;
        trigger(ON_CANVAS_MOUSEUP_EVENT);
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
    private var mCurrentKeyEvent: KeyboardEvent;
    function onKeyDown (e: KeyboardEvent) {
        if (mCurrentKeyEvent == null) {
            switch e.keyCode {
                case 16: {
                    isEditing = true;
                }
            }
            mCurrentKeyEvent = e;
        }
    }
    function onKeyUp (e: KeyboardEvent) {
        switch e.keyCode {
            case 8: onDelete(e);
            case 16: {
                isEditing = false;
            }
        }
        mCurrentKeyEvent = null;
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
