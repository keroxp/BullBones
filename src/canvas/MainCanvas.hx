package canvas;
import canvas.tools.SmoothTool;
import canvas.tools.BrushTool;
import canvas.CanvasToolType;
import canvas.CanvasState;
import js.html.UIEvent;
import view.PopupMenu;
import util.CursorUtil;
import geometry.Scalar;
import figure.PivotShape;
import figure.FigureType;
import figure.ShapeFigureSet;
import model.MirroringInfo.MirroringType;
import model.MirroringInfo;
import js.html.Window;
import rollbar.Rollbar;
import ajax.Uploader;
import jQuery.JQuery;
import js.Error;
import command.CopyCommand;
import command.DeleteCommand;
import command.InsertCommand;
import cv.ImageWrap;
import command.FigureCommand;
import command.DisplayCommand;
import createjs.easeljs.DisplayObject;
import model.ZoomEditor;
import createjs.easeljs.Point;
import js.html.WheelEvent;
import view.PopupMenu.PopupItem;
import util.Log;
import createjs.easeljs.Rectangle;
import js.html.ImageElement;
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
using figure.Figures;

typedef InsertEvent = {
    public var target: DisplayObject;
    public var at: Int;
}
typedef DeleteEvent = {
    public var target: DisplayObject;
}
typedef CopyEvent = {
    public var src: DisplayObject;
    public var target: DisplayObject;
    public var at: Int;
}

/*
レイヤー構造
[Stage]
  StageDebugShape       - ステージレイヤのデバッグ用
  [Foreground Layer]    - 前面レイヤ
    ExportShape             - 画像書き出しの際のマスク
    SymmetryPivotShape      - 線対称のピボット
    BrushCircleShape        - ブラシヘッド
    BoudingBox              - バウンディングボックス
  [Main Layer]          - メインレイヤ
    MainDebugShape          - メインレイヤのデバッグ用
    BufferShape             - 描画途中の図形
    [FigureLayer]           - 図形レイヤ
  [BackgroundLayer]     - 背景レイヤ
    GridShape               - グリッド
    BackgroundShape         - 背景
 */
