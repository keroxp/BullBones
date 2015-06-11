package view;
import util.BrowserUtil;
import hammer.HammerEvent;
import hammer.Hammer;
import js.Browser;
import figure.ImageFigure;
import model.ImageEditor;
import createjs.easeljs.Bitmap;
import view.ImageEditorView.ImageEditorListener;
import view.SearchView.SearchResultListener;
import ajax.Loader;
import view.ViewModel;
import ajax.BingSearch.BingSearchResult;
import jQuery.JQuery;
import event.MouseEventCapture;
import figure.Draggable;
import js.html.Element;
import js.html.DOMWindow;
import js.html.MouseEvent;
import createjs.easeljs.Container;
import js.html.Image;
import geometry.FuzzyPoint;
import figure.BoundingBox;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import figure.Figure;
import createjs.easeljs.Stage;
import createjs.easeljs.Shape;

using view.ViewUtil;
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
    var window: DOMWindow = Browser.window;

    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null)
        = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEUP_EVENT";

    @:isVar public var activeFigure(get,set):Draggable;
    function get_activeFigure(): Draggable {
        return get("activeFigure");
    }
    function set_activeFigure(value:Draggable) {
        set("activeFigure", value);
        return this.activeFigure = value;
    }

    @:isVar public var isEditing(get,set): Bool = false;
    function get_isEditing(): Bool {
        return get("isEditing");
    }
    function set_isEditing(value:Bool) {
        this.isEditing = value;
        jq.attr("data-editing", value+"");
        activeFigure = value ? mFigures[mFigures.length-1] : null;
        mBackground.visible = value;
        mGrid.visible = value;
        mBrushCircle.visible = !value;
        drawBoundingBox();
        drawBrushCircle();
        draw();
        set("isEditing", value);
        return value;
    }

    public function new(jq: JQuery) {
        super(jq);
        var window: DOMWindow = js.Browser.window;
        var hm = new Hammer(el);
        hm.on("panstart", function (e: HammerEvent) {
            if (e.pointers.length == 1) {
                onPanStart(e);
            }
        });
        hm.on("panmove", function (e: HammerEvent) {
            if (e.pointers.length == 1) {
                onPanMove(e);
            }
        });
        hm.on("panend", function (e: HammerEvent) {
            if (e.pointers.length == 1) {
                onPanEnd(e);
            }
        });
        if (!BrowserUtil.isTable() && !BrowserUtil.isMobile()) {
            el.on("mousemove", onMouseMove);
        }
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
        mBgLayer.addChild(mBackground);
        // グリッド
        mGrid = new Shape();
        mGrid.visible = false;
        mBgLayer.addChild(mGrid);
        // バウンディングボックス
        mBoundingBox = new BoundingBox();
        mBoundingBox.listener = this;
        mFgLayer.addChild(mBoundingBox.shape);
        // brush
        mBrushCircle = new Shape();
        mFgLayer.addChild(mBrushCircle);
        // ファジィグラフ
        mFuzzySketchGraph = new Shape();
        mFgLayer.addChild(mFuzzySketchGraph);

        mStage.addChild(mBgLayer);
        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);

        if (Main.App.v.isDebug) {
            Loader.loadImage("img/bullbones.jpg").done(function(img: Image) {
                var bb = ImageFigure.fromImage(img);
                insertImage(bb,0,0);
            }).fail(function(e){
                trace(e);
            });
        }
        // reset drawing
        resizeCanvas();
        invalidate();
    }

    override public function init() {
        // event observing
        listenTo(Main.App.v, "change:brush", drawBrushCircle);
        listenTo(Main.App, App.APP_WINDOW_RESIZE_EVENT, resizeCanvas);
        Main.App.onFileLoad = onFileLoad;
    }

    function invalidate () {
        drawBackground();
        drawGrid();
        drawBrushCircle();
        drawBoundingBox();
        draw();
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
        .clear()
        .beginFill(vBackgroundColor)
        .drawRoundRect(0,0,mCanvas.width,mCanvas.height,0)
        .endFill();
    }
    function drawGrid () {
        mGrid.graphics
        .clear()
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
        if (activeFigure != null) {
            mBoundingBox.render(activeFigure.bounds);
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
        if (activeFigure != null && activeFigure.type == Image) {
            var image: ImageFigure = cast activeFigure;
            image.filter = editor.createFilter();
            image.bitmap.alpha = editor.alpha;
            trace(editor);
            draw();
        }
    }

    public function onSearchResultLoad(img: Image, result: BingSearchResult):Void {
        var bm = ImageFigure.fromImage(img);
        bm.thumbSrc = result.Thumbnail.MediaUrl;
        var x = (jq.width()-img.width)/2;
        var y = (jq.height()-img.height)/2;
        insertImage(bm,x,y);
    }

    function onFileLoad (dataUrl: String) {
        var im = ImageFigure.fromUrl(dataUrl);
        insertImage(im,0,0);
    }

    private function resizeCanvas () {
        var w: Float = window.innerWidth;
        var h: Float = window.innerHeight;
        this.jq.attr({
            width : w,
            height: h
        });
        invalidate();
        trace("onWindowChange",w,h);
    }

    public function toggleEditing() {
        isEditing = !isEditing;
    }
    private var mDragBegan = false;
    private var mCapture = new MouseEventCapture();
    function onPanStart (e: HammerEvent) {
        mPressed = true;
        if (!isEditing) {
            if (activeFigure != null) {
                activeFigure = null;
                drawBoundingBox();
            } else {
                var f =  new Figure(e.center.x, e.center.y);
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
                if (d.bounds.containsPoint(e.center.x,e.center.y)) {
                    d.onDragStart(e);
                    tmp = d;
                    mDragBegan = true;
                    break;
                }
                i--;
            }
            activeFigure = tmp;
            drawBoundingBox();
        }
        mCapture.down(e);
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        draw();
    }
    function onMouseMove (e: MouseEvent) {
        if (!isEditing) {
            mBrushCircle.x = e.clientX;
            mBrushCircle.y = e.clientY;
            draw();
        }
    }
    function onPanMove (e: HammerEvent) {
        var toDraw = false;
        if (mPressed) {
            if (!isEditing) {
                if (mDrawingFigure != null) {
                    mDrawingFigure.addPoint(e.center.x,e.center.y);
                    var i = mDrawingFigure.points.length-1;
                    var fp = mDrawingFigure.points[i];
                    toDraw = true;
                }
            } else {
                if (mDragBegan) {
                    activeFigure.onDragMove(e);
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
    function onPanEnd (e: HammerEvent) {
        var toDraw = false;
        if (!isEditing) {
            if (mDrawingFigure != null) {
                mDrawingFigure.addPoint(e.center.x, e.center.y);
                mDrawingFigure.calcVertexes();
                mDrawingFigure.isDrawing = false;
                mDrawingFigure = null;
                toDraw = true;
            }
        } else {
            if (mDragBegan) {
                activeFigure.onDragEnd(e);
                drawBoundingBox();
                toDraw = true;
            }
        }
        if (toDraw) draw();
        mCapture.up(e);
        mDrawingFigure = null;
        mPressed = false;
        mDragBegan = false;
        trigger(ON_CANVAS_MOUSEUP_EVENT);
    }
    public function onCornerDown (e: createjs.easeljs.MouseEvent, corner: Corner): Void {

    }
    public function onCornerMove (e: createjs.easeljs.MouseEvent, corner: Corner, dx: Float, dy: Float): Void {
        var f: Draggable = cast activeFigure;
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
//        mactiveFigure.setScale(scaleX,scaleY,px,py);
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
        if (activeFigure != null) {
            mFigures.remove(activeFigure);
            mMainLayer.removeChild(activeFigure.display);
            mBoundingBox.clear();
            activeFigure = null;
            draw();
        }
    }
}
