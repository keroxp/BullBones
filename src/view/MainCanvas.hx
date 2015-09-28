package view;
import geometry.Scalar;
import geometry.Scalar;
import figure.PivotShape;
import figure.FigureType;
import figure.ShapeFigureSet;
import model.DrawingMode.MirroringType;
import model.DrawingMode;
import model.DrawingMode;
import backbone.haxe.BackboneCollection;
import model.BaseModel;
import backbone.Collection;
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
import view.ImageEditorView.ImageEditorListener;
import view.SearchView.SearchResultListener;
import view.ViewModel;
import ajax.BingSearch.BingSearchResult;
import event.MouseEventCapture;
import js.html.Element;
import createjs.easeljs.Container;
import geometry.FuzzyPoint;
import figure.BoundingBox;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import figure.ShapeFigure;
import createjs.easeljs.Stage;
import createjs.easeljs.Shape;
using util.RectangleUtil;
using util.ArrayUtil;
using util.FigureUtil;

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

enum CanvasEventState {
    Drawing(drawing: ShapeFigure);
    Dragging(dragging: DisplayObject);
    Grabbing;
    Scaling(corner: Corner);
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
class MainCanvas extends ViewModel
implements SearchResultListener
implements ImageEditorListener {
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
    var mMirrorFigure: ShapeFigure;
    var mUndoStack: Array<FigureCommand> = new Array<FigureCommand>();
    var mRedoStack: Array<FigureCommand> = new Array<FigureCommand>();
    var mCanvas: CanvasElement;
    var vGridUnit = 10;
    var vGridDivision = 10;
    var mPressed = false;
    var vBackgroundColor = "#ddd";
    var mDirtyRect: Rectangle = new Rectangle();
    var mCapture: MouseEventCapture;
    var mEventState: CanvasEventState;
    var window = BrowserUtil.window;
    var mPopupMenu: PopupMenu;
    public static var ON_CANVAS_MOUSEDOWN_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEDOWN_EVENT";
    public static var ON_CANVAS_MOUSEMOVE_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEMOVE_EVENT";
    public static var ON_CANVAS_MOUSEUP_EVENT(default, null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_CANVAS_MOUSEUP_EVENT";
    public static var ON_INSERT_EVENT(default,null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_INSERT_EVENT";
    public static var ON_COPY_EVENT(default,null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_COPY_EVENT";
    public static var ON_DELETE_EVENT(default,null)
    = "me.keroxp.app.BullBones:view.MainCanvas:ON_DELETE_EVENT";

    public function new(jq: JQuery) {
        super(jq);
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
        mBgContainer.addChild(mBackground);
        // グリッド
        mGrid.visible = false;
        mBgContainer.addChild(mGrid);

        mFgContainer.addChild(mBoundingBox.shape);
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
        mPopupMenu = new PopupMenu(Main.App.jq);
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
        listenTo(Main.App.drawingMode, "change:pivotEnabled", function(m: DrawingMode, val: Bool) {
            mSymmetryPivotShape.visible = val;
            var piv = m.pivot;
            if (piv == null) {
                piv = mFgContainer.globalToLocal(
                    mCanvas.width*0.5,
                    mCanvas.height*0.5
                );
                m.pivot = piv;
            }
            extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
            mSymmetryPivotShape.adjustPivot(piv.x,piv.y);
            extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
            draw();
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
        if (value != null) {
            extendDirtyRectWithDisplayObject(value);
            drawBoundingBox();
            draw();
        }
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
        return get("isExporting") || false;
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

    function onChangeEditing (m, value: Bool) {
        if (value) {
            activeFigure = mFigureContainer.children.findLast(function(e: DisplayObject) { return e.visible; });
        } else {
            activeFigure = null;
        }
    }

    var scale(get,never): Float;
    inline function get_scale():Float return Main.App.model.zoom.scale;


    function invalidate () {
        drawBackground();
        drawGrid();
        drawBrushCircle();
        drawBoundingBox();
        showPopupMenu();
        draw(true);
    }
    private var mPrevDirtyRect: Rectangle = new Rectangle();
    public function draw (clearAll: Bool = false) {
        if (!clearAll && mDirtyRect == null) return;
        var pad = Main.App.model.brush.width.addf(10);
        if (clearAll) {
            mDirtyRect = new Rectangle(0,0,mCanvas.width,mCanvas.height);
        }
        mDirtyRect.pad(pad,pad,pad,pad);
        mStageDebugShape.graphics.clear();
        if (Main.App.model.isDebug) {
            mStageDebugShape.graphics
            .beginStroke("red").setStrokeStyle(Scalar.valueOf(1))
            .drawRect(mDirtyRect.x+2,mDirtyRect.y+2,mDirtyRect.width-2,mDirtyRect.height-2);
        }
        Reflect.setField(mStage,"drawRect",mDirtyRect.union(mPrevDirtyRect).pad(5,5,5,5));
        mStage.update();
        mPrevDirtyRect = mDirtyRect;
        mDirtyRect = null;
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
    function drawBoundingBox () {
        mBoundingBox.clear();
        if (activeFigure != null) {
            var p = mMainContainer.localToLocal(
                activeFigure.x,
                activeFigure.y,
                mFgContainer
            );
            mBoundingBox.shape.x = p.x;
            mBoundingBox.shape.y = p.y;
            var bounds = activeFigure.getTransformedBounds().scale(scale,scale);
            mBoundingBox.render(bounds);
            var g = mMainContainer.localToGlobal(bounds.x,bounds.y);
            extendDirtyRect(g.x,g.y,bounds.width,bounds.height);
        }
    }
    function drawBrushCircle () {
        var w = Main.App.model.brush.width.toFloat()*scale;
        mBrushCircle.graphics
        .clear()
        .setStrokeStyle(Scalar.valueOf(1),"round", "round")
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
    public function extendDirtyRect(gx: Float, gy: Float, width: Float = 0, height: Float = 0) {
        if (mDirtyRect == null) {
            mDirtyRect = new Rectangle(gx,gy,width,height);
        } else {
            mDirtyRect.extend(gx,gy,width,height);
        }
    }
    public function extendDirtyRectWithRect(r: Rectangle) {
       extendDirtyRect(r.x,r.y,r.width,r.height);
    }
    public function extendDirtyRectWithDisplayObject(o: DisplayObject, ?prevBounds: Rectangle) {
        var b = o.getTransformedBounds();
        var g = o.parent.localToGlobal(b.x,b.y);
        var d = new Rectangle(g.x,g.y,b.width,b.height);
        if (prevBounds != null) {
            var pg = o.parent.localToGlobal(prevBounds.x,prevBounds.y);
            d = d.union(new Rectangle(pg.x,pg.y,prevBounds.width,prevBounds.height));
        }
        extendDirtyRectWithRect(d.scale(scale,scale));
    }
    public function insertFigure (f: DisplayObject, silent: Bool = false, ?index: Int) {
        if (f == null) {
            throw new Error("attempt to insert null figure");
        }
        var fun = function(arg) {
            var i = index == null ? mFigureContainer.children.length : index;
            mFigureContainer.addChildAt(f,i);
            trigger(ON_INSERT_EVENT, {
                target: f,
                at: i
            });
        };
        silent ? fun(null) : pushCommand(new InsertCommand(f,this).exec(fun));
        extendDirtyRectWithDisplayObject(f);
        draw();
    }
    public function deleteFigure(f: DisplayObject, silent: Bool = false) {
        if (f == null) return;
        // 削除後だとparentの情報が消えるので先にDRを更新しておく
        extendDirtyRectWithDisplayObject(f);
        var fun = function(a) {
            mFigureContainer.removeChild(f);
            trigger(ON_DELETE_EVENT,{
                target: f
            });
        };
        silent ? fun(null) : pushCommand(new DeleteCommand(f,this).exec(fun));
        mBoundingBox.clear();
        if (isEditing) {
            activeFigure = mFigureContainer.children.last();
        }
        f.asImageFigure(function(imf: ImageFigure) {
            Main.App.floatingThumbnailView.remove(imf.imageWrap);
        });
        draw();
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
        draw();
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
            } else {
                invalidate();
            }
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
            } else {
                invalidate();
            }
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
                draw();
            }).fail(function(e) {
                Rollbar.error(e);
            });
        }
    }

    public function onSearchResultLoad(img: ImageWrap, result: BingSearchResult):Void {
        var im = new ImageFigure(img);
        var p =  mMainContainer.globalToLocal(0,0);
        im.x = p.x;
        im.y = p.y;
        insertFigure(im);
    }

    function onFileLoad (img: ImageWrap) {
        var im = new ImageFigure(img);
        var p =  mMainContainer.globalToLocal(0,0);
        im.x = p.x;
        im.y = p.y;
        insertFigure(im);
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
//        mStage.scaleX = 1/d;
//        mStage.scaleY = 1/d;
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
        var dm = Main.App.drawingMode;
        if (dm.pivotEnabled) {
            var piv = mFigureContainer.localToLocal(
                dm.pivot.x,
                dm.pivot.y,
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

    function showPopupMenu () {
        if (!isExporting && activeFigure != null) {
            var d = BrowserUtil.window.devicePixelRatio;
            var p = mMainContainer.localToGlobal(
                activeFigure.x,
                activeFigure.y
            );
            p.x /= d;
            p.y /= d;
            var margin = 20;
            var b = activeFigure.getTransformedBounds().scale(scale,scale).scale(1/d,1/d);
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
            mPopupMenu.render(getPopupItmes(activeFigure)).showAt(x,y,dir,300);
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
    function onMouseDown (e: MouseEventCapture) {
        mPressed = true;
        var p_main_local = mMainContainer.globalToLocal(e.x,e.y);
        var p_fg_local = mFgContainer.globalToLocal(e.x,e.y);
        if (!isExporting) {
            var hitted: DisplayObject = null;
            if (!isEditing) {
                var dm = Main.App.drawingMode;
                if (dm.pivotEnabled && mSymmetryPivotShape.hitTest(p_fg_local.x,p_fg_local.y)) {
                    hitted = mSymmetryPivotShape;
                    mEventState = CanvasEventState.Dragging(hitted);
                } else {
                    var f =  new ShapeFigure(p_main_local.x,p_main_local.y);
                    f.width = Main.App.model.brush.width;
                    f.color = Main.App.model.brush.color;
                    mEventState = CanvasEventState.Drawing(f);
                    if (dm.isMirroring) {
                        var dm = dm;
                        var piv: Point = dm.pivotEnabled ? dm.pivot : p_main_local;
                        mMirrorFigure = new ShapeFigure(
                            p_main_local.x - (p_main_local.x-piv.x)*2,
                            p_main_local.y
                        );
                        mMirrorFigure.width = Main.App.model.brush.width;
                        mMirrorFigure.color = Main.App.model.brush.color;
                    }
                    drawBrushCircle();
                }
            } else {
                // during editing
                hitted = mFigureContainer.children.findLast(function(d: DisplayObject) {
                    return d.visible && d.getTransformedBounds().containsPoint(p_main_local.x,p_main_local.y);
                });
                if (hitted != null) {
                    mEventState = CanvasEventState.Dragging(hitted);
                } else {
                    mEventState = CanvasEventState.Grabbing;
                }
            }
            if (activeFigure != null) {
                var corner = mBoundingBox.hitsCorner(p_fg_local.x,p_fg_local.y);
                if (corner != null) {
                    mEventState = CanvasEventState.Scaling(corner);
                }
            }
            if (hitted != null) {
                mBoundingBox.shape.x = hitted.x;
                mBoundingBox.shape.y = hitted.y;
            }
            switch (mEventState) {
                case CanvasEventState.Dragging(dragging): {
                    mDisplayCommand = new DisplayCommand(dragging, this);
                    if (isEditing) {
                        activeFigure = hitted;
                    }
                    jq.css("cursor", mCurrentPointerCSS = "move");
                }
                case CanvasEventState.Grabbing: {
                    jq.css("cursor",mCurrentPointerCSS = BrowserUtil.grabbingCursor());
                }
                case CanvasEventState.Scaling(corner): {
                    mDisplayCommand = new DisplayCommand(activeFigure, this);
                }
                default: {}
            }
            drawBoundingBox();
            mBrushCircle.visible = !isEditing;
        } else {
            // during export
        }
        trigger(ON_CANVAS_MOUSEDOWN_EVENT);
        draw();
    }
    private var mCurrentPointerCSS: String;
    private static var MOVED_THRESH = 2*2;
    function updateBrushCircle(e: MouseEventCapture) {
        var fp = mFgContainer.globalToLocal(e.x,e.y);
        var pb = mBrushCircle.getTransformedBounds();
        var bw = Main.App.model.brush.width.toFloat()*scale/2;
        mBrushCircle.x = ~~(fp.x+0.5-bw);
        mBrushCircle.y = ~~(fp.y+0.5-bw);
        extendDirtyRectWithDisplayObject(mBrushCircle,pb);
    }
    function onMouseMove (e: MouseEventCapture) {
        var toDraw = false;
        if (!BrowserUtil.isBrowser()) {
            e.srcEvent.preventDefault();
        }
        var p_local_main = mMainContainer.globalToLocal(e.x,e.y);
        var p_local_main_prev = mMainContainer.globalToLocal(e.prevX,e.prevY);
        if (!isExporting) {
            if (!mPressed) {
                var nextCursor = mCurrentPointerCSS;
                if (!isEditing) {
                    if (mCurrentPointerCSS != "none") {
                        nextCursor = "none";
                    }
                    if (Main.App.drawingMode.pivotEnabled) {
                        var p_local_fg = mFgContainer.globalToLocal(e.x,e.y);
                        if (mSymmetryPivotShape.hitTest(p_local_fg.x,p_local_fg.y)) {
                            nextCursor = "move";
                        }
                    }
                    updateBrushCircle(e);
                } else {
                    if (activeFigure != null) {
                        var c = mBoundingBox.hitsCorner(p_local_main.x,p_local_main.y);
                        if (c != null) {
                            nextCursor = BoundingBox.getPointerCSS(c);
                        } else if (mCurrentPointerCSS != "move" && activeFigure.getTransformedBounds().containsPoint(p_local_main.x,p_local_main.y)){
                            nextCursor = "move";
                        } else if (mCurrentPointerCSS != BrowserUtil.grabCursor()) {
                            nextCursor = BrowserUtil.grabCursor();
                        }
                    }
                }
                if (mCurrentPointerCSS != nextCursor) {
                    jq.css("cursor", mCurrentPointerCSS = nextCursor);
                }
            } else {
                if (!isEditing) {
                    switch(mEventState) {
                        case Drawing(drawing): {
                            drawing.addPoint(p_local_main.x,p_local_main.y);
                            var b = Main.App.model.brush;
                            var dm = Main.App.drawingMode;
                            if (dm.isMirroring) {
                                var s_p_local_main = mMainContainer.globalToLocal(e.startX, e.startY);
                                var p_local_main_prev = mMainContainer.globalToLocal(e.prevX,e.prevY);
                                var piv: Point = dm.pivotEnabled ? dm.pivot : s_p_local_main;
                                var m = new Point(
                                    p_local_main.x - (p_local_main.x-piv.x)*2,
                                    p_local_main.y
                                );
                                var mp = new Point(
                                    p_local_main_prev.x - (p_local_main_prev.x-piv.x)*2,
                                    p_local_main_prev.y
                                );
                                mMirrorFigure.addPoint(m.x,m.y);
                                mBufferShape.graphics
                                .setStrokeStyle(b.width,"round", "round")
                                .beginStroke(b.color)
                                .moveTo(mp.x,mp.y)
                                .lineTo(m.x,m.y)
                                .endStroke();
                                var gm = mMainContainer.localToGlobal(m.x,m.y);
                                extendDirtyRect(gm.x,gm.y);
                            }
                            mBufferShape.graphics
                            .setStrokeStyle(b.width,"round", "round")
                            .beginStroke(b.color)
                            .moveTo(p_local_main_prev.x,p_local_main_prev.y)
                            .lineTo(p_local_main.x,p_local_main.y)
                            .endStroke();
                            extendDirtyRect(e.x,e.y);
                        }
                        case Dragging(dragging): {
                            dragging.x += e.deltaX;
                            dragging.y += e.deltaY;
                            if (dragging == mSymmetryPivotShape) {
                                var w = mSymmetryPivotShape.totalRadius.toFloat();
                                var piv = mFgContainer.localToLocal(
                                    mSymmetryPivotShape.x+w,
                                    mSymmetryPivotShape.y+w,
                                    mFigureContainer
                                );
                                Main.App.drawingMode.pivot = piv;
                                extendDirtyRectWithDisplayObject(mSymmetryPivotShape);
                            }
                        }
                        default: {}
                    }
                    updateBrushCircle(e);
                } else {
                    switch (mEventState) {
                        case Dragging(dragging): {
                            var pb = activeFigure.getTransformedBounds().clone();
                            dragging.x += e.deltaX/scale;
                            dragging.y += e.deltaY/scale;
                            mBoundingBox.shape.x += e.deltaX;
                            mBoundingBox.shape.y += e.deltaY;
                            extendDirtyRectWithDisplayObject(dragging,pb);
                            mPopupMenu.dismiss(200);
                        }
                        case Grabbing: {
                            mMainContainer.x += e.deltaX;
                            mMainContainer.y += e.deltaY;
                            mFgContainer.x += e.deltaX;
                            mFgContainer.y += e.deltaY;
                            drawGrid(e.deltaX,e.deltaY);
                            mPopupMenu.dismiss(200);
                        }
                        case Scaling(corner): {
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
                            corner.isLeft? constrainScaleX() : doScaleX(tBounds.width+e.deltaX/scale);
                            corner.isTop? constrainScaleY() : doScaleY(tBounds.height+e.deltaY/scale);
                            if (modifiedByShift()) {
                                var d = activeFigure;
                                var s = (d.scaleX+d.scaleY)*0.5;
                                var oBounds = d.getBounds();
                                d.scaleX = d.scaleY = s;
                                var w = oBounds.width*s;
                                var h = oBounds.height*s;
                                if (corner.isLeft) {
                                    d.x = tBounds.right()-w;
                                }
                                if (corner.isTop) {
                                    d.y = tBounds.bottom()-h;
                                }
                            }
                            extendDirtyRectWithDisplayObject(activeFigure,tBounds);
                            drawBoundingBox();
                        }
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
        draw();
        trigger(ON_CANVAS_MOUSEMOVE_EVENT);
    }
    function onMouseUp (e: MouseEventCapture) {
        var toDraw = false;
        if (!isExporting) {
            if (!isEditing) {
                switch (mEventState) {
                    case CanvasEventState.Drawing(drawing): {
                        if (drawing.points.length > 1) {
                            if (Main.App.drawingMode.isMirroring) {
                                var set = ShapeFigureSet.createWithShapes([
                                    drawing.render(),
                                    mMirrorFigure.render()
                                ]);
                                insertFigure(set.render());
                                extendDirtyRectWithDisplayObject(set, set.getTransformedBounds());
                            } else {
                                drawing.calcVertexes();
                                insertFigure(drawing.render());
                                extendDirtyRectWithDisplayObject(drawing,mBufferShape.getTransformedBounds());
                            }
                        }
                    }
                    default: {}
                }
                toDraw = true;
            } else {
                switch (mEventState) {
                    case CanvasEventState.Dragging: {
                        drawBoundingBox();
                        toDraw = true;
                    }
                    case CanvasEventState.Grabbing: {
                        if (activeFigure != null) {
                            activeFigure = null;
                            mBoundingBox.clear();
                            drawBoundingBox();
                        }
                        jq.css("cursor", BrowserUtil.grabCursor());
                    }
                    case CanvasEventState.Scaling: {
                        activeFigure.asShapeFigure(function(shape: ShapeFigure) {
                            var sx = shape.shapeScaleX*shape.scaleX;
                            var sy = shape.shapeScaleY*shape.scaleY;
                            shape.applyScale(sx,sy).render();
                        });
                        drawBoundingBox();
                        Main.App.layerView.invalidate(activeFigure);
                        toDraw = true;
                    }
                    default: {}
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
        mMirrorFigure = null;
        mBufferShape.graphics.clear();
        mPressed = false;
        mEventState = null;
        mBrushCircle.visible = BrowserUtil.isBrowser() && !isEditing;
        drawBrushCircle();
        trigger(ON_CANVAS_MOUSEUP_EVENT);
        if (toDraw) draw();
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
