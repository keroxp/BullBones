package ;

import figure.Draggable;
import model.BBModel;
import js.html.ProgressEvent;
import js.html.fs.FileError;
import ajax.Loader;
import createjs.easeljs.Event;
import view.ViewUtil;
import model.BrushEditor;
import view.MainCanvas;
import view.ViewModel;
import figure.ImageFigure;
import backbone.haxe.BackboneEvents;
import view.ImageEditorView;
import view.BrushEditorView;
import js.html.DOMWindow;
import jQuery.JQuery;
import js.html.MouseEvent;
import view.SearchView;
import js.Browser;
using figure.Draggable.DraggableUtil;
typedef OnFileLoadListenr = String -> Void

class App extends BackboneEvents implements BrushEditorListener {
    public var v(default, null): V;
    private var jModalLoading: JQuery;
    private var jSearchButton: JQuery;
    private var jBrushButton: JQuery;
    private var jEditButton: JQuery;
    private var jImageButton: JQuery;
    private var jDebugButton: JQuery;
    public var mainCanvas: MainCanvas;
    public var searchView: SearchView;
    public var brushEditorView: BrushEditorView;
    public var imageEditorView: ImageEditorView;
    var window: DOMWindow = Browser.window;
    var document = Browser.document;
    public var onFileLoad: OnFileLoadListenr;
    public static var APP_WINDOW_RESIZE_EVENT = "BullBones:APP_WINDOW_RESIZE_EVENT";

    public function new(attr: Dynamic) {
        super();
        this.v = new V(attr);
    }
    public function start () {
        once("app:start", function (a: Dynamic) {
            trace("BullBones started!");
        });
        trigger("app:start");
        new JQuery(function () {
            new JQuery(window).resize(onWindowResize);
            window.addEventListener("dragover", onDragOver);
            window.addEventListener("drop", onDrop);
            // Loading View
            jModalLoading = new JQuery("#modalLoadingView");
            // メインキャンバス
            mainCanvas = new MainCanvas(new JQuery("#mainCanvas"));
            listenTo(mainCanvas, MainCanvas.ON_CANVAS_MOUSEDOWN_EVENT, function (e: Dynamic) {
                brushEditorView.jq.hide();
                searchView.jq.hide();
                imageEditorView.jq.hide();
            });
            listenTo(mainCanvas, "change:isEditing", function (mode: BBModel, value: Bool) {
                hidePanels();
            });
            listenTo(mainCanvas, "change:activeFigure", function (c: MainCanvas, value: Draggable) {
                if (value.isImageFigure()) {
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
            imageEditorView.listener = mainCanvas;
            // 検索ボタン
            jSearchButton = new JQuery("#searchButton");
            jSearchButton.on("click", function (e: MouseEvent) {
                mainCanvas.isEditing = false;
                searchView.toggle();
            });
            // ブラシボタン
            var brushButton = new JQuery("#brushButton");
            brushButton.on("click", function(e: MouseEvent) {
                hidePanels(brushEditorView);
                brushEditorView.jq.toggle();
            });
            // 編集ボタン
            jEditButton = new JQuery("#editButton");
            jEditButton.on("click", function (e: MouseEvent) {
                hidePanels();
                mainCanvas.toggleEditing();
            });
            // 画像ボタン
            jImageButton = new JQuery("#imageEditorButton");
            jImageButton.on("click", function(e: MouseEvent) {
                hidePanels(imageEditorView);
                imageEditorView.jq.toggle();
            });
            // デバッグボタン
            new JQuery("#debugButton").on("click", function (e: MouseEvent){
                this.v.isDebug = !this.v.isDebug;
            });

            mainCanvas.init();
            searchView.init();
            imageEditorView.init();
            brushEditorView.init();

            // hide loading
            haxe.Timer.delay(function() {
                jModalLoading.fadeOut(700);
            }, 2400);
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

    private function onDragOver (e: MouseEvent) {
        e.preventDefault();
        e.stopPropagation();
        e.dataTransfer.dropEffect = 'copy';
    }

    private function onDrop (e: MouseEvent) {
        e.preventDefault();
        e.stopPropagation();
        trace("file dopped");
        var files = e.dataTransfer.files;
        if (files.length > 0) {
            var f = files.item(0);
            Loader.loadFile(f)
            .done(function (url: String) {
                if (onFileLoad != null) onFileLoad(url);
            }).fail(function (e: FileError) {
                trace(e);
                js.Lib.alert("読み込めない形式です");
            }).progress(function (p: ProgressEvent) {
                trace(p);
            });
        }
    }

    // Listeners

    public function onBrushEditorChange(editor:BrushEditor):Void {
        this.v.brush = editor;
    }


}
