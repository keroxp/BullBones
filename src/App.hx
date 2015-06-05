package ;

import view.ViewModel;
import figure.Image;
import ajax.BingSearch.BingSearchResult;
import MainCanvas;
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
            var document = Browser.document;
            var window: DOMWindow = Browser.window;
            var w: Float = window.innerWidth;
            var h: Float = window.innerHeight;
            var canvasDom = new JQuery("#mainCanvas");
            canvasDom.attr({
                width : w,
                height: h
            });
            // メインキャンバス
            mMainCanvas = new MainCanvas(canvasDom);
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

    public function onBrushEditorChange(editor:BrushEditor):Void {
        this.v.brush = editor;
    }

    public function onCanvasImageSelected(image:Image):Void {
        if (image != null) {
            jImageButton.show();
            mImageEditorView.setImage(image);
        } else {
            jImageButton.hide();
        }
    }

}
