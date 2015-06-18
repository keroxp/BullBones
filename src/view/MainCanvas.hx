package view;
import createjs.easeljs.Rectangle;
import createjs.easeljs.Matrix2D;
import js.html.ImageElement;
import util.BrowserUtil;
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
using figure.Draggable.DraggableUtil;
using util.RectangleUtil;
class MainCanvas extends ViewModel
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
    var mBufferShape: Shape;
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    var mDragBegan = false;
    var mScaleBegan = false;
    var mGrabBegan = false;
    var mScaleCorner: Corner;
    var mCapture: MouseEventCapture;
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
        jq.css("cursor","");
        drawBoundingBox();
        drawBrushCircle();
        draw();
        set("isEditing", value);
        return value;
    }

    public function new(jq: JQuery) {
        super(jq);
        var window: DOMWindow = js.Browser.window;
        var cap = new MouseEventCapture();
        cap.onDown(el,onMouseDown);
        cap.onMove(el,onMouseMove);
        cap.onUp(el,onMouseUp);
        mCapture = cap;
        window.addEventListener("keyup", onKeyUp);
        window.addEventListener("keydown", onKeyDown);

        mCanvas = cast jq.get()[0];
        mContext = mCanvas.getContext("2d");
        mBgLayer = new Container();
        mFgLayer = new Container();
        mBufferShape = new Shape();
        mMainLayer = new Container();
        mMainLayer.addChild(mBufferShape);
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
        .setStrokeStyle(1,0)
        .beginStroke("#fff");
        var i = vGridUnit;
        var max = Math.max(mCanvas.width,mCanvas.height);
        while (i < max) {
            if (i < mCanvas.width) {
                // vertical
                mGrid.graphics.moveTo(i+0.5,0).lineTo(i+0.5,mCanvas.height);
            }
            if (i < mCanvas.height) {
                mGrid.graphics.moveTo(0,i+0.5).lineTo(mCanvas.width,i+0.5);
            }
            i += vGridUnit*vGridDivision;
        }
        mGrid.graphics.endStroke();
        mGrid.cache(0,0,mCanvas.width,mCanvas.height);
        mGrid.updateCache();
    }
    function drawBoundingBox () {
        mBoundingBox.clear();
        if (activeFigure != null) {
            mBoundingBox.shape.x = activeFigure.display.x;
            mBoundingBox.shape.y = activeFigure.display.y;
            mBoundingBox.render(activeFigure.display);
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
        mBrushCircle.cache(-2*w,-2*w,w*4,w*4);
        mBrushCircle.updateCache();
        var p = mFgLayer.globalToLocal(mCapture.x,mCapture.y);
        mBrushCircle.x = p.x;
        mBrushCircle.y = p.y;
    }
    function insertImage (img: ImageFigure, x: Float, y: Float) {
        img.bitmap.x = x;
        img.bitmap.y = y;
        mFigures.push(img);
        mMainLayer.addChild(img.bitmap);
        mStage.update();
    }
    public function onImageEditorChange(editor: ImageEditor):Void {
        if (activeFigure.isImageFigure()) {
            var image: ImageFigure = cast activeFigure;
            image.setFilterAsync(editor.createFilter())
            .done(function(img: ImageElement) {
                draw();
            }).fail(function(e) {
                trace(e);
            });
        }
    }

    public function onSearchResultLoad(img: Image, result: BingSearchResult):Void {
        var bm = ImageFigure.fromImage(img);
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
    function onMouseDown (e: MouseEventCapture) {
        mPressed = true;
        var p = mMainLayer.globalToLocal(e.x,e.y);
        if (!isEditing) {
            if (activeFigure != null) {
                activeFigure = null;
                drawBoundingBox();
            } else {
                var f =  new Figure(p.x,p.y);
                f.width = Main.App.v.brush.width;
                f.color = Main.App.v.brush.color;
                mFigures.push(f);
                if (Main.App.v.isDebug) {
                    drawFuzzyPointGraph(f.points[0],0);
                }
                mDrawingFigure = f;
            }
        } else {
            var i = mFigures.length-1;
            var tmp: Draggable = null;
            while (i > -1) {
                var d = mFigures[i];
                if (d.display.getTransformedBounds().containsPoint(p.x,p.y)) {
                    d.onDragStart(e);
                    tmp = d;
                    mDragBegan = true;
                    break;
                }
                i--;
            }
            mScaleCorner = mBoundingBox.hitsCorner(p.x,p.y);
            mScaleBegan = mScaleCorner != null;
            if (mScaleBegan) {
                mDragBegan = false;
            } else {
                activeFigure = tmp;
                mGrabBegan = true;
                jq.css("cursor",mCurrentPointerCSS = BrowserUtil.grabbingCursor());
            }
            if (mDragBegan) {
                jq.css("cursor", mCurrentPointerCSS = "move");
            }
            if (activeFigure != null) {
                mBoundingBox.shape.x = activeFigure.display.x;
                mBoundingBox.shape.y = activeFigure.display.y;
            }
            drawBoundingBox();
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        mBrushCircle.visible = !isEditing;
        draw();
    }
    private var mCurrentPointerCSS: String;
    function onMouseMove (e: MouseEventCapture) {
        var toDraw = false;
        if (!BrowserUtil.isBrowser()) {
            e.srcEvent.preventDefault();
        }
        var localP = mMainLayer.globalToLocal(e.x,e.y);
        var localPrevP = mMainLayer.globalToLocal(e.prevX,e.prevY);
        if (!isEditing) {
            var fp = mFgLayer.globalToLocal(e.x,e.y);
            mBrushCircle.x = fp.x;
            mBrushCircle.y = fp.y;
            toDraw = true;
        } else {
            if (this.activeFigure != null) {
                if (mScaleBegan) {}
                var c = mBoundingBox.hitsCorner(localP.x,localP.y);
                if (c != null) {
                    if (mCurrentPointerCSS != BoundingBox.getPointerCSS(c)) {
                        jq.css("cursor", mCurrentPointerCSS = BoundingBox.getPointerCSS(c));
                    }
                } else if (activeFigure.display.getTransformedBounds().containsPoint(localP.x,localP.y)){
                    if (mCurrentPointerCSS != "move") {
                        jq.css("cursor", mCurrentPointerCSS = "move");
                    }
                } else if (mCurrentPointerCSS != BrowserUtil.grabCursor()) {
                    jq.css("cursor", mCurrentPointerCSS = BrowserUtil.grabCursor());
                }
            }
        }
        if (mPressed) {
            if (!isEditing) {
                if (mDrawingFigure != null) {
                    mDrawingFigure.addPoint(localP.x,localP.y);
                    var b = Main.App.v.brush;
                    mBufferShape.graphics
                    .setStrokeStyle(b.width,"round",1)
                    .beginStroke(b.color)
                    .moveTo(localPrevP.x,localPrevP.y)
                    .lineTo(localP.x,localP.y);
                    var i = mDrawingFigure.points.length-1;
                    var fp = mDrawingFigure.points[i];
                    toDraw = true;
                }
            } else {
                if (mDragBegan) {
                    activeFigure.onDragMove(e);
                    mBoundingBox.shape.x += e.deltaX;
                    mBoundingBox.shape.y += e.deltaY;
                    toDraw = true;
                }else if(mGrabBegan) {
                    mMainLayer.x += e.deltaX;
                    mMainLayer.y += e.deltaY;
                    mFgLayer.x += e.deltaX;
                    mFgLayer.y += e.deltaY;
                    toDraw = true;
                } else if (mScaleBegan) {
                    var tBounds = activeFigure.display.getTransformedBounds().clone();
                    inline function doScaleX (width: Float) {
                        var sx = width/tBounds.width;
                        if (0 < sx) {
                            activeFigure.display.scaleX *= sx;
                        }
                    }
                    inline function doScaleY (height: Float) {
                        var sy = height/tBounds.height;
                        if (0 < sy) {
                            activeFigure.display.scaleY *= sy;
                        }
                    }
                    inline function constrainScaleX () {
                        if (localP.x < tBounds.right()) {
                            if (tBounds.right() < localPrevP.x) {
                                doScaleX(tBounds.right()-e.x);
                            } else {
                                doScaleX(tBounds.width-e.deltaX);
                            }
                            activeFigure.display.x = localP.x;
                        }
                    }
                    inline function constrainScaleY () {
                        if (localP.y < tBounds.bottom()) {
                            if (tBounds.bottom() < localPrevP.y) {
                                doScaleY(tBounds.bottom()-localP.y);
                            } else {
                                doScaleY(tBounds.height-e.deltaY);
                            }
                            activeFigure.display.y = localP.y;
                        }
                    }
                    mScaleCorner.isLeft? constrainScaleX() : doScaleX(tBounds.width+e.deltaX);
                    mScaleCorner.isTop? constrainScaleY() : doScaleY(tBounds.height+e.deltaY);
                    if (modifiedByShift()) {
                        var d = activeFigure.display;
                        var s = (d.scaleX+d.scaleY)*0.5;
                        var oBounds = d.getBounds();
                        d.scaleX = d.scaleY = s;
                        var w = oBounds.width*s;
                        var h = oBounds.height*s;
                        if (mScaleCorner.isLeft) {
                            d.x = tBounds.right()-w;
                        }
                        if (mScaleCorner.isTop) {
                            d.y = tBounds.bottom()-h;
                        }
                    }
                    drawBoundingBox();
                    toDraw = true;
                }
            }
        }
        if (toDraw) draw();
        trigger(ON_CANVAS_MOUSEMOVE_EVENT);
    }
    function onMouseUp (e: MouseEventCapture) {
        var toDraw = false;
        if (!isEditing) {
            if (mDrawingFigure != null) {
                mDrawingFigure.calcVertexes();
                mDrawingFigure.isDrawing = false;
                mMainLayer.addChild(mDrawingFigure.render().display);
                mDrawingFigure = null;
                toDraw = true;
            }
        } else {
            if (mDragBegan) {
                activeFigure.onDragEnd(e);
                drawBoundingBox();
                toDraw = true;
            } else if (mScaleBegan) {
                drawBoundingBox();
                toDraw = true;
            } else if (mGrabBegan) {
                jq.css("cursor", BrowserUtil.grabCursor());
            }
        }
        mDrawingFigure = null;
        mBufferShape.graphics.clear();
        mPressed = false;
        mDragBegan = false;
        mScaleCorner = null;
        mScaleBegan = false;
        mGrabBegan = false;
        mBrushCircle.visible = BrowserUtil.isBrowser() && !isEditing;
        trigger(ON_CANVAS_MOUSEUP_EVENT);
        if (toDraw) draw();
    }
    private var mCurrentKeyEvent: KeyboardEvent;
    function modifiedByShift () : Bool {
        return mCurrentKeyEvent != null && mCurrentKeyEvent.shiftKey;
    }
    function onKeyDown (e: KeyboardEvent) {
        if (mCurrentKeyEvent == null) {
            switch e.keyCode {
                case 16: {
                    if (activeFigure != null && mScaleBegan && activeFigure.display.scaleX != activeFigure.display.scaleY) {
                        var d = activeFigure.display;
                        d.scaleX = d.scaleY = (d.scaleX+d.scaleY)*0.5;
                        drawBoundingBox();
                        draw();
                    }
                }
                case 69: { // E
                    e.preventDefault();
                    e.stopPropagation();
                    isEditing = true;
                }
            }
            mCurrentKeyEvent = e;
            return false;
        }
        return true;
    }
    function onKeyUp (e: KeyboardEvent) {
        switch e.keyCode {
            case 8: onDelete(e);
            case 69: { // E
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
