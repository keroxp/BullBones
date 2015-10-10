package ;

import js.Error;
import figure.FigureType;
import model.MirroringInfo;
import view.LayerView;
import createjs.easeljs.DisplayObject;
import cv.ImageWrap;
import view.ZoomInputView;
import view.FloatingThumbnailView;
import util.Log;
import js.html.DragEvent;
import js.html.PopStateEvent;
import util.BrowserUtil;
import view.ModalView;
import model.BaseModel;
import ajax.Loader;
import model.BrushEditor;
import canvas.MainCanvas;
import view.ViewModel;
import backbone.haxe.BackboneEvents;
import view.ImageEditorView;
import view.BrushEditorView;
import jQuery.JQuery;
import js.html.MouseEvent;
import view.SearchView;
import js.Browser;
using figure.Figures;

class App extends BackboneEvents implements BrushEditorListener {
    public var model(default, null): AppModel;
    private var jModalLoading: JQuery;
    private var jSearchButton: JQuery;
    private var jBrushButton: JQuery;
    private var jEditButton: JQuery;
    private var jLayerButton: JQuery;
    private var jImageButton: JQuery;
    private var jDebugButton: JQuery;
    public var jq: JQuery;
    public var modalView(default,null): ModalView;
    public var mainCanvas(default,null): MainCanvas;
    public var searchView(default,null): SearchView;
    public var brushEditorView(default,null): BrushEditorView;
    public var imageEditorView(default,null): ImageEditorView;
    public var floatingThumbnailView(default,null): FloatingThumbnailView;
    public var zoomInputView(default,null): ZoomInputView;
    public var layerView(default,null): LayerView;
    var window = BrowserUtil.window;
    var document = BrowserUtil.document;
    public static var APP_WINDOW_RESIZE_EVENT = "BullBones:APP_WINDOW_RESIZE_EVENT";
    public static var APP_ON_START_EVENT = "BullBones:APP_ON_START";

