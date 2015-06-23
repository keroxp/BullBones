package view;
import view.PopupMenu.PopupItem;
import jQuery.JQuery;
import view.PopupMenu.PopupItem;
import util.Log;
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
using util.ArrayUtil;
class MainCanvas extends ViewModel
implements SearchResultListener
implements ImageEditorListener {
    var mStage: Stage;
    var mFgLayer: Container = new Container();
    var mBgLayer: Container = new Container();
    var mMainLayer: Container = new Container();
    var mImageLayer: Container = new Container();
    var mFigureLayer: Container = new Container();
    var mBoundingBox: BoundingBox = new BoundingBox();
    var mFuzzySketchGraph: Shape = new Shape();
    var mBackground: Shape = new Shape();
    var mGrid: Shape = new Shape();
    var mBrushCircle: Shape = new Shape();
    var mBufferShape: Shape = new Shape();
    var mDrawingFigure: Figure;
    var mFigures: Array<Draggable> = new Array();
    var mCanvas: CanvasElement;
    var mContext: CanvasRenderingContext2D;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    var mMoved = false;
    var mDragBegan = false;
    var mScaleBegan = false;
    var mGrabBegan = false;
    var mScaleCorner: Corner;
    var mCapture: MouseEventCapture;
    var window: DOMWindow = Browser.window;
    var mPopupMenu: PopupMenu;
    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEUP_EVENT";

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
        mStage = new Stage(jq.attr("id"));
        // 背景
        mBackground.visible = false;
        mBgLayer.addChild(mBackground);
        // グリッド
        mGrid.visible = false;
        mBgLayer.addChild(mGrid);
        // バウンディングボックス
        mFgLayer.addChild(mBoundingBox.shape);
        // brush
        mFgLayer.addChild(mBrushCircle);
        // buffer shape
        mFgLayer.addChild(mBufferShape);
        // ファジィグラフ
        mFgLayer.addChild(mFuzzySketchGraph);
        mMainLayer.addChild(mImageLayer);
        mMainLayer.addChild(mFigureLayer);
        mStage.addChild(mBgLayer);
        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);

        // UI
        mPopupMenu = new PopupMenu(Main.App.jq);
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

    @:isVar public var activeFigure(get,set):Draggable;
    function get_activeFigure(): Draggable {
        return get("activeFigure");
    }
    function set_activeFigure(value:Draggable) {
        set("activeFigure", value);
        if (value == null && mPopupMenu.isShown) {
            mPopupMenu.dismiss(200);
        }
        invalidate();
        return this.activeFigure = value;
    }

    @:isVar public var isEditing(get,set): Bool = false;
    function get_isEditing(): Bool {
        return get("isEditing");
    }
    function set_isEditing(value:Bool) {
        this.isEditing = value;
        jq.attr("data-editing", value+"");
        if (value) {
            activeFigure = mFigures.findLast(function(e: Draggable) { return e.display.visible; });
        } else {
            activeFigure = null;
        }
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
    function insertFigure (fig: Draggable, x: Float, y: Float) {
        var p = mMainLayer.globalToLocal(x,y);
        fig.display.x = p.x;
        fig.display.y = p.y;
        mFigures.push(fig);
        if (fig.isImageFigure()) {
            mImageLayer.addChild(fig.display);
        } else {
            mFigureLayer.addChild(fig.display);
        }
        draw();
    }
    function deleteFigure(f: Draggable) {
        mFigures.remove(activeFigure);
        if (activeFigure.type == DraggableType.Image) {
            mImageLayer.removeChild(activeFigure.display);
        } else if (activeFigure.type == DraggableType.Figure) {
            mFigureLayer.removeChild(activeFigure.display);
        }
        mBoundingBox.clear();
        activeFigure = null;
        if (f.isImageFigure()) {
            var imf: ImageFigure = cast f;
            Main.App.floatingThumbnailView.remove(imf.image);
        }
        draw();
    }

    function copyFigure(f: Draggable) {
        Log.d("copy");
    }

    function thumbnalzieImage(f: ImageFigure) {
        f.display.visible = false;
        var tv = Main.App.floatingThumbnailView;
        if (!tv.contains(f.image)) {
            tv.add(f.image, function () {
                f.display.visible = true;
                tv.hide(f.image);
                draw();
            });
        } else {
            tv.show(f.image);
        }
        draw();
    }

    public function onImageEditorChange(editor: ImageEditor):Void {
        if (activeFigure.isImageFigure()) {
            var image: ImageFigure = cast activeFigure;
            image.setFilterAsync(editor.createFilter())
            .done(function(img: ImageElement) {
                draw();
            }).fail(function(e) {
                Log.e(e);
            });
        }
    }

    public function onSearchResultLoad(img: Image, result: BingSearchResult):Void {
        var bm = ImageFigure.fromImage(img);
        var x = (jq.width()-img.width)/2;
        var y = (jq.height()-img.height)/2;
        insertFigure(bm,x,y);
    }

    function onFileLoad (dataUrl: String) {
        var im = ImageFigure.fromUrl(dataUrl);
        var x = mCanvas.width/2;
        var y = mCanvas.height/2;
        insertFigure(im,x,y);
    }

    function resizeCanvas () {
        var w: Float = window.innerWidth;
        var h: Float = window.innerHeight;
        this.jq.attr({
            width : w,
            height: h
        });
        invalidate();
        Log.d("onWindowChange"+w+","+h);
    }

    function showPopupMenu () {
        var p = mMainLayer.localToGlobal(
            activeFigure.display.x,
            activeFigure.display.y
        );
        var margin = 20;
        var b = activeFigure.display.getTransformedBounds();
        var w = mPopupMenu.jq.outerWidth();
        var h = mPopupMenu.jq.outerHeight();
        var x = p.x+(b.width-w)*0.5;
        var y = p.y-h-margin;
        var dir = "bottom";
        var o = mMainLayer.globalToLocal(0,0);
        if (p.y < h && mCanvas.height-h < p.y+b.height) {
            dir = "top";
            y = p.y+b.height*0.5;
        } else {
            if (y < o.y) {
                dir = "top";
                y = p.y+b.height+margin;
            }
        }
        mPopupMenu.render(getPopupItmes(activeFigure)).showAt(x,y,dir,300);
    }

    function getPopupItmes (fig: Draggable): Array<PopupItem> {
        var ret: Array<PopupItem> = [];
        if (fig.type == DraggableType.Image) {
            var hide = new PopupItem("隠す",function(p: PopupItem) {
                thumbnalzieImage(cast fig);
                activeFigure = null;
            });
            ret.push(hide);
        }
        var delete = new PopupItem("削除", function (p) {
            deleteFigure(fig);
            activeFigure = null;
        });
        ret.push(delete);
        return ret;
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
            var hitted: Draggable = mFigures.findLast(function(d: Draggable) {
                return d.display.visible && d.display.getTransformedBounds().containsPoint(p.x,p.y);
            });
            if (hitted != null) {
                hitted.onDragStart(e);
                mDragBegan = true;
                jq.css("cursor", mCurrentPointerCSS = "move");
            } else {
                mGrabBegan = true;
                jq.css("cursor",mCurrentPointerCSS = BrowserUtil.grabbingCursor());
            }
            if (activeFigure != null) {
                mScaleCorner = mBoundingBox.hitsCorner(p.x,p.y);
                mScaleBegan = mScaleCorner != null;
                if (mScaleBegan) {
                    mDragBegan = false;
                    mGrabBegan = false;
                }
            }
            if (hitted != null) {
                mBoundingBox.shape.x = hitted.display.x;
                mBoundingBox.shape.y = hitted.display.y;
            }
            if (!mScaleBegan) {
                activeFigure = hitted;
            }
            drawBoundingBox();
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        mBrushCircle.visible = !isEditing;
        draw();
    }
    private var mCurrentPointerCSS: String;
    private static var MOVED_THRESH = 2*2;
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
            if (mMoved) {
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
            } else if (Math.pow(e.totalDeltaX,2)+Math.pow(e.totalDeltaY,2) > MOVED_THRESH) {
                if (mPopupMenu.isShown) {
                    mPopupMenu.dismiss(200);
                }
                mMoved = true;
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
                mFigureLayer.addChild(mDrawingFigure.render().display);
                mDrawingFigure = null;
                toDraw = true;
            }
        } else {
            if (mMoved) {
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
            if (activeFigure != null) {
                showPopupMenu();
            }
        }
        mDrawingFigure = null;
        mBufferShape.graphics.clear();
        mPressed = false;
        mMoved = false;
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
            deleteFigure(activeFigure);
        }
    }
}