@:allow(canvas.tools)
class MainCanvas extends ViewModel
implements SearchResultListener {
    var mStage: Stage;
    var mFgContainer: Container = new Container();
    var mBgContainer: Container = new Container();
    var mMainContainer: Container = new Container();
    var mFigureContainer: Container = new Container();
    var mBoundingBox: BoundingBox = new BoundingBox();
    var mFuzzySketchGraph: Shape = new Shape();
    var mBackground: Shape = new Shape();
    var mGrid: Shape = new Shape();
    var mBrushCircle: Shape = new Shape();
    var mBufferShape: Shape = new Shape();
    var mExportShape: Shape = new Shape();
    var mSymmetryPivotShape: PivotShape = new PivotShape();
    var mStageDebugShape: Shape = new Shape();
    var mMainDebugShape: Shape = new Shape();
    var mUndoStack: Array<FigureCommand> = new Array<FigureCommand>();
    var mRedoStack: Array<FigureCommand> = new Array<FigureCommand>();
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
    var mCanvasState: CanvasState = Idle;
    var mTool: CanvasTool;
    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_CANVAS_MOUSEUP_EVENT";
    public static var ON_INSERT_EVENT(default,null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_INSERT_EVENT";
    public static var ON_COPY_EVENT(default,null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_COPY_EVENT";
    public static var ON_DELETE_EVENT(default,null)
    = "me.keroxp.app.BullBones:canvas.MainCanvas:ON_DELETE_EVENT";

    public var mirroringInfo(default, null): MirroringInfo = new MirroringInfo();

    public function new(jq: JQuery) {
        super(jq, {
            activeFigure: null,
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

        mFgContainer.addChild(mBoundingBox.shape);
        mBrushCircle.visible = false;
        mFgContainer.addChild(mBrushCircle);
        mFgContainer.addChild(mFuzzySketchGraph);
        mSymmetryPivotShape.render();
        mSymmetryPivotShape.visible = false;
        mFgContainer.addChild(mSymmetryPivotShape);
        mFgContainer.addChild(mExportShape);

        mMainContainer.addChild(mMainDebugShape);
        mMainContainer.addChild(mFigureContainer);
        mMainContainer.addChild(mBufferShape);

        mStage.addChild(mBgContainer);
        mStage.addChild(mMainContainer);
        mStage.addChild(mFgContainer);
        mStage.addChild(mStageDebugShape);
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
            for (f in mFigureContainer.children) {
                f.asShapeFigure(function(shape: ShapeFigure) {
                   shape.render();
                });
            }
            invalidate();
        });
        listenTo(mirroringInfo, "change:pivotEnabled", function(m: MirroringInfo, val: Bool) {
            mSymmetryPivotShape.visible = val;
            extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
            mSymmetryPivotShape.adjustPivot(m.pivotX,m.pivotY);
            extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
            requestDraw("change:pivotEnabled", draw);
        });
        var piv = mFgContainer.globalToLocal(
            mCanvas.width*0.5,
            mCanvas.height*0.5
        );
        mirroringInfo.pivotX = piv.x;
        mirroringInfo.pivotY = piv.y;
    }

    @:isVar public var activeFigure(get,set):DisplayObject;
    function get_activeFigure(): DisplayObject {
        return get("activeFigure");
    }
    function set_activeFigure(value:DisplayObject) {
        trace("set_activeFigure", value);
        if (activeFigure == value) return value;
        if (value == null && mPopupMenu.isShown) {
            mPopupMenu.dismiss(200);
        }
        drawBoundingBox(value);
        if (isEditing) {
            showPopupMenu(value);
        }
        extendDirtyRectWithDisplayObject(value != null ? value : activeFigure);
        requestDraw("setActiveFigure", draw);
        set("activeFigure", value);
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
        if (value) {
            activeFigure = mFigureContainer.children.findLast(function(e: DisplayObject) {
                return e.visible;
            });
        } else {
            activeFigure = null;
        }
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
        mExportShape.visible = value;
        mExportShape.graphics.clear();
        invalidate();
        return value;
    }

    var scale(get,never): Float;
    inline function get_scale():Float return Main.App.model.zoom.scale;
    
    function invalidate () {
        drawBackground();
        drawGrid();
        drawBrushCircle();
        drawBoundingBox(activeFigure);
        showPopupMenu(activeFigure);
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
        var pad = Main.App.model.brush.width.addf(10);
        if (clearAll) {
            mDirtyRect.setValues(0,0,mCanvas.width,mCanvas.height);
        }
        mDirtyRect.pad(pad,pad,pad,pad);
        mStageDebugShape.graphics.clear();
        if (Main.App.model.isDebug) {
            mStageDebugShape.graphics
            .beginStroke("red").setStrokeStyle(Scalar.valueOf(1))
            .drawRect(mDirtyRect.x,mDirtyRect.y,mDirtyRect.width,mDirtyRect.height);
        }
        Reflect.setField(mStage,"drawRect",mDirtyRect.union(mPrevDirtyRect).pad(5,5,5,5));
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
    function drawBoundingBox (target: DisplayObject) {
        mBoundingBox.clear();
        if (target != null) {
            var p = mMainContainer.localToLocal(
                target.x,
                target.y,
                mFgContainer
            );
            mBoundingBox.shape.x = p.x;
            mBoundingBox.shape.y = p.y;
            var bounds = target.getTransformedBounds().clone();
            var xOffset = 0.0;
            var yOffset = 0.0;
            if (target.type() == FigureType.Shape) {
                var shape = cast(target, ShapeFigure);
                xOffset = shape.width.toFloat()*.5;
                yOffset = shape.width.toFloat()*.5;
            } else if (target.type() == FigureType.ShapeSet) {
                var shape = cast(target, ShapeFigureSet);
                xOffset = shape.leftShape.width.toFloat()*.5;
                yOffset = shape.topShape.width.toFloat()*.5;
            }
            mBoundingBox.shape.x -= xOffset*scale;
            mBoundingBox.shape.y -= yOffset*scale;
            bounds.scale(scale,scale);
            mBoundingBox.render(bounds);
            var g = mMainContainer.localToGlobal(bounds.x,bounds.y);
            extendDirtyRect(g.x,g.y,bounds.width,bounds.height);
        }
    }
    function drawBrushCircle () {
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
    public function insertFigure (f: DisplayObject, silent: Bool = false, ?index: Int) {
        if (f == null) {
            throw new Error("attempt to insert null figure");
        }
        var fun = function(arg) {
            var i = index == null ? mFigureContainer.children.length : index;
            mFigureContainer.addChildAt(f,i);
            f.asImageFigure(function (imf: ImageFigure) {
                listenTo(imf.editor, "change", onImageEditorChange);
            });
            trigger(ON_INSERT_EVENT, {
                target: f,
                at: i
            });
        };
        silent ? fun(null) : pushCommand(new InsertCommand(f,this).exec(fun));
        extendDirtyRectWithDisplayObject(f);
        requestDraw("insertFigure", draw);
    }
    public function deleteFigure(f: DisplayObject, silent: Bool = false) {
        if (f == null) return;
        // 削除後だとparentの情報が消えるので先にDRを更新しておく
        extendDirtyRectWithDisplayObject(f);
        var fun = function(a) {
            mFigureContainer.removeChild(f);
            f.asImageFigure(function(imf: ImageFigure) {
                stopListening(imf.editor, "change", onImageEditorChange);
                Main.App.floatingThumbnailView.remove(imf.imageWrap.id);
            });
            trigger(ON_DELETE_EVENT,{
                target: f
            });
        };
        silent ? fun(null) : pushCommand(new DeleteCommand(f,this).exec(fun));
        mBoundingBox.clear();
        if (isEditing) {
            activeFigure = mFigureContainer.children.last();
        }
        requestDraw("deleteFigure",draw);
    }

    public function copyFigure(f: DisplayObject, silent: Bool = false) {
        var i = mFigureContainer.getChildIndex(f);
        var fun = function(a){
            var fig = f.clone();
            fig.x = f.x+20;
            fig.y = f.y+20;
            mFigureContainer.addChildAt(fig, i);
            return fig;
        };
        var copied: DisplayObject;
        if (silent) {
            copied = fun(null);
        } else {
            var cmd = new CopyCommand(f,this);
            copied = cmd.exec(fun).copiedObject;
            pushCommand(cmd);
        }
        trigger(ON_COPY_EVENT,{
            src: f,
            target: copied,
            at: i
        });
        if (isEditing) {
            activeFigure = copied;
        }
    }

    public function moveLayer(fig: DisplayObject, at: Int) {
        mFigureContainer.setChildIndex(fig, at);
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

    public function pushCommand(cmd: FigureCommand) {
        mUndoStack.push(cmd);
        mRedoStack.splice(0,mRedoStack.length);
        Main.App.model.undoStackSize += 1;
        Main.App.model.redoStackSize = 0;
    }

    public function undo() {
        var cmd = mUndoStack.pop();
        if (cmd != null) {
            mRedoStack.push(cmd);
            var af = null;
            if (cmd.isInsertCommand() || cmd.isCopyCommand()) {
                var i = mFigureContainer.getChildIndex(cmd.target);
                if (cmd.isInsertCommand()) {
                    i -= 1;
                }
                af = i < mFigureContainer.children.length ? mFigureContainer.getChildAt(i) : null;
            } else {
                af = cmd.target;
            }
            Reflect.callMethod(cmd, Reflect.field(cmd,"undo"),[]);
            if (isEditing) {
                activeFigure = af;
            }
            invalidate();
            Main.App.model.undoStackSize -= 1;
            Main.App.model.redoStackSize += 1;
        }
    }

    public function redo() {
        var cmd = mRedoStack.pop();
        if (cmd != null) {
            Reflect.callMethod(cmd, Reflect.field(cmd, "redo"),[]);
            mUndoStack.push(cmd);
            var af = null;
            if (cmd.isDeleteCommand()) {
                var i = mFigureContainer.getChildIndex(cmd.target) - 1;
                af = i < mFigureContainer.children.length ? mFigureContainer.getChildAt(i) : null;
            } else {
                af = cmd.target;
                if (cmd.isCopyCommand()) {
                    var i = cmd.target.parent.getChildIndex(cmd.target);
                    af = cmd.target.parent.getChildAt(i+1);
                }
            }
            if (isEditing) {
                activeFigure = af;
            }
            invalidate();
            Main.App.model.undoStackSize += 1;
            Main.App.model.redoStackSize -= 1;
        }
    }

    public function onImageEditorChange(editor: ImageEditor):Void {
        if (activeFigure.type() == FigureType.Image) {
            var image: ImageFigure = cast activeFigure;
            image.setFilterAsync(editor.createFilter())
            .done(function(img: ImageElement) {
                image.alpha = editor.alpha;
                Main.App.layerView.invalidate(image);
                extendDirtyRectWithDisplayObject(image);
                requestDraw("onImageEditorChange", draw);
            }).fail(function(e) {
                Log.e(e);
                Rollbar.error(e);
            });
        }
    }

    function insertImageFiguew(iw: ImageWrap) {
        var im = new ImageFigure(iw);
        var p =  mMainContainer.globalToLocal(0,0);
        im.x = p.x;
        im.y = p.y;
        insertFigure(im);
        isEditing = true;
    }

    public function onSearchResultLoad(img: ImageWrap, result: BingSearchResult):Void {
        insertImageFiguew(img);
    }

    public function onFileLoad (img: ImageWrap) {
        insertImageFiguew(img);
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
            if (activeFigure != null) {
                var c = activeFigure.getTransformedBounds().center();
                var p = mMainContainer.localToGlobal(c.x,c.y);
                pivX = p.x;
                pivY = p.y;
            }
            applyScaleToLayer(mMainContainer, val.scale, pivX, pivY);
        }
        if (mirroringInfo.pivotEnabled) {
            var piv = mFigureContainer.localToLocal(
                mirroringInfo.pivotX,
                mirroringInfo.pivotY,
                mFgContainer
            );
            var w = mSymmetryPivotShape.getBounds().width*0.5;
            mSymmetryPivotShape.adjustPivot(piv.x,piv.y);
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

    function showPopupMenu (target: DisplayObject) {
        if (!isExporting && target != null) {
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
            mPopupMenu.render(getPopupItmes(target)).showAt(x,y,dir,300);
        } else {
            mPopupMenu.dismiss(200);
        }
    }

    function getPopupItmes (fig: DisplayObject): Array<PopupItem> {
        var ret: Array<PopupItem> = [];
        if (fig.type() == FigureType.Image) {
            var hide = new PopupItem("隠す",function(p) {
                thumbnalzieImage(cast fig);
                var i = mFigureContainer.getChildIndex(fig)-1;
                activeFigure = null;
            });
            ret.push(hide);
        }
        var copy = new PopupItem("コピー", function (p) {
            copyFigure(fig);
        });
        ret.push(copy);
        var delete = new PopupItem("削除", function (p) {
            deleteFigure(fig);
        });
        ret.push(delete);
        return ret;
    }

    var mDisplayCommand: DisplayCommand;
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
                if (mirroringInfo.pivotEnabled && mSymmetryPivotShape.hitTest(p_fg_local.x,p_fg_local.y)) {
                    hitted = mSymmetryPivotShape;
                    mCanvasState = Dragging(hitted);
                } else {
                    // using tools
                    switch (toolType) {
                        case Brush: {
                            mCanvasState = Drawing(new BrushTool());
                        }
                        case Smooth: {
                            mCanvasState = Drawing(new SmoothTool());
                        }
                    }
                    drawBrushCircle();
                }
            } else {
                // during editing
                hitted = mFigureContainer.children.findLast(function(d: DisplayObject) {
                    return d.visible && d.getTransformedBounds().containsPoint(p_main_local.x,p_main_local.y);
                });
                if (hitted != null) {
                    mCanvasState = Dragging(hitted);
                } else {
                    mCanvasState = Grabbing;
                }
            }
            if (activeFigure != null) {
                var corner = mBoundingBox.hitsCorner(p_fg_local.x,p_fg_local.y);
                if (corner != null) {
                    mCanvasState = Scaling(corner);
                }
            }
            if (hitted != null) {
                mBoundingBox.shape.x = hitted.x;
                mBoundingBox.shape.y = hitted.y;
            }
            switch (mCanvasState) {
                case Drawing(tool): {
                    tool.onMouseDown(this,e);
                }
                case Dragging(dragging): {
                    mDisplayCommand = new DisplayCommand(dragging, this);
                    if (isEditing) {
                        activeFigure = hitted;
                    }
                    jq.css("cursor", mCurrentPointerCSS = "move");
                }
                case Grabbing: {
                    jq.css("cursor",mCurrentPointerCSS = CursorUtil.grabbingCursor());
                }
                case Scaling(corner): {
                    mDisplayCommand = new DisplayCommand(activeFigure, this);
                }
                default: {}
            }
            if (isEditing) {
                drawBoundingBox(activeFigure);
            }
            mBrushCircle.visible = !isEditing;
        } else {
            // during export
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        requestDraw("onMouseDown", draw);
    }
    private var mCurrentPointerCSS: String;
    private static var MOVED_THRESH = 2*2;

    function updateBrushCircle(e: CanvasMouseEvent) {
        mBrushCircle.visible = true;
        var fp = e.getLocal(mFgContainer);
        var pb = mBrushCircle.getTransformedBounds().clone();
        var bw = Main.App.model.brush.width.toFloat()*scale*.5;
        mBrushCircle.x = fp.x-bw;
        mBrushCircle.y = fp.y-bw;
        extendDirtyRectWithDisplayObject(mBrushCircle,pb);
    }

    function handleFreeCursorMove(e: CanvasMouseEvent) {
        var nextCursor = mCurrentPointerCSS;
        if (!isEditing) {
            if (mCurrentPointerCSS != CursorUtil.CROSSHAIR) {
                nextCursor = CursorUtil.CROSSHAIR;
            }
            if (mirroringInfo.pivotEnabled) {
                var lpfg = e.getLocal(mFgContainer);
                if (mSymmetryPivotShape.hitTest(lpfg.x,lpfg.y)) {
                    nextCursor = CursorUtil.MOVE;
                }
            }
            updateBrushCircle(e);
        } else {
            if (activeFigure != null) {
                var lpmn = e.getLocal(mMainContainer);
                var c = mBoundingBox.hitsCorner(lpmn.x,lpmn.y);
                if (c != null) {
                    nextCursor = BoundingBox.getPointerCSS(c);
                } else {
                    if (activeFigure.getTransformedBounds().containsPoint(lpmn.x,lpmn.y)){
                        nextCursor = CursorUtil.MOVE;
                    } else {
                        nextCursor = CursorUtil.grabCursor();
                    }
                }
            }
        }
        if (mCurrentPointerCSS != nextCursor) {
            jq.css("cursor", mCurrentPointerCSS = nextCursor);
        }
    }

    function handleSmooth(e: CanvasMouseEvent, tool: SmoothTool) {

    }
    function handleDragging(e: CanvasMouseEvent, dragging: DisplayObject) {
        if (!isEditing) {
            dragging.x += e.deltaX;
            dragging.y += e.deltaY;
            if (dragging == mSymmetryPivotShape) {
                var w = mSymmetryPivotShape.totalRadius.toFloat();
                var piv = mFgContainer.localToLocal(
                    mSymmetryPivotShape.x+w,
                    mSymmetryPivotShape.y+w,
                    mFigureContainer
                );
                mirroringInfo.pivotX = piv.x;
                mirroringInfo.pivotY = piv.y;
                extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
            }
        } else {
            var pb = activeFigure.getTransformedBounds().clone();
            dragging.x += e.deltaX/scale;
            dragging.y += e.deltaY/scale;
            mBoundingBox.shape.x += e.deltaX;
            mBoundingBox.shape.y += e.deltaY;
            extendDirtyRectWithDisplayObject(dragging,pb);
            mPopupMenu.dismiss(200);
        }
    }
    function handleGrabbing(e: CanvasMouseEvent) {
        mMainContainer.x += e.deltaX;
        mMainContainer.y += e.deltaY;
        mFgContainer.x += e.deltaX;
        mFgContainer.y += e.deltaY;
        extendDirtyRect(0,0,mCanvas.width,mCanvas.height);
        drawGrid(e.deltaX,e.deltaY);
        mPopupMenu.dismiss(200);
    }
    function handleScaling(e: CanvasMouseEvent, corner: Corner) {
        var tb = activeFigure.getTransformedBounds().clone();
        var lpmn = e.getLocal(mMainContainer);
        var lpmnprev = e.getLocalPrev(mMainContainer);
        inline function doScaleX (width: Float) {
            var sx = width/tb.width;
            if (0 < sx) {
                activeFigure.scaleX *= sx;
            }
        }
        inline function doScaleY (height: Float) {
            var sy = height/tb.height;
            if (0 < sy) {
                activeFigure.scaleY *= sy;
            }
        }
        inline function constrainScaleX () {
            if (lpmn.x < tb.right()) {
                if (tb.right() < lpmnprev.x) {
                    doScaleX(tb.right()-e.x);
                } else {
                    doScaleX(tb.width-e.deltaX/scale);
                }
                activeFigure.x = lpmn.x;
            }
        }
        inline function constrainScaleY () {
            if (lpmn.y < tb.bottom()) {
                if (tb.bottom() < lpmnprev.y) {
                    doScaleY(tb.bottom()-lpmn.y);
                } else {
                    doScaleY(tb.height-e.deltaY/scale);
                }
                activeFigure.y = lpmn.y;
            }
        }
        corner.isLeft? constrainScaleX() : doScaleX(tb.width+e.deltaX/scale);
        corner.isTop? constrainScaleY() : doScaleY(tb.height+e.deltaY/scale);
        if (modifiedByShift()) {
            var d = activeFigure;
            var s = (d.scaleX+d.scaleY)*0.5;
            var oBounds = d.getBounds();
            d.scaleX = d.scaleY = s;
            var w = oBounds.width*s;
            var h = oBounds.height*s;
            if (corner.isLeft) {
                d.x = tb.right()-w;
            }
            if (corner.isTop) {
                d.y = tb.bottom()-h;
            }
        }
        extendDirtyRectWithDisplayObject(activeFigure,tb);
        drawBoundingBox(activeFigure);
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
                    switch(mCanvasState) {
                    case Drawing(tool):
                        tool.onMouseMove(this, e);
                    case Dragging(dragging):
                        handleDragging(e,dragging);
                    default: {}
                    }
                    updateBrushCircle(e);
                } else {
                    switch (mCanvasState) {
                        case Dragging(dragging):
                            handleDragging(e,dragging);
                        case Grabbing:
                            handleGrabbing(e);
                        case Scaling(corner):
                            handleScaling(e, corner);
                        default: {}
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
                var p = mFgContainer.globalToLocal(x,y);
                mExportShape.alpha = 0.4;
                mExportShape.graphics
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
                switch (mCanvasState) {
                case Drawing(tool):
                    tool.onMouseUp(this, e);
                default: {}
                }
            } else {
                switch (mCanvasState) {
                case Dragging(dragging): {
                    drawBoundingBox(dragging);
                }
                case Grabbing: {
                    if (activeFigure != null) {
                        activeFigure = null;
                    }
                    jq.css("cursor", CursorUtil.grabCursor());
                }
                case Scaling(corner): {
                    activeFigure.asShapeFigure(function(shape: ShapeFigure) {
                        var sx = shape.shapeScaleX*shape.scaleX;
                        var sy = shape.shapeScaleY*shape.scaleY;
                        shape.applyScale(sx,sy).render();
                    });
                    drawBoundingBox(activeFigure);
                    Main.App.layerView.invalidate(activeFigure);
                }
                default: {}
                }
                showPopupMenu(activeFigure);
            }
            if (mDisplayCommand != null) {
                pushCommand(mDisplayCommand.exec(null));
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
        mDisplayCommand = null;
        mBufferShape.graphics.clear();
        mPressed = false;
        mCanvasState = Idle;
        mBrushCircle.visible = BrowserUtil.isBrowser && !isEditing;
        drawBrushCircle();
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
