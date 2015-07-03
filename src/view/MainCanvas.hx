package view;
import jQuery.JQuery;
import js.Error;
import command.CopyCommand;
import command.DeleteCommand;
import command.InsertCommand;
import command.Undoable;
import cv.ImageWrap;
import command.FigureCommand;
import command.DisplayCommand;
import createjs.easeljs.DisplayObject;
import model.ZoomEditor;
import createjs.easeljs.Point;
import js.html.WheelEvent;
import view.PopupMenu.PopupItem;
import jQuery.JQuery;
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
import event.MouseEventCapture;
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
import figure.ShapeFigure;
import createjs.easeljs.Stage;
import createjs.easeljs.Shape;
using util.RectangleUtil;
using util.ArrayUtil;
using util.FigureUtil;
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
    var mExportShape: Shape = new Shape();
    var mStageDebugShape: Shape = new Shape();
    var mMainDebugShape: Shape = new Shape();
    var mDrawingFigure: ShapeFigure;
    var mUndoStack: Array<FigureCommand> = new Array();
    var mRedoStack: Array<FigureCommand> = new Array();
    var mCanvas: CanvasElement;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
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

        mFgLayer.addChild(mBoundingBox.shape);
        mFgLayer.addChild(mBrushCircle);
        mFgLayer.addChild(mFuzzySketchGraph);
        mFgLayer.addChild(mExportShape);

        mMainLayer.addChild(mMainDebugShape);
        mMainLayer.addChild(mImageLayer);
        mMainLayer.addChild(mFigureLayer);
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
        listenTo(Main.App.v, "change:isDebug", function () {
            for (f in mFigureLayer.children) {
                f.asShapeFigure(function(shape: ShapeFigure) {
                   shape.render();
                });
            }
            invalidate();
        });
        on("change:isEditing", onChangeEditing);
        Main.App.onFileLoad = onFileLoad;
    }

    @:isVar public var activeFigure(get,set):DisplayObject;
    function get_activeFigure(): DisplayObject {
        return get("activeFigure");
    }
    function set_activeFigure(value:DisplayObject) {
        if (value == null && mPopupMenu.isShown) {
            mPopupMenu.dismiss(200);
        }
        set("activeFigure", value);
        invalidate();
        return value;
    }

    @:isVar public var isEditing(get,set): Bool = false;
    function get_isEditing(): Bool {
        return get("isEditing");
    }
    function set_isEditing(value:Bool) {
        jq.attr("data-editing", value+"");
        mBackground.visible = value;
        mGrid.visible = value;
        mBrushCircle.visible = !value;
        jq.css("cursor","");
        set("isEditing", value);
        invalidate();
        return value;
    }

    @:isVar public var isExporting(get, set): Bool = false;
    function get_isExporting(): Bool {
        return get("isExporting");
    }
    function set_isExporting(value:Bool) {
        set("isExporting",value);
        if (value) {
            jq.css("cursor","crosshair");
        } else {
            jq.css("cursor","");
        }
        mExportShape.visible = value;
        mExportShape.graphics.clear();
        invalidate();
        return value;
    }


    var figures(get,never): Array<DisplayObject>;
    function get_figures():Array<DisplayObject> {
        return mImageLayer.children.concat(mFigureLayer.children);
    }

    function onChangeEditing (m, value: Bool) {
        if (value) {
            activeFigure = figures.findLast(function(e: DisplayObject) { return e.visible; });
        } else {
            activeFigure = null;
        }
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
        mStageDebugShape.graphics.clear();
        if (Main.App.v.isDebug) {
            mStageDebugShape.graphics
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
                activeFigure.x,
                activeFigure.y,
                mFgLayer
            );
            mBoundingBox.shape.x = p.x;
            mBoundingBox.shape.y = p.y;
            var bounds = activeFigure.getTransformedBounds().scale(scale,scale);
            mBoundingBox.render(bounds);
            var g = mMainLayer.localToGlobal(bounds.x,bounds.y);
            extendDirtyRect(g.x,g.y,bounds.width,bounds.height);
        }
    }
    function drawBrushCircle () {
        var w = Main.App.v.brush.width*scale;
        mBrushCircle.graphics
        .clear()
        .setStrokeStyle(1,"round", "round")
        .beginStroke(mPressed ? "#2196F3" : "#000")
        .drawCircle(w/2+1,w/2+1,w/2)
        .endStroke();
        mBrushCircle.cache(0,0,w+2,w+2);
        mBrushCircle.updateCache();
        mBrushCircle.setBounds(0,0,w+2,w+2);
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
    function insertFigure (f: DisplayObject) {
        if (f == null) {
            throw new Error("attempt to insert null figure");
        }
        var cmd = new InsertCommand(f).exec(function(arg) {
            if (f.isImageFigure()) {
                mImageLayer.addChild(f);
            } else {
                mFigureLayer.addChild(f);
            }
        });
        pushCommand(cmd);
        extendDirtyRectWithDisplayObject(f);
        draw();
    }
    function deleteFigure(f: DisplayObject) {
        if (f == null) return;
        extendDirtyRectWithDisplayObject(f);
        var cmd = new DeleteCommand(f).exec(function(a) {
            if (activeFigure.isImageFigure()) {
                mImageLayer.removeChild(activeFigure);
            } else if (activeFigure.isShapeFigure()) {
                mFigureLayer.removeChild(activeFigure);
            }
        });
        pushCommand(cmd);
        mBoundingBox.clear();
        activeFigure = null;
        f.asImageFigure(function(imf: ImageFigure) {
            Main.App.floatingThumbnailView.remove(imf.imageWrap);
        });
        draw();
    }

    function copyFigure(f: DisplayObject) {
        var cmd = new CopyCommand(f).exec(function(a){
            var fig = f.clone();
            fig.x = f.x+20;
            fig.y = f.y+20;
            insertFigure(fig);
            return fig;
        });
        pushCommand(cmd);
    }

    function thumbnalzieImage(f: ImageFigure) {
        f.visible = false;
        var tv = Main.App.floatingThumbnailView;
        if (!tv.contains(f.imageWrap)) {
            tv.add(f.imageWrap, function () {
                f.visible = true;
                tv.hide(f.imageWrap);
                extendDirtyRectWithDisplayObject(f);
                draw();
            });
        } else {
            tv.show(f.imageWrap);
        }
        extendDirtyRectWithDisplayObject(f);
        draw();
    }

    public function pushCommand(cmd: FigureCommand) {
        mUndoStack.push(cmd);
        mRedoStack.splice(0,mRedoStack.length);
    }

    public function undo() {
        var cmd = mUndoStack.pop();
        if (cmd != null) {
            mRedoStack.push(cmd);
            var af = null;
            if (cmd.isInsertCommand() || cmd.isCopyCommand()) {
                var p: Container = cmd.target.isShapeFigure() ? mFigureLayer : mImageLayer;
                var i = p.getChildIndex(cmd.target);
                if (cmd.isInsertCommand()) {
                    i -= 1;
                }
                af = i < p.children.length ? p.getChildAt(i) : null;
            } else {
                af = cmd.target;
            }
            Reflect.callMethod(cmd, Reflect.field(cmd,"undo"),[]);
            if (isEditing) {
                activeFigure = af;
            } else {
                invalidate();
            }
        }
    }

    public function redo() {
        var cmd = mRedoStack.pop();
        if (cmd != null) {
            Reflect.callMethod(cmd, Reflect.field(cmd, "redo"),[]);
            mUndoStack.push(cmd);
            var af = null;
            if (cmd.isDeleteCommand()) {
                var p: Container = cmd.target.isShapeFigure() ? mFigureLayer : mImageLayer;
                var i = p.getChildIndex(cmd.target) - 1;
                af = i < p.children.length ? p.getChildAt(i) : null;
            } else {
                af = cmd.target;
                if (cmd.isCopyCommand()) {
                    var i = cmd.target.parent.getChildIndex(cmd.target);
                    af = cmd.target.parent.getChildAt(i+1);
                }
            }
            if (isEditing) {
                activeFigure = af;
            } else {
                invalidate();
            }
        }
    }

    public function onImageEditorChange(editor: ImageEditor):Void {
        if (activeFigure.isImageFigure()) {
            var image: ImageFigure = cast activeFigure;
            image.setFilterAsync(editor.createFilter())
            .done(function(img: ImageElement) {
                image.alpha = editor.alpha;
                extendDirtyRectWithDisplayObject(image);
                draw();
            }).fail(function(e) {
                Log.e(e);
            });
        }
    }

    public function onSearchResultLoad(img: ImageWrap, result: BingSearchResult):Void {
        var im = new ImageFigure(img);
        var p =  mMainLayer.globalToLocal(0,0);
        im.x = p.x;
        im.y = p.y;
        insertFigure(im);
    }

    function onFileLoad (img: ImageWrap) {
        var im = new ImageFigure(img);
        var p =  mMainLayer.globalToLocal(0,0);
        im.x = p.x;
        im.y = p.y;
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

    function exportImage (x: Float, y: Float, w: Float, h: Float) {
        var ec: CanvasElement = cast BrowserUtil.document.createElement("canvas");
        ec.width = cast w;
        ec.height = cast h;
        var es = new Stage(ec);
        var ml = mMainLayer.clone(true);
        ml.scaleX = 1.0;
        ml.scaleY = 1.0;
        ml.regX = 0;
        ml.regY = 0;
        ml.x = -x;
        ml.y = -y;
        es.addChild(ml);
        es.update();
        var url = es.toDataURL("rgba(0,0,0,0)","image/png");
        Main.App.modalView.confirmExporting(url, function(result: Bool) {
            if (result) {
                window.open(url);
            }
            url = null;
        }).open();
        es = null;
        ec = null;
    }

    function onChageZoomEditor (v: V, val: ZoomEditor, options: Dynamic) {
        if (options.changer == this) {
            applyScaleToLayer(mMainLayer, val.scale, val.pivotX, val.pivotY);
        } else {
            var pivX = mCanvas.width/2;
            var pivY = mCanvas.height/2;
            if (activeFigure != null) {
                var c = activeFigure.getTransformedBounds().center();
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
                activeFigure.x,
                activeFigure.y
            );
            var margin = 20;
            var b = activeFigure.getTransformedBounds().scale(scale,scale);
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

    function getPopupItmes (fig: DisplayObject): Array<PopupItem> {
        var ret: Array<PopupItem> = [];
        if (fig.isImageFigure()) {
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

    var mDisplayCommand: DisplayCommand;
    function onMouseDown (e: MouseEventCapture) {
        mPressed = true;
        var p_main_local = mMainLayer.globalToLocal(e.x,e.y);
        var p_fg_local = mFgLayer.globalToLocal(e.x,e.y);
        if (!isExporting) {
            if (!isEditing) {
                if (activeFigure != null) {
                    activeFigure = null;
                    mBoundingBox.clear();
                } else {
                    var f =  new ShapeFigure(p_main_local.x,p_main_local.y);
                    f.width = Main.App.v.brush.width;
                    f.color = Main.App.v.brush.color;
                    if (Main.App.v.isDebug) {
                        drawFuzzyPointGraph(f.points[0],0);
                    }
                    mDrawingFigure = f;
                    drawBrushCircle();
                }
            } else {
                var hitted: DisplayObject = figures.findLast(function(d: DisplayObject) {
                    return d.visible && d.getTransformedBounds().containsPoint(p_main_local.x,p_main_local.y);
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
                    mBoundingBox.shape.x = hitted.x;
                    mBoundingBox.shape.y = hitted.y;
                }
                if (mDragBegan) {
                    mDisplayCommand = new DisplayCommand(hitted);
                } else if (mScaleBegan) {
                    mDisplayCommand = new DisplayCommand(activeFigure);
                }
                if (!mScaleBegan) {
                    activeFigure = hitted;
                }
                drawBoundingBox();
            }
            mBrushCircle.visible = !isEditing;
        } else {
            // during export
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        draw();
    }
    private var mCurrentPointerCSS: String;
    private static var MOVED_THRESH = 2*2;
    function onMouseMove (e: MouseEventCapture) {
        var toDraw = false;
        if (!BrowserUtil.isBrowser()) {
            e.srcEvent.preventDefault();
        }
        var p_local_main = mMainLayer.globalToLocal(e.x,e.y);
        var p_local_main_prev = mMainLayer.globalToLocal(e.prevX,e.prevY);
        var p_local_fg = mFgLayer.globalToLocal(e.x,e.y);
        if (!isExporting) {
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
                    var c = mBoundingBox.hitsCorner(p_local_fg.x,p_local_fg.y);
                    if (c != null) {
                        if (mCurrentPointerCSS != BoundingBox.getPointerCSS(c)) {
                            jq.css("cursor", mCurrentPointerCSS = BoundingBox.getPointerCSS(c));
                        }
                    } else if (activeFigure.getTransformedBounds().containsPoint(p_local_main.x,p_local_main.y)){
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
                        var pb = activeFigure.getTransformedBounds().clone();
                        activeFigure.x += e.deltaX/scale;
                        activeFigure.y += e.deltaY/scale;
                        mBoundingBox.shape.x += e.deltaX;
                        mBoundingBox.shape.y += e.deltaY;
                        extendDirtyRectWithDisplayObject(activeFigure,pb);
                        mPopupMenu.dismiss(200);
                        toDraw = true;
                    }else if(mGrabBegan) {
                        mMainLayer.x += e.deltaX;
                        mMainLayer.y += e.deltaY;
                        mFgLayer.x += e.deltaX;
                        mFgLayer.y += e.deltaY;
                        drawGrid(e.deltaX,e.deltaY);
                        mPopupMenu.dismiss(200);
                        toDraw = true;
                    } else if (mScaleBegan) {
                        var tBounds = activeFigure.getTransformedBounds().clone();
                        inline function doScaleX (width: Float) {
                            var sx = width/tBounds.width;
                            if (0 < sx) {
                                activeFigure.scaleX *= sx;
                            }
                        }
                        inline function doScaleY (height: Float) {
                            var sy = height/tBounds.height;
                            if (0 < sy) {
                                activeFigure.scaleY *= sy;
                            }
                        }
                        inline function constrainScaleX () {
                            if (p_local_main.x < tBounds.right()) {
                                if (tBounds.right() < p_local_main_prev.x) {
                                    doScaleX(tBounds.right()-e.x);
                                } else {
                                    doScaleX(tBounds.width-e.deltaX/scale);
                                }
                                activeFigure.x = p_local_main.x;
                            }
                        }
                        inline function constrainScaleY () {
                            if (p_local_main.y < tBounds.bottom()) {
                                if (tBounds.bottom() < p_local_main_prev.y) {
                                    doScaleY(tBounds.bottom()-p_local_main.y);
                                } else {
                                    doScaleY(tBounds.height-e.deltaY/scale);
                                }
                                activeFigure.y = p_local_main.y;
                            }
                        }
                        mScaleCorner.isLeft? constrainScaleX() : doScaleX(tBounds.width+e.deltaX/scale);
                        mScaleCorner.isTop? constrainScaleY() : doScaleY(tBounds.height+e.deltaY/scale);
                        if (modifiedByShift()) {
                            var d = activeFigure;
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
                        extendDirtyRectWithDisplayObject(activeFigure,tBounds);
                        drawBoundingBox();
                        toDraw = true;
                    }
                }
            }
        } else {
            if (mPressed) {
                // during export
                var x = e.totalDeltaX < 0 ? e.startX+e.totalDeltaX : e.startX;
                var y = e.totalDeltaY < 0 ? e.startY+e.totalDeltaY : e.startY;
                var w = e.totalDeltaX < 0 ? -e.totalDeltaX : e.totalDeltaX;
                var h = e.totalDeltaY < 0 ? -e.totalDeltaY : e.totalDeltaY;
                var p = mFgLayer.globalToLocal(x,y);
                mExportShape.alpha = 0.4;
                mExportShape.graphics
                .clear()
                .beginFill("#000")
                .drawRoundRect(p.x,p.y,w,h,0)
                .endFill();
                extendDirtyRect(x,y,w,h);
                toDraw = true;
            }
        }
        if (toDraw) draw();
        trigger(ON_CANVAS_MOUSEMOVE_EVENT);
    }
    function onMouseUp (e: MouseEventCapture) {
        var toDraw = false;
        if (!isExporting) {
            if (!isEditing) {
                if (mDrawingFigure != null && mDrawingFigure.points.length > 1) {
                    mDrawingFigure.calcVertexes();
                    insertFigure(mDrawingFigure);
                    mDrawingFigure.render();
                    extendDirtyRectWithDisplayObject(mDrawingFigure,mBufferShape.getTransformedBounds());
                }
                toDraw = true;
                mDrawingFigure = null;
            } else {
                if (mDragBegan) {
                    drawBoundingBox();
                    toDraw = true;
                } else if (mScaleBegan) {
                    activeFigure.asShapeFigure(function(shape: ShapeFigure) {
                        shape.applyScale().render();
                    });
                    drawBoundingBox();
                    toDraw = true;
                } else if (mGrabBegan) {
                    jq.css("cursor", BrowserUtil.grabCursor());
                }
                if (activeFigure != null) {
                    showPopupMenu();
                }
            }
            if (mDisplayCommand != null) {
                pushCommand(mDisplayCommand.exec(null));
            }
        } else {
            // during exporting
            var z = Main.App.v.zoom;
            var lp = mMainLayer.globalToLocal(e.startX,e.startY);
            var x = lp.x;
            var y = lp.y;
            var w = Math.abs(e.totalDeltaX/z.scale);
            var h = Math.abs(e.totalDeltaY/z.scale);
            exportImage(lp.x,lp.y,w,h);
            isExporting = false;
        }
        mDisplayCommand = null;
        mDrawingFigure = null;
        mBufferShape.graphics.clear();
        mPressed = false;
        mDragBegan = false;
        mScaleCorner = null;
        mScaleBegan = false;
        mGrabBegan = false;
        mBrushCircle.visible = BrowserUtil.isBrowser() && !isEditing;
        drawBrushCircle();
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
    function modifiedByCmdOrCtrl (e: KeyboardEvent): Bool {
        return (e.ctrlKey && !e.metaKey) || (!e.ctrlKey && e.metaKey);
    }
    function onKeyDown (e: KeyboardEvent) {
        var el: Element = cast e.target;
        if (el.id == "searchInput") return true;
        if (mCurrentKeyEvent == null) {
            switch e.keyCode {
                case 69: { // E
                    if (!isEditing) {
                        isEditing = true;
                    }
                }
                case 90: { // Z
                    if (e.shiftKey) {
                        redo();
                    } else {
                        undo();
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
            case 8: deleteFigure(activeFigure);
            case 69: { // E
                if (isEditing) {
                    isEditing = false;
                }
            }
        }
        mCurrentKeyEvent = null;
        return false;
    }
}
