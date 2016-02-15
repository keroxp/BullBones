package canvas;
import figure.FigureType;
import canvas.tools.ScaleTool;
import canvas.tools.GrabTool;
import canvas.tools.DragTool;
import command.Undoable;
import figure.Layer;
import canvas.CanvasToolType;
import canvas.tools.BrushTool;
import js.html.UIEvent;
import view.PopupMenu;
import util.CursorUtil;
import geometry.Scalar;
import figure.PivotShape;
import model.MirroringInfo;
import js.html.Window;
import rollbar.Rollbar;
import ajax.Uploader;
import jQuery.JQuery;
import js.Error;
import command.CopyLayerCommand;
import command.DeleteLayerCommand;
import command.InsertLayerCommand;
import cv.ImageWrap;
import createjs.easeljs.DisplayObject;
import model.ZoomEditor;
import createjs.easeljs.Point;
import js.html.WheelEvent;
import view.PopupMenu.PopupItem;
import util.Log;
import createjs.easeljs.Rectangle;
import util.BrowserUtil;
import js.Browser;
import figure.ImageFigure;
import model.ImageEditor;
import view.SearchView.SearchResultListener;
import view.ViewModel;
import ajax.BingSearch.BingSearchResult;
import js.html.Element;
import createjs.easeljs.Container;
import figure.BoundingBox;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import figure.ShapeFigure;
import createjs.easeljs.Stage;
import createjs.easeljs.Shape;
using util.RectangleUtil;
using util.ArrayUtil;
using util.UndoableUtil;
using figure.Figures;

/*
Layer Structure
[Stage]
  [Foreground Container]
    SymmetryPivotShape
    BrushCircleShape
    BoudingBox
  [Main Container]
    [Layer Container]
        - Layer 1
        - Layer 2
        - ...
  [Background Container]
    GridShape
    BackgroundShape
 */
