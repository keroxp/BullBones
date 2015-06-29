package view;
import haxe.ds.Either;
import createjs.easeljs.DisplayObject;
import model.ZoomEditor;
import createjs.easeljs.Point;
import js.html.WheelEvent;
import js.html.Event;
import js.html.EventListener;
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
    var mStageDebugShape: Shape = new Shape();
    var mMainDebugShape: Shape = new Shape();
    var mDrawingFigure: Figure;
    var mFigures: Array<Draggable> = new Array();
    var mCanvas: CanvasElement;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    var mMoved = false;
    var mDragBegan = false;
    var mScaleBegan = false;
    var mGrabBegan = false;
    var mScaleCorner: Corner;
    var mDirtyRect: Rectangle = new Rectangle();
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
        jq.on("mousewheel", onMouseWheel);
        window.addEventListener("keyup", onKeyUp);
        window.addEventListener("keydown", onKeyDown);
        mCanvas = cast jq.get()[0];
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
        // ファジィグラフ
        mFgLayer.addChild(mFuzzySketchGraph);
        mMainLayer.addChild(mMainDebugShape);
        mMainLayer.addChild(mImageLayer);
        mMainLayer.addChild(mFigureLayer);
        // buffer shape
        mMainLayer.addChild(mBufferShape);
        mStage.addChild(mBgLayer);
        mStage.addChild(mMainLayer);
        mStage.addChild(mFgLayer);
        mStage.addChild(mStageDebugShape);
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
        listenTo(Main.App.v, "change:zoom", onChageZoomEditor);
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
        if (value != null) {
            Log.d(value.display.getTransformedBounds());
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
        set("isEditing", value);
        invalidate();
        return value;
    }

    var scale(get,never): Float;
    function get_scale():Float {
        return Main.App.v.zoom.scale;
    }

    function invalidate () {
        drawBackground();
        drawGrid();
        drawBrushCircle();
        drawBoundingBox();
        showPopupMenu();
        draw(true);
    }
    private var mPrevDirtyRect: Rectangle = new Rectangle();
    function draw (clearAll: Bool = false) {
        if (!clearAll && mDirtyRect == null) return;
        var pad = Main.App.v.brush.width + 10;
        if (clearAll) {
            mDirtyRect = new Rectangle(0,0,mCanvas.width,mCanvas.height);
        }
        mDirtyRect.pad(pad,pad,pad,pad);
        if (Main.App.v.isDebug) {
            mStageDebugShape.graphics
            .clear()
            .beginStroke("red").setStrokeStyle(1)
            .drawRect(mDirtyRect.x+2,mDirtyRect.y+2,mDirtyRect.width-2,mDirtyRect.height-2);
        }
        Reflect.setField(mStage,"drawRect",mDirtyRect.union(mPrevDirtyRect).pad(5,5,5,5));
        mStage.update();
        mPrevDirtyRect = mDirtyRect;
        mDirtyRect = null;
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
        .beginFill(isEditing ? vBackgroundColor : "#fff")
        .drawRoundRect(0,0,mCanvas.width,mCanvas.height,0)
        .endFill();
        extendDirtyRect(0,0,mCanvas.width,mCanvas.height);
    }
    private var mGridDeltaX: Float = 0;
    private var mGridDeltaY: Float = 0;
    function drawGrid (?deltaX: Float = 0, ?deltaY: Float = 0) {
        mGrid.graphics
        .clear()
        .setStrokeStyle(1,0)
        .beginStroke("#fff");
        var i: Float = cast vGridUnit;
        var w = vGridUnit*vGridDivision*scale;
        mGridDeltaX += deltaX;
        if (mGridDeltaX <= -w || w <= mGridDeltaX) {
            mGridDeltaX = mGridDeltaX%w;
        }
        mGridDeltaY += deltaY;
        if (mGridDeltaY <= -w || w <= mGridDeltaY) {
            mGridDeltaY = mGridDeltaY%w;
        }
        var max = Math.max(mCanvas.width,mCanvas.height);
        while (i < max) {
            if (i < mCanvas.width) {
                // vertical
                mGrid.graphics.moveTo(i+0.5+mGridDeltaX,0).lineTo(i+0.5+mGridDeltaX,mCanvas.height);
            }
            if (i < mCanvas.height) {
                mGrid.graphics.moveTo(0,i+0.5+mGridDeltaY).lineTo(mCanvas.width,i+0.5+mGridDeltaY);
            }
            i += vGridUnit*vGridDivision*scale;
        }
        mGrid.graphics.endStroke();
        mGrid.cache(0,0,mCanvas.width,mCanvas.height);
        mGrid.updateCache();
        extendDirtyRect(0,0,mCanvas.width,mCanvas.height);
    }
    function drawBoundingBox () {
        mBoundingBox.clear();
        if (activeFigure != null) {
            var p = mMainLayer.localToLocal(
                activeFigure.display.x,
                activeFigure.display.y,
                mFgLayer
            );
            mBoundingBox.shape.x = p.x;
            mBoundingBox.shape.y = p.y;
            var bounds = activeFigure.display.getTransformedBounds().scale(scale,scale);
            mBoundingBox.render(bounds);
            var g = mMainLayer.localToGlobal(bounds.x,bounds.y);
            extendDirtyRect(g.x,g.y,bounds.width,bounds.height);
        }
    }
    function drawBrushCircle () {
        var w = Main.App.v.brush.width*scale;
        mBrushCircle.graphics
        .clear()
        .setStrokeStyle(1)
        .beginStroke("#000")
        .drawCircle(w/2,w/2,w)
        .endStroke();
        mBrushCircle.cache(-2*w,-2*w,w*4,w*4);
        mBrushCircle.updateCache();
        mBrushCircle.setBounds(0,0,w*2,w*2);
//        var p = mFgLayer.globalToLocal(mCapture.x,mCapture.y);
//        mBrushCircle.x = p.x;
//        mBrushCircle.y = p.y;
    }
    function extendDirtyRect(x: Float, y: Float, ?width: Float = 0, ?height: Float = 0) {
        if (mDirtyRect == null) {
            mDirtyRect = new Rectangle(x,y,width,height);
        } else {
            mDirtyRect.extend(x,y,width,height);
        }
    }
    function extendDirtyRectWithRect(r: Rectangle) {
       extendDirtyRect(r.x,r.y,r.width,r.height);
    }
    function extendDirtyRectWithDisplayObject(o: DisplayObject, ?prevBounds: Rectangle) {
        var b = o.getTransformedBounds();
        var g = o.parent.localToGlobal(b.x,b.y);
        var d = new Rectangle(g.x,g.y,b.width,b.height);
        if (prevBounds != null) {
            var pg = o.parent.localToGlobal(prevBounds.x,prevBounds.y);
            d = d.union(new Rectangle(pg.x,pg.y,prevBounds.width,prevBounds.height));
        }
        extendDirtyRectWithRect(d.scale(scale,scale));
    }
    function insertFigure (f: Draggable) {
        mFigures.push(f);
        if (f.isImageFigure()) {
            mImageLayer.addChild(f.display);
        } else {
            mFigureLayer.addChild(f.display);
        }
        extendDirtyRectWithDisplayObject(f.display);
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
        extendDirtyRectWithDisplayObject(f.display);
        draw();
    }

    function copyFigure(f: Draggable) {
        var fig = f.clone();
        fig.display.x = f.display.x+20;
        fig.display.y = f.display.y+20;
        insertFigure(fig);
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
        extendDirtyRectWithDisplayObject(f.display);
        draw();
    }

    public function onImageEditorChange(editor: ImageEditor):Void {
        if (activeFigure.isImageFigure()) {
            var image: ImageFigure = cast activeFigure;
            image.setFilterAsync(editor.createFilter())
            .done(function(img: ImageElement) {
                extendDirtyRectWithDisplayObject(image.bitmap);
                draw();
            }).fail(function(e) {
                Log.e(e);
            });
        }
    }

    public function onSearchResultLoad(img: Image, result: BingSearchResult):Void {
        var im = ImageFigure.fromImage(img);
        var p =  mMainLayer.globalToLocal(0,0);
        im.display.x = p.x;
        im.display.y = p.y;
        insertFigure(im);
    }

    function onFileLoad (dataUrl: String) {
        var im = ImageFigure.fromUrl(dataUrl);
        var p =  mMainLayer.globalToLocal(0,0);
        im.display.x = p.x;
        im.display.y = p.y;
        insertFigure(im);
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

    function onChageZoomEditor (v: V, val: ZoomEditor, options: Dynamic) {
        if (options.changer == this) {
            applyScaleToLayer(mMainLayer, val.scale, val.pivotX, val.pivotY);
        } else {
            var pivX = mCanvas.width/2;
            var pivY = mCanvas.height/2;
            if (activeFigure != null) {
                var c = activeFigure.display.getTransformedBounds().center();
                var p = mMainLayer.localToGlobal(c.x,c.y);
                pivX = p.x;
                pivY = p.y;
            }
            applyScaleToLayer(mMainLayer, val.scale, pivX, pivY);
        }
        invalidate();
    }

    private function applyScaleToLayer(layer: Container, scale: Float, g_pivX: Float, g_pivY: Float) {
        var piv = layer.globalToLocal(g_pivX,g_pivY);
        layer.scaleX = scale;
        layer.scaleY = scale;
        layer.regX = piv.x;
        layer.regY = piv.y;
        layer.x = g_pivX;
        layer.y = g_pivY;
    }

    function showPopupMenu () {
        if (activeFigure != null) {
            var p = mMainLayer.localToGlobal(
                activeFigure.display.x,
                activeFigure.display.y
            );
            var margin = 20;
            var b = activeFigure.display.getTransformedBounds().scale(scale,scale);
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
        } else {
            mPopupMenu.dismiss(200);
        }
    }

    function getPopupItmes (fig: Draggable): Array<PopupItem> {
        var ret: Array<PopupItem> = [];
        if (fig.type == DraggableType.Image) {
            var hide = new PopupItem("隠す",function(p) {
                thumbnalzieImage(cast fig);
                activeFigure = null;
            });
            ret.push(hide);
        }
        var copy = new PopupItem("コピー", function (p) {
            copyFigure(fig);
            activeFigure = null;
        });
        ret.push(copy);
        var delete = new PopupItem("削除", function (p) {
            deleteFigure(fig);
            activeFigure = null;
        });
        ret.push(delete);
        return ret;
    }

    function onMouseDown (e: MouseEventCapture) {
        mPressed = true;
        var p_main_local = mMainLayer.globalToLocal(e.x,e.y);
        var p_fg_local = mFgLayer.globalToLocal(e.x,e.y);
        if (!isEditing) {
            if (activeFigure != null) {
                activeFigure = null;
                mBoundingBox.clear();
            } else {
                var f =  new Figure(p_main_local.x,p_main_local.y);
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
                return d.display.visible && d.display.getTransformedBounds().containsPoint(p_main_local.x,p_main_local.y);
            });
            if (hitted != null) {
                mDragBegan = true;
                jq.css("cursor", mCurrentPointerCSS = "move");
            } else {
                mGrabBegan = true;
                jq.css("cursor",mCurrentPointerCSS = BrowserUtil.grabbingCursor());
            }
            if (activeFigure != null) {
                mScaleCorner = mBoundingBox.hitsCorner(p_fg_local.x,p_fg_local.y);
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
        m_p_local_main_prev = mMainLayer.globalToLocal(e.x,e.y);
        draw();
    }
    private var mCurrentPointerCSS: String;
    private static var MOVED_THRESH = 2*2;
    private var m_p_local_main_prev: Point;
    function onMouseMove (e: MouseEventCapture) {
        var toDraw = false;
        if (!BrowserUtil.isBrowser()) {
            e.srcEvent.preventDefault();
        }
        var p_local_main = mMainLayer.globalToLocal(e.x,e.y);
        var p_local_main_prev = m_p_local_main_prev;
        var p_local_fg = mFgLayer.globalToLocal(e.x,e.y);
        if (!isEditing) {
            var fp = mFgLayer.globalToLocal(e.x,e.y);
            var pb = mBrushCircle.getTransformedBounds().clone();
            var bw = Main.App.v.brush.width*scale/2;
            mBrushCircle.x = ~~(fp.x+0.5-bw);
            mBrushCircle.y = ~~(fp.y+0.5-bw);
            extendDirtyRectWithDisplayObject(mBrushCircle,pb);
            toDraw = true;
        } else {
            if (this.activeFigure != null) {
                if (mScaleBegan) {}
                var c = mBoundingBox.hitsCorner(p_local_fg.x,p_local_fg.y);
                if (c != null) {
                    if (mCurrentPointerCSS != BoundingBox.getPointerCSS(c)) {
                        jq.css("cursor", mCurrentPointerCSS = BoundingBox.getPointerCSS(c));
                    }
                } else if (activeFigure.display.getTransformedBounds().containsPoint(p_local_main.x,p_local_main.y)){
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
                        mDrawingFigure.addPoint(p_local_main.x,p_local_main.y);
                        var b = Main.App.v.brush;
                        mBufferShape.graphics
                        .setStrokeStyle(b.width,"round", "round")
                        .beginStroke(b.color)
                        .moveTo(p_local_main_prev.x,p_local_main_prev.y)
//                        .lineTo(p_local_main.x,p_local_main.y);
                        .curveTo(p_local_main_prev.x,p_local_main_prev.y,p_local_main.x,p_local_main.y);
                        extendDirtyRect(e.x,e.y);
                        extendDirtyRect(e.prevX,e.prevY);
                        toDraw = true;
                    }
                } else {
                    if (mDragBegan) {
                        var pb = activeFigure.display.getTransformedBounds().clone();
                        activeFigure.display.x += e.deltaX/scale;
                        activeFigure.display.y += e.deltaY/scale;
                        mBoundingBox.shape.x += e.deltaX;
                        mBoundingBox.shape.y += e.deltaY;
                        extendDirtyRectWithDisplayObject(activeFigure.display,pb);
                        toDraw = true;
                    }else if(mGrabBegan) {
                        mMainLayer.x += e.deltaX;
                        mMainLayer.y += e.deltaY;
                        mFgLayer.x += e.deltaX;
                        mFgLayer.y += e.deltaY;
                        drawGrid(e.deltaX,e.deltaY);
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
                            if (p_local_main.x < tBounds.right()) {
                                if (tBounds.right() < p_local_main_prev.x) {
                                    doScaleX(tBounds.right()-e.x);
                                } else {
                                    doScaleX(tBounds.width-e.deltaX/scale);
                                }
                                activeFigure.display.x = p_local_main.x;
                            }
                        }
                        inline function constrainScaleY () {
                            if (p_local_main.y < tBounds.bottom()) {
                                if (tBounds.bottom() < p_local_main_prev.y) {
                                    doScaleY(tBounds.bottom()-p_local_main.y);
                                } else {
                                    doScaleY(tBounds.height-e.deltaY/scale);
                                }
                                activeFigure.display.y = p_local_main.y;
                            }
                        }
                        mScaleCorner.isLeft? constrainScaleX() : doScaleX(tBounds.width+e.deltaX/scale);
                        mScaleCorner.isTop? constrainScaleY() : doScaleY(tBounds.height+e.deltaY/scale);
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
                        extendDirtyRectWithDisplayObject(activeFigure.display,tBounds);
                        drawBoundingBox();
                        toDraw = true;
                    }
                }
                m_p_local_main_prev = p_local_main;
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
                mFigureLayer.addChild(mDrawingFigure.display);
                mDrawingFigure.render();
                extendDirtyRectWithDisplayObject(mDrawingFigure.display,mBufferShape.getTransformedBounds());
                mDrawingFigure = null;
                toDraw = true;
            }
        } else {
            if (mMoved) {
                if (mDragBegan) {
                    drawBoundingBox();
                    toDraw = true;
                } else if (mScaleBegan) {
                    if (activeFigure.type == DraggableType.Figure) {
                        var fig: Figure = cast activeFigure;
                        fig.applyScale().render();
                    }
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
    private function onMouseWheel (e: WheelEvent) {
        var zoom = Main.App.v.zoom;
        var z: ZoomEditor = e.deltaY < 0 ? zoom.zoomIn() : zoom.zoomOut();
        z.pivotX = e.clientX;
        z.pivotY = e.clientY;
        Main.App.v.set("zoom", z, {
            changer: this
        });
        invalidate();
    }
    private var mCurrentKeyEvent: KeyboardEvent;
    function modifiedByShift () : Bool {
        return mCurrentKeyEvent != null && mCurrentKeyEvent.shiftKey;
    }
    function onKeyDown (e: KeyboardEvent) {
        var el: Element = cast e.target;
        if (el.id == "searchInput") return true;
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
                    if (!isEditing) {
                        isEditing = true;
                    }
                }
            }
            mCurrentKeyEvent = e;
            return false;
        }
        return true;
    }
    function onKeyUp (e: KeyboardEvent) {
        var el: Element = cast e.target;
        if (el.id == "searchInput") return true;
        switch e.keyCode {
            case 8: onDelete(e);
            case 69: { // E
                if (isEditing) {
                    isEditing = false;
                }
            }
        }
        mCurrentKeyEvent = null;
        return false;
    }
    function onDelete (e: KeyboardEvent) {
        if (activeFigure != null) {
            deleteFigure(activeFigure);
        }
    }
}
