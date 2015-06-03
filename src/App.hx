package ;

import view.BrushView;
import js.html.DOMWindow;
import jQuery.JQuery;
import js.html.MouseEvent;
import view.SearchView;
import js.Browser;

class App extends Model {
    @:isVar public var brushWidth(get, set):Float;

    function get_brushWidth():Float {
        return get("brushWidth");
    }
    function set_brushWidth(value:Float): Float {
        set("brushWidth", value);
        return value;
    }

    @:isVar public var brushColor(get, null):String;

    function get_brushColor():String {
        var alpha = brushAlpha/255;
        var thick = 255-brushThickness;
        var ret = 'rgba($thick,$thick,$thick,$alpha)';
        trace(ret);
        return ret;
    }

    @:isVar public var brushThickness(get, set):Int;

    function get_brushThickness():Int {
        return get("brushThickness");
    }

    function set_brushThickness(value:Int) {
        set("brushThickness",value);
        return value;
    }

    @:isVar public var brushAlpha(get, set):Int;

    function get_brushAlpha():Int {
        return get("brushAlpha");
    }

    function set_brushAlpha(value:Int): Int {
        set("brushAlpha", value);
        return value;
    }

    @:isVar public var isEditing(get, set):Bool;

    function get_isEditing():Bool {
        return get("isEditing");
    }

    function set_isEditing(value:Bool): Bool {
        set("isEditing", value);
        return value;
    }

    @:isVar public var isDebug(get, set):Bool;

    function get_isDebug():Bool {
        return get("isDebug");
    }

    function set_isDebug(value:Bool) {
        set("isDebug", value);
        return value;
    }
    private var jSearchButton: JQuery;
    private var jBrushButton: JQuery;
    private var jEditButton: JQuery;
    private var jDebugButton: JQuery;
    private var mMainCanvas: MainCanvas;
    private var mSearchView: SearchView;
    private var mBrushView: BrushView;

    public function new(attr: Dynamic) {
        super(attr);
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
            mMainCanvas = new MainCanvas(this, canvasDom);
            listenTo(mMainCanvas, MainCanvas.ON_CANVAS_MOUSEDOWN_EVENT, function (e: Dynamic) {
                mBrushView.jq.hide();
                mSearchView.jq.hide();
            });
            // 検索ビュー
            mSearchView = new SearchView("searchView");
            mSearchView.onSelectImage = mMainCanvas.onSelectImage;
            // ブラシビュー
            mBrushView = new BrushView(this,new JQuery("#brushWrapper"));
            // 検索ボタン
            jSearchButton = new JQuery("#searchButton");
            jSearchButton.on("click", function (e: MouseEvent) {
                mSearchView.toggle();
            });
            // ブラシボタン
            var brushButton = new JQuery("#brushButton");
            brushButton.on("click", function(e: MouseEvent) {
                mBrushView.jq.toggle();
            });
            // 編集ボタン
            jEditButton = new JQuery("#editButton");
            jEditButton.on("click", function (e: MouseEvent) {
                mMainCanvas.toggleEditing();
            });
            // デバッグボタン
            jDebugButton = new JQuery("#debugButton");
            jDebugButton.on("click", function (e: MouseEvent){
                isDebug = !isDebug;
            });
        });
    }
    public function start () {
        once("app:start", function (a: Dynamic) {
            trace("BullBones started!");
        });
        trigger("app:start");
    }
}