@:allow(canvas.tools)
class MainCanvas extends ViewModel
implements SearchResultListener {
    var mStage: Stage;
    var mFgContainer: Container = new Container();
    var mBgContainer: Container = new Container();
    var mMainContainer: Container = new Container();
    var mLayerContainer: Container = new Container();
    var mBoundingBox: BoundingBox = new BoundingBox();
    var mFuzzySketchGraph: Shape = new Shape();
    var mBackground: Shape = new Shape();
    var mGrid: Shape = new Shape();
    var mBrushCircle: Shape = new Shape();
    var mMirrorPivotShape: PivotShape = new PivotShape();
    var mUndoStack: Array<Undoable> = new Array<Undoable>();
    var mRedoStack: Array<Undoable> = new Array<Undoable>();
    var mCanvas: CanvasElement;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    var mHasDirtyRect = false;
    var mDirtyRect: Rectangle = new Rectangle();
    var mPrevDirtyRect: Rectangle = new Rectangle();
    var mCapture: CanvasMouseEvent;
    var window = BrowserUtil.window;
    var mPopupMenu: PopupMenu;
    var mActiveTool: CanvasTool;
    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null) = "ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null) = "ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null) = "ON_CANVAS_MOUSEUP_EVENT";
    public static var ON_INSERT_EVENT(default,null) = "ON_INSERT_EVENT";
    public static var ON_COPY_EVENT(default,null) = "ON_COPY_EVENT";
    public static var ON_DELETE_EVENT(default,null) = "ON_DELETE_EVENT";

    public var mirroringInfo(default, null): MirroringInfo = new MirroringInfo();

    public function new(jq: JQuery) {
        super(jq, {
            activeLayer: null,
            toolType: Brush,
            isEditing: false,
            isExporting: false
        });
        var cap = new CanvasMouseEvent();
        cap.onDown(window,onMouseDown, function(e: UIEvent) {
            return cast(e.target, Element).id == el.id;
        });
        cap.onMove(window,onMouseMove);
        cap.onUp(window,onMouseUp, function (e: UIEvent) {
            return mPressed;
        });
        mCapture = cap;
        jq.on("mousewheel", onMouseWheel);
        window.addEventListener("keyup", onKeyUp);
        window.addEventListener("keydown", onKeyDown);
        mCanvas = cast jq.get()[0];
        mStage = new Stage(jq.attr("id"));
        // 背景
        mBackground.visible = false;
        mBgContainer.addChild(mBackground);
        // グリッド
        mGrid.visible = false;
        mBgContainer.addChild(mGrid);

        mFgContainer.addChild(mBoundingBox);
        mBrushCircle.visible = false;
        mFgContainer.addChild(mBrushCircle);
        mFgContainer.addChild(mFuzzySketchGraph);
        mMirrorPivotShape.render();
        mMirrorPivotShape.visible = false;
        mFgContainer.addChild(mMirrorPivotShape);

        mMainContainer.addChild(mLayerContainer);

        mStage.addChild(mBgContainer);
        mStage.addChild(mMainContainer);
        mStage.addChild(mFgContainer);
        // UI
        mPopupMenu = new PopupMenu(Main.App.jUILayer);
        // reset drawing
        resizeCanvas();
        invalidate();

    }

    override public function init() {
        // event observing
        listenTo(Main.App.model, "change:brush", drawBrushCircle);
        listenTo(Main.App, App.APP_WINDOW_RESIZE_EVENT, resizeCanvas);
        listenTo(Main.App.model, "change:zoom", onChageZoomEditor);
        listenTo(Main.App.model, "change:isDebug", function () {
            for (f in mLayerContainer.children) {
                cast(f, Layer).render();
            }
            invalidate();
        });
        listenTo(mirroringInfo, "change:pivotEnabled", function(m: MirroringInfo, val: Bool) {
            mMirrorPivotShape.visible = val;
            extendDirtyRectWithDisplayObject(mMirrorPivotShape);
            mMirrorPivotShape.adjustPivot(m.pivotX,m.pivotY);
            extendDirtyRectWithDisplayObject(mMirrorPivotShape);
            requestDraw("change:pivotEnabled", draw);
        });
        var piv = mFgContainer.globalToLocal(
            mCanvas.width*0.5,
            mCanvas.height*0.5
        );
        mirroringInfo.pivotX = piv.x;
        mirroringInfo.pivotY = piv.y;

    }

    public function onStart() {
        var layer = new Layer();
        insertLayer(layer,true);
    }

    @:isVar public var activeLayer(get,set):Layer;
    function get_activeLayer(): Layer {
        return get("activeLayer");
    }
    function set_activeLayer(value:Layer) {
        trace("set_activeLayer", value);
        if (activeLayer == value) return value;
        if (value == null && mPopupMenu.isShown) {
            mPopupMenu.dismiss(200);
        }
        drawBoundingBox(value);
        if (isEditing) {
            showPopupMenu(value);
        }
        extendDirtyRectWithDisplayObject(value != null ? value : activeLayer);
        requestDraw("setActiveLayer", draw);
        set("activeLayer", value);
        return value;
    }

    @:isVar public var toolType(get, set):CanvasToolType;
    function get_toolType():CanvasToolType {
        return get("toolType");
    }
    function set_toolType(value:CanvasToolType) {
        set("toolType", value);
        return value;
    }

    @:isVar public var isEditing(get,set): Bool;
    function get_isEditing(): Bool {
        return get("isEditing");
    }
    function set_isEditing(value:Bool) {
        trace("set_isEditing", value);
        if (value == isEditing) return value;
        jq.attr("data-editing", value+"");
        mBackground.visible = value;
        mGrid.visible = value;
        mBrushCircle.visible = !value;
        jq.css("cursor","");
        set("isEditing", value);
        invalidate();
        return value;
    }

    @:isVar public var isExporting(get, set): Bool;
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
        var buf = getBufferShape(mFgContainer);
        buf.visible = value;
        buf.graphics.clear();
        invalidate();
        return value;
    }

    var scale(get,never): Float;
    inline function get_scale():Float return Main.App.model.zoom.scale;
    
    function invalidate () {
        mBoundingBox.clear();
        mPopupMenu.dismiss();
        mGrid.graphics.clear();
        drawBackground();
        if (!isEditing) {
            drawBrushCircle();
        } else {
            drawGrid();
            drawBoundingBox(activeLayer);
            showPopupMenu(activeLayer);
        }
        requestDraw("invalidate", draw, [true]);
    }
    private function requestDraw(tag: String, func: Dynamic, ?args: Array<Dynamic>) {
        if (Main.App.model.isDebug) {
            untyped __js__('
                var n = window.performance.now();
                func.apply(this, args || []);
                var t = window.performance.now()-n;
                if (t > 16) {
                    console.warn(tag+": spend "+t+" ms");
                }
            ');
        } else {
            untyped __js__('func.apply(this, args || [])');
        }
    }
    public function draw (clearAll: Bool = false) {
        if (!clearAll && !mHasDirtyRect) return;
        if (clearAll) {
            mDirtyRect.setValues(0,0,mCanvas.width,mCanvas.height);
        }
        var buf = getBufferShape(mStage);
        buf.graphics.clear();
        if (Main.App.model.isDebug) {
            buf.graphics
            .beginStroke("red").setStrokeStyle(Scalar.valueOf(1))
            .drawRect(mDirtyRect.x,mDirtyRect.y,mDirtyRect.width,mDirtyRect.height);
        }
        Reflect.setField(mStage,"drawRect",mDirtyRect.union(mPrevDirtyRect).padAll(Scalar.valueOf(5).toFloat()));
        mStage.update();
        mPrevDirtyRect.copy(mDirtyRect);
        mDirtyRect.reset();
        mHasDirtyRect = false;
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
    function drawGrid (deltaX: Float = 0, deltaY: Float = 0) {
        mGrid.graphics
        .clear()
        .setStrokeStyle(Scalar.valueOf(1),0)
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
    function drawBoundingBox (target: Layer) {
        mBoundingBox.clear();
        if (target != null && target.hasContent())
        {
            var p = mMainContainer.localToLocal(
                target.x,
                target.y,
                mFgContainer
            );
            mBoundingBox.x = p.x;
            mBoundingBox.y = p.y;
            var bounds = target.getTransformedBounds().clone();
            bounds.scale(scale,scale);
            mBoundingBox.render(bounds);
            var g = mMainContainer.localToGlobal(bounds.x,bounds.y);
            var pad = mBoundingBox.cornerRadius.toFloat();
            extendDirtyRect(g.x-pad,g.y-pad,bounds.width+pad*2,bounds.height+pad*2);
        }
    }
    function drawBrushCircle () {
        if (!isEditing) {
            var rad = Main.App.model.brush.width.toFloat()*scale*.5;
            var w = Scalar.valueOf(1).toFloat();
            mBrushCircle.graphics
            .clear()
            .setStrokeStyle(w,"round", "round")
            .beginStroke(mPressed ? "#2196F3" : "#000")
            .drawCircle(rad+w,rad+w,rad)
            .endStroke();
            mBrushCircle.cache(0,0,rad*2+w*2,rad*2+w*2);
            updateBrushCircle(mCapture);
        }
    }
    public function extendDirtyRectWithRadius(x: Float, y: Float, rad: Float = 0, ?container: Container) {
        if (container != null) {
            var p = container.localToGlobal(x,y);
            x = p.x;
            y = p.y;
        }
        extendDirtyRect(x-rad,y-rad,rad*2,rad*2);
    }
    public function extendDirtyRect(gx: Float, gy: Float, width: Float = 0, height: Float = 0) {
        if (!mHasDirtyRect) {
            mDirtyRect.setValues(gx,gy,width,height);
            mHasDirtyRect = true;
        } else {
            mDirtyRect.extend(gx,gy,width,height);
        }
    }
    public function extendDirtyRectWithRect(r: Rectangle, ?localContainer: Container) {
        if (localContainer != null) {
            var lt = localContainer.localToGlobal(r.x,r.y);
            var rb = localContainer.localToGlobal(r.right(),r.bottom());
            extendDirtyRect(lt.x,lt.y);
            extendDirtyRect(rb.x,rb.y);
        } else {
            extendDirtyRect(r.x,r.y,r.width,r.height);
        }
    }
    public function extendDirtyRectWithDisplayObject(o: DisplayObject, ?prevBounds: Rectangle) {
        var b = o.getTransformedBounds().clone();
        if (prevBounds != null) {
            b.extend(prevBounds.x,prevBounds.y,prevBounds.width,prevBounds.height);
        }
        extendDirtyRectWithRect(b, o.parent);
    }
    private static var BUFFER_SHAPE_TAG = "BUFFER_SHAPE_TAG";
    public function getBufferShape(container: Container): Shape {
        var ret = container.getChildByName(BUFFER_SHAPE_TAG);
        if (ret == null) {
            ret = new Shape();
            ret.name = BUFFER_SHAPE_TAG;
            container.addChild(ret);
        }
        container.setChildIndex(ret,container.children.length);
        return cast ret;
    }
    public function insertLayer (layer: Layer, silent: Bool = false, ?index: Int) {
        if (layer == null) {
            throw new Error("attempt to insert null figure");
        }
        var fun = function(arg) {
            var i = index == null ? mLayerContainer.children.length : index;
            mLayerContainer.addChildAt(layer,i);
            listenTo(layer.editor, "change", onImageEditorChange);
            trigger(ON_INSERT_EVENT, {
                target: layer,
                at: i
            });
        };
        silent ? fun(null) : pushCommand(new InsertLayerCommand(layer,this).exec(fun));
        activeLayer = layer;
        extendDirtyRectWithDisplayObject(layer);
        requestDraw("insertFigure", draw);
        Log.d(layer);
    }
    public function deleteLayer(layer: Layer, silent: Bool = false) {
        if (layer == null) return;
        // 削除後だとparentの情報が消えるので先にDRを更新しておく
        extendDirtyRectWithDisplayObject(layer);
        var fun = function(a) {
            mLayerContainer.removeChild(layer);
            stopListening(layer.editor, "change", onImageEditorChange);
//            Main.App.floatingThumbnailView.remove(layer.imageWrap.id);
            trigger(ON_DELETE_EVENT,{
                target: layer
            });
        };
        silent ? fun(null) : pushCommand(new DeleteLayerCommand(layer,this).exec(fun));
        mBoundingBox.clear();
        if (isEditing) {
            activeLayer = cast mLayerContainer.children.last();
        }
        requestDraw("deleteFigure",draw);
    }

    public function copyLayer(layer: Layer, silent: Bool = false) {
        var i = mLayerContainer.getChildIndex(layer)+1;
        var fun = function(a){
            var cop = layer.clone();
            cop.x = layer.x+20;
            cop.y = layer.y+20;
            mLayerContainer.addChildAt(cop, i);
            listenTo(cop.editor, "change", onImageEditorChange);
            return cop;
        };
        var copied: Layer;
        if (silent) {
            copied = fun(null);
        } else {
            var cmd = new CopyLayerCommand(layer,this);
            cmd.exec(fun);
            copied = cmd.copiedObject;
            pushCommand(cmd);
        }
        trigger(ON_COPY_EVENT,{
            src: layer,
            target: copied,
            at: i
        });
        if (isEditing) {
            activeLayer = copied;
        }
    }

    public function moveLayer(fig: DisplayObject, at: Int) {
        mLayerContainer.setChildIndex(fig, at);
        extendDirtyRectWithDisplayObject(fig);
        requestDraw("moveLayer", draw);
    }

    function thumbnalzieImage(f: ImageFigure) {
        f.visible = false;
        var tv = Main.App.floatingThumbnailView;
        tv.add(f.imageWrap, function () {
            f.visible = true;
            tv.remove(f.imageWrap.id);
            extendDirtyRectWithDisplayObject(f);
            requestDraw("thumbnalzieImage:add", draw);
        });
        extendDirtyRectWithDisplayObject(f);
        requestDraw("thumbnalzieImage", draw);
    }

    public function pushCommand(cmd: Undoable) {
        mUndoStack.push(cmd);
        mRedoStack.splice(0,mRedoStack.length);
        Main.App.model.undoStackSize += 1;
        Main.App.model.redoStackSize = 0;
    }

    public function undo() {
        var cmd = mUndoStack.pop();
        if (cmd != null) {
            mRedoStack.push(cmd);
            cmd.undo();
            invalidate();
            Main.App.model.undoStackSize -= 1;
            Main.App.model.redoStackSize += 1;
        }
    }

    public function redo() {
        var cmd = mRedoStack.pop();
        if (cmd != null) {
            cmd.redo();
            mUndoStack.push(cmd);
            invalidate();
            Main.App.model.undoStackSize += 1;
            Main.App.model.redoStackSize -= 1;
        }
    }

    public function onImageEditorChange(editor: ImageEditor):Void {
        activeLayer.setFilterAsync(editor.createFilter())
        .done(function(im) {
            activeLayer.alpha = editor.alpha;
            Main.App.layerView.invalidate(activeLayer);
            extendDirtyRectWithDisplayObject(activeLayer);
            requestDraw("onImageEditorChange", draw);
        }).fail(function(e) {
            Log.e(e);
            Rollbar.error(e);
        });
    }

    public function onSearchResultLoad(img: ImageWrap, result: BingSearchResult):Void {
        insertLayer(Layer.fromImage(img));
    }

    public function onFileLoad (img: ImageWrap) {
        insertLayer(Layer.fromImage(img));
    }

    function resizeCanvas () {
        var w = window.innerWidth;
        var h = window.innerHeight;
        this.jq.attr({
            width : Scalar.valueOf(w),
            height: Scalar.valueOf(h)
        });
        this.jq.css({
            width: w+"px",
            height: h+"px"
        });
        invalidate();
        Log.d("onWindowChange"+w+","+h);
    }

    function exportImage (x: Float, y: Float, w: Float, h: Float) {
        if (w == 0 || h == 0) {
            return;
        }
        var ec: CanvasElement = cast BrowserUtil.document.createElement("canvas");
        ec.width = cast w;
        ec.height = cast h;
        var es = new Stage(ec);
        var ml = mMainContainer.clone(true);
        ml.scaleX = 1.0;
        ml.scaleY = 1.0;
        ml.regX = 0;
        ml.regY = 0;
        ml.x = -x;
        ml.y = -y;
        es.addChild(ml);
        es.update();
        try {
            var url = es.toDataURL("rgba(0,0,0,0)","image/png");
            Main.App.modalView.confirmExporting(url, function(result: Bool) {
                if (result) {
                    Uploader.uploadImage(url, "image/png").done(function(as: UploadedAsset){
                        Log.d(as);
                        window.open("/images/"+as.displayId);
                    }).fail(function(e){
                        Log.e(e);
                        Browser.alert("ファイルのアップロードに失敗しました。ネットワークの設定などを確認して再度お試しください。");
                    });
                }
                url = null;
            }).open();
        } catch (err: Error) {
            Browser.alert("ファイルの書き出しに失敗しました。");
            Rollbar.error(err);
        }
        es = null;
        ec = null;
    }

    function onChageZoomEditor (v: AppModel, val: ZoomEditor, options: Dynamic) {
        if (options.changer == this) {
            applyScaleToLayer(mMainContainer, val.scale, val.pivotX, val.pivotY);
        } else {
            var pivX = mCanvas.width/2;
            var pivY = mCanvas.height/2;
            if (activeLayer != null) {
                var c = activeLayer.getTransformedBounds().center();
                var p = mMainContainer.localToGlobal(c.x,c.y);
                pivX = p.x;
                pivY = p.y;
            }
            applyScaleToLayer(mMainContainer, val.scale, pivX, pivY);
        }
        if (mirroringInfo.pivotEnabled) {
            var piv = mLayerContainer.localToLocal(
                mirroringInfo.pivotX,
                mirroringInfo.pivotY,
                mFgContainer
            );
            var w = mMirrorPivotShape.getBounds().width*0.5;
            mMirrorPivotShape.adjustPivot(piv.x,piv.y);
        }
        invalidate();
    }

    private function applyScaleToLayer(container: Container, scale: Float, g_pivX: Float, g_pivY: Float) {
        var piv = container.globalToLocal(g_pivX,g_pivY);
        container.scaleX = scale;
        container.scaleY = scale;
        container.regX = piv.x;
        container.regY = piv.y;
        container.x = g_pivX;
        container.y = g_pivY;
    }

    function showPopupMenu (target: Layer) {
        if (!isExporting && target != null && target.hasContent()) {
            mPopupMenu.render(getPopupItmes(target));
            var d = BrowserUtil.window.devicePixelRatio;
            var p = mMainContainer.localToGlobal(
                target.x,
                target.y
            );
            p.x /= d;
            p.y /= d;
            var margin = 20;
            var b = target.getTransformedBounds().clone().scale(scale/d,scale/d);
            var w = mPopupMenu.jq.outerWidth();
            var h = mPopupMenu.jq.outerHeight();
            var x = p.x+(b.width-w)*0.5;
            var y = p.y-h-margin;
            var dir = "bottom";
            var o = mMainContainer.globalToLocal(0,0);
            if (p.y < h && jq.outerHeight()-h < p.y+b.height) {
                dir = "top";
                y = p.y+b.height*0.5;
            } else {
                if (y < o.y) {
                    dir = "top";
                    y = p.y+b.height+margin;
                }
            }
            mPopupMenu.showAt(x,y,dir,300);
        } else {
            mPopupMenu.dismiss(200);
        }
    }

    function getPopupItmes (layer: Layer): Array<PopupItem> {
        var ret: Array<PopupItem> = [];
        var copy = new PopupItem("コピー", function (p) {
            copyLayer(layer);
        });
        ret.push(copy);
        var delete = new PopupItem("削除", function (p) {
            deleteLayer(layer);
        });
        ret.push(delete);
        return ret;
    }

    var mUndoCommand: Undoable;
    function onMouseDown (e: CanvasMouseEvent) {
        mPressed = true;
        var p_main_local = e.getLocal(mMainContainer);
        var p_fg_local = e.getLocal(mFgContainer);
        if (!isExporting) {
            var hitted: DisplayObject = null;
            if (!isEditing) {
                // set start point as pivot anywasy even if pivot is disabled.
                if (!mirroringInfo.pivotEnabled) {
                    mirroringInfo.pivotX = p_main_local.x;
                    mirroringInfo.pivotY = p_main_local.y;
                }
                if (mirroringInfo.pivotEnabled && mMirrorPivotShape.hitTest(p_fg_local.x,p_fg_local.y)) {
                    hitted = mMirrorPivotShape;
                    mActiveTool = new DragTool(hitted);
                } else {
                    // using tools
                    mActiveTool = switch (toolType) {
                        case CanvasToolType.Brush: new BrushTool();
                        case CanvasToolType.Eraser: new BrushTool(true);
                    };
                    drawBrushCircle();
                }
            } else {
                // during editing
                hitted = mLayerContainer.children.findLast(function(d: DisplayObject) {
                    return d.visible && d.getTransformedBounds().containsPoint(p_main_local.x,p_main_local.y);
                });
                if (hitted != null) {
                    mActiveTool = new DragTool(hitted);
                    if (isEditing && hitted.type() == FigureType.TypeLayer) {
                        activeLayer = cast hitted;
                    }
                } else {
                   mActiveTool = new GrabTool();
                }
                if (activeLayer != null) {
                    var corner = mBoundingBox.hitsCorner(p_fg_local.x,p_fg_local.y);
                    if (corner != null) {
                        mActiveTool = new ScaleTool(corner);
                    }
                }
            }
            if (mActiveTool != null) {
                mActiveTool.onMouseDown(this,e);
            }
            if (isEditing) {
                drawBoundingBox(activeLayer);
            }
            mBrushCircle.visible = !isEditing;
        } else {
            // during export
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        requestDraw("onMouseDown", draw);
    }

    private static var MOVED_THRESH = 2*2;

    function updateBrushCircle(e: CanvasMouseEvent) {
        mBrushCircle.visible = true;
        var fp = e.getLocal(mFgContainer);
        extendDirtyRectWithDisplayObject(mBrushCircle);
        var bw = Main.App.model.brush.width.toFloat()*scale*.5;
        mBrushCircle.x = fp.x-bw;
        mBrushCircle.y = fp.y-bw;
        extendDirtyRectWithDisplayObject(mBrushCircle);
    }

    private var mCurrentPointerCSS: String;
    function setCursor(cursor: String) {
        jq.css("cursor", mCurrentPointerCSS = cursor);
    }

    function handleFreeCursorMove(e: CanvasMouseEvent) {
        var nextCursor = mCurrentPointerCSS;
        if (!isEditing) {
            if (mCurrentPointerCSS != CursorUtil.CROSSHAIR) {
                nextCursor = CursorUtil.CROSSHAIR;
            }
            if (mirroringInfo.pivotEnabled) {
                var lpfg = e.getLocal(mFgContainer);
                if (mMirrorPivotShape.hitTest(lpfg.x,lpfg.y)) {
                    nextCursor = CursorUtil.MOVE;
                }
            }
            updateBrushCircle(e);
        } else {
            if (activeLayer != null) {
                var lpfg = e.getLocal(mFgContainer);
                var c = mBoundingBox.hitsCorner(lpfg.x,lpfg.y);
                if (c != null) {
                    nextCursor = BoundingBox.getPointerCSS(c);
                } else {
                    if (activeLayer.getTransformedBounds().containsPoint(lpfg.x,lpfg.y)){
                        nextCursor = CursorUtil.MOVE;
                    } else {
                        nextCursor = CursorUtil.grabCursor();
                    }
                }
            }
        }
        if (mCurrentPointerCSS != nextCursor) {
            setCursor(nextCursor);
        }
    }

    function onMouseMove (e: CanvasMouseEvent) {
        if (!BrowserUtil.isBrowser) {
            e.srcEvent.preventDefault();
        }
        if (!isExporting) {
            if (!mPressed) {
                handleFreeCursorMove(e);
            } else {
                if (!isEditing) {
                    updateBrushCircle(e);
                }
                if (mActiveTool != null) {
                    mActiveTool.onMouseMove(this,e);
                }
            }
        } else {
            if (mPressed) {
                // during export
                var x = e.totalDeltaX < 0 ? e.startX+e.totalDeltaX : e.startX;
                var y = e.totalDeltaY < 0 ? e.startY+e.totalDeltaY : e.startY;
                var w = e.totalDeltaX < 0 ? -e.totalDeltaX : e.totalDeltaX;
                var h = e.totalDeltaY < 0 ? -e.totalDeltaY : e.totalDeltaY;
                var p = mFgContainer.globalToLocal(x,y);
                var buf = getBufferShape(mFgContainer);
                buf.alpha = 0.4;
                buf.graphics
                .clear()
                .beginFill("#000")
                .drawRoundRect(p.x,p.y,w,h,0)
                .endFill();
                extendDirtyRect(x,y,w,h);
            }
        }
        requestDraw(TAG_ON_MOUSE_MOVE, draw);
        trigger(ON_CANVAS_MOUSEMOVE_EVENT);
    }
    private static var TAG_ON_MOUSE_MOVE = "onMouseMove";
    function onMouseUp (e: CanvasMouseEvent) {
        if (!isExporting) {
            if (!isEditing) {
                if (mActiveTool != null) {
                    mActiveTool.onMouseUp(this,e);
                }
                drawBrushCircle();
            } else {
                if (mActiveTool != null) {
                    mActiveTool.onMouseUp(this,e);
                }
                showPopupMenu(activeLayer);
            }
            if (mUndoCommand != null) {
                pushCommand(mUndoCommand.exec(null));
            }
        } else {
            // during exporting
            var z = Main.App.model.zoom;
            var lp = mMainContainer.globalToLocal(
                e.totalDeltaX < 0 ? e.startX+e.totalDeltaX : e.startX,
                e.totalDeltaY < 0 ? e.startY+e.totalDeltaY : e.startY
            );
            var w = Math.abs(e.totalDeltaX/z.scale);
            var h = Math.abs(e.totalDeltaY/z.scale);
            exportImage(lp.x,lp.y,w,h);
            isExporting = false;
        }
        mUndoCommand = null;
        mPressed = false;
        mActiveTool = null;
        mBrushCircle.visible = BrowserUtil.isBrowser && !isEditing;
        trigger(ON_CANVAS_MOUSEUP_EVENT);
        requestDraw("onMouseUp", draw);
    }
    private function onMouseWheel (e: WheelEvent) {
        var zoom = Main.App.model.zoom;
        var z: ZoomEditor = e.deltaY < 0 ? zoom.zoomIn() : zoom.zoomOut();
        z.pivotX = e.clientX;
        z.pivotY = e.clientY;
        Main.App.model.set("zoom", z, {
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
            case 8: deleteLayer(activeLayer);
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
