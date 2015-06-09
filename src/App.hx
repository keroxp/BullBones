package ;

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

class App extends BackboneEvents
implements BrushEditorListener
implements MainCanvasListener {
    public var v(default, null): V;
    private var jSearchButton: JQuery;
    private var jBrushButton: JQuery;
    private var jEditButton: JQuery;
    private var jImageButton: JQuery;
    private var jDebugButton: JQuery;
    private var mMainCanvas: MainCanvas;
    private var mSearchView: SearchView;
    private var mBrushView: BrushEditorView;
    private var mImageEditorView: ImageEditorView;
    var window: DOMWindow = Browser.window;
    var document = Browser.document;

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
            ViewUtil.on("appView", "dragover", onDragOver);
            ViewUtil.on("appView", "drop", onDrop);
            // メインキャンバス
            mMainCanvas = new MainCanvas(new JQuery("#mainCanvas"));
            mMainCanvas.listener = this;
            listenTo(mMainCanvas, MainCanvas.ON_CANVAS_MOUSEDOWN_EVENT, function (e: Dynamic) {
                mBrushView.jq.hide();
                mSearchView.jq.hide();
                mImageEditorView.jq.hide();
            });
            // 検索ビュー
            mSearchView = new SearchView(new JQuery("#searchView"));
            mSearchView.listener = mMainCanvas;
            // ブラシ
            mBrushView = new BrushEditorView(new JQuery("#brushWrapper"));
            mBrushView.listener = this;
            // 画像エディタ
            mImageEditorView = new ImageEditorView(new JQuery("#imageEditorView"));
            mImageEditorView.listener = mMainCanvas;
            // 検索ボタン
            jSearchButton = new JQuery("#searchButton");
            jSearchButton.on("click", function (e: MouseEvent) {
                hidePanels(mSearchView);
                mSearchView.toggle();
            });
            // ブラシボタン
            var brushButton = new JQuery("#brushButton");
            brushButton.on("click", function(e: MouseEvent) {
                hidePanels(mBrushView);
                mBrushView.jq.toggle();
            });
            // 編集ボタン
            jEditButton = new JQuery("#editButton");
            jEditButton.on("click", function (e: MouseEvent) {
                hidePanels();
                mMainCanvas.toggleEditing();
            });
            // 画像ボタン
            jImageButton = new JQuery("#imageEditorButton");
            jImageButton.on("click", function(e: MouseEvent) {
                hidePanels(mImageEditorView);
                mImageEditorView.jq.toggle();
            });
            // デバッグボタン
            new JQuery("#debugButton").on("click", function (e: MouseEvent){
                this.v.isDebug = !this.v.isDebug;
            });
        });
    }

    private function hidePanels (?exclude: ViewModel) {
        if (exclude != mImageEditorView) mImageEditorView.jq.hide();
        if (exclude != mSearchView ) mSearchView.jq.hide();
        if (exclude != mBrushView) mBrushView.jq.hide();
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
        trace(e.dataTransfer.files);
        var files = e.dataTransfer.files;
        if (files.length > 0) {
            var f = files.item(0);
            if (f.type.indexOf("image/") > -1) {

            }
        }
    }

    // Listeners

    public function onBrushEditorChange(editor:BrushEditor):Void {
        this.v.brush = editor;
    }

    public function onCanvasImageSelected(image:ImageFigure):Void {
        if (image != null) {
            jImageButton.show();
            mImageEditorView.setImage(image);
        } else {
            jImageButton.hide();
        }
    }

}