    public function new(attr: Dynamic) {
        super();
        this.model = new AppModel(attr);
        if (window.location.href.indexOf("http://localhost:8000") == 0) {
            this.model.isDebug = true;
        }
        trace(this.model.attributes);
    }
    public function start () {
        once("app:start", function (a: Dynamic) {
            Log.d("BullBones started!");
        });
        trigger("app:start");
        new JQuery(function () {
            jq = new JQuery("#appView");
            new JQuery(window).resize(onWindowResize);
            window.scrollTo(0,0);
            window.addEventListener("dragover", onDragOver);
            window.addEventListener("drop", onDrop);
            // Loading View
            jModalLoading = new JQuery("#modalLoadingView");
            // Modal View
            modalView = new ModalView(new JQuery("#modalView"));
            // メインキャンバス
            mainCanvas = new MainCanvas(new JQuery("#mainCanvas"));
            listenTo(mainCanvas, MainCanvas.ON_CANVAS_MOUSEDOWN_EVENT, function (e: Dynamic) {
                brushEditorView.jq.hide();
                searchView.jq.hide();
                imageEditorView.jq.hide();
            });
            listenTo(mainCanvas, "change:isEditing", function (mode: BaseModel, value: Bool) {
                hidePanels();
                jEditButton.toggleClass("editing", value);
            });
            listenTo(mainCanvas, "change:activeFigure", function (c: MainCanvas, value: DisplayObject) {
                if (value != null && value.type() == FigureType.Image) {
                    jImageButton.show();
                } else {
                    jImageButton.hide();
                }
            });
            // 検索ビュー
            searchView = new SearchView(new JQuery("#searchView"));
            searchView.listener = mainCanvas;
            // ブラシ
            brushEditorView = new BrushEditorView(new JQuery("#brushWrapper"));
            brushEditorView.listener = this;
            // 画像エディタ
            imageEditorView = new ImageEditorView(new JQuery("#imageEditorView"));
            // ThumbView
            floatingThumbnailView = new FloatingThumbnailView(new JQuery("#floatingThumbnailView"));
            // Zoom
            zoomInputView = new ZoomInputView(new JQuery("#zoomInputGroup"));
            // Layer
            layerView = new LayerView(new JQuery("#layerView"));
            // 検索ボタン
            jSearchButton = new JQuery("#searchButton");
            jSearchButton.on("click", function (e: MouseEvent) {
                mainCanvas.isEditing = false;
                searchView.toggle();
            });
            var click = BrowserUtil.isMobile ? "touchstart" : "click";
            // ブラシボタン
            var brushButton = new JQuery("#brushButton");
            brushButton.on(click, function(e: MouseEvent) {
                hidePanels(brushEditorView);
                brushEditorView.jq.toggle();
            });
            // 編集ボタン
            jEditButton = new JQuery("#editModeButton");
            jEditButton.on(click, function (e: MouseEvent) {
                hidePanels();
                mainCanvas.isEditing = !mainCanvas.isEditing;
                jEditButton.toggleClass("editing", mainCanvas.isEditing);
            });
            // 画像ボタン
            jImageButton = new JQuery("#imageEditorButton");
            jImageButton.on(click, function(e: MouseEvent) {
                hidePanels(imageEditorView);
                imageEditorView.toggle();
            });
            // デバッグボタン
            new JQuery("#debugButton").on(click, function (e: MouseEvent){
                this.model.isDebug = !this.model.isDebug;
            });
            // Undo/Redo
            var jUndoButton: JQuery = new JQuery("#undoButton").on(click, function(e: MouseEvent) {
                mainCanvas.undo();
            });
            var jRedoButton: JQuery = new JQuery("#redoButton").on(click, function(e: MouseEvent) {
                mainCanvas.redo();
            });
            // 線対称
            var jLineSymmetryButton: JQuery = new JQuery("#lineSymmetryButton");
            jLineSymmetryButton.on(click, function(e: MouseEvent) {
                mainCanvas.mirroringInfo.enabled = !mainCanvas.mirroringInfo.enabled;
                mainCanvas.mirroringInfo.mirroringType = MirroringType.Line;
                jLineSymmetryButton.toggleClass("editing", mainCanvas.mirroringInfo.enabled);
            });
            var jLineSymmetryPivotButton: JQuery = new JQuery("#lineSymmetryPivotButton");
            jLineSymmetryPivotButton.on(click, function(e: MouseEvent) {
                mainCanvas.mirroringInfo.pivotEnabled = !mainCanvas.mirroringInfo.pivotEnabled;
                jLineSymmetryPivotButton.toggleClass("editing", mainCanvas.mirroringInfo.pivotEnabled);
            });
            var jDrawingBrushButton: JQuery = new JQuery("#drawingBrushButton");
            var jSmoothBrushButton: JQuery = new JQuery("#smoothBrushButton");
            jDrawingBrushButton.on(click, function(e: MouseEvent) {
                mainCanvas.toolType = Brush;
                jSmoothBrushButton.toggleClass("editing", mainCanvas.toolType == Smooth);
                jDrawingBrushButton.toggleClass("editing", mainCanvas.toolType == Brush);
            });
            jSmoothBrushButton.on(click, function(e: MouseEvent) {
                mainCanvas.toolType = Smooth;
                jDrawingBrushButton.toggleClass("editing", mainCanvas.toolType == Brush);
                jSmoothBrushButton.toggleClass("editing", mainCanvas.toolType == Smooth);
            });
            // Layer
            jLayerButton = new JQuery("#layerButton").on(click, function(e: MouseEvent) {
                layerView.jq.toggle();
                jLayerButton.toggleClass("editing");
            });
            listenTo(model, "change:undoStackSize", function (m,val:Int) {
                if (val == 0) {
                    jUndoButton.attr("data-enabled","false");
                } else if (jUndoButton.data("enabled") == false && val == 1) {
                    jUndoButton.attr("data-enabled", "true");
                }
            });
            listenTo(model, "change:redoStackSize", function (m,val:Int) {
                if (val == 0) {
                    jRedoButton.attr("data-enabled", "false");
                } else if (jRedoButton.data("enabled") == false && val == 1) {
                    jRedoButton.attr("data-enabled", "true");
                }
            });
            new JQuery("#exportButton").on(click, function(e: MouseEvent) {
                modalView.beginExporting(function(val) {
                    mainCanvas.isExporting = val;
                }).open();
            });
            mainCanvas.init();
            searchView.init();
            imageEditorView.init();
            brushEditorView.init();
            floatingThumbnailView.init();
            zoomInputView.init();
            layerView.init();

            // hide loading
            haxe.Timer.delay(function() {
                jModalLoading.fadeOut(700, function(){
                    if (this.model.isDebug || !BrowserUtil.isBrowser) {
                        modalView.openOnce(ModalView.ADD_TO_HOMESCREEN);
                    }
                });
            }, 2400);
            // diable back action
            window.onunload = function (a) {};
            if (!this.model.isDebug) {
                window.onbeforeunload = function (a) {
                    return "ページを再読み込みしようとしています。\n保存されていないデータは消えてしまいます。";
                };
            }
            window.history.pushState( "nohb", null, "" );
            window.addEventListener("popstate", function(e: PopStateEvent){
                if(!e.state) {
                    window.history.pushState( "nohb", null, "" );
                    return;
                }
            });
            window.history.forward();
        });
    }

    public function toggleModalLoading () {
        jModalLoading.toggle();
    }

    private function hidePanels (?exclude: ViewModel) {
        if (exclude != imageEditorView) imageEditorView.jq.hide();
        if (exclude != searchView ) searchView.jq.hide();
        if (exclude != brushEditorView) brushEditorView.jq.hide();
    }

    // Global Event Handlers
    private var mTimer: Int = -1;
    private function onWindowResize (e: jQuery.Event) {
        if (mTimer > -1) {
            window.clearTimeout(mTimer);
        }
        mTimer = window.setTimeout(function () {
            trigger(APP_WINDOW_RESIZE_EVENT);
        }, 400);
    }

    private function onDragOver (e: DragEvent) {
        e.preventDefault();
        e.stopPropagation();
        e.dataTransfer.dropEffect = 'copy';
    }

    private function onDrop (e: DragEvent) {
        e.preventDefault();
        e.stopPropagation();
        var files = e.dataTransfer.files;
        if (files.length > 0) {
            var f = files.item(0);
            try {
                Loader.loadFile(f)
                .done(function (img: ImageWrap) {
                    mainCanvas.onFileLoad(img);
                }).fail(function (e: Error) {
                    Browser.alert(e);
                });
            } catch (err: Error) {
                Browser.alert(err.message);
            }
        }
    }

    // Listeners

    public function onBrushEditorChange(editor:BrushEditor):Void {
        this.model.brush = editor;
    }


}
