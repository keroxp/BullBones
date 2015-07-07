package view;
import util.Log;
import createjs.easeljs.DisplayObject;
import cv.ImageWrap.AspectPolicy;
import js.html.CanvasElement;
import rollbar.Rollbar;
import js.html.Image;
import model.ImageEditor;
import cv.ImageUtil;
import figure.ImageFigure;
import ajax.Loader;
import js.html.ImageData;
import js.html.Event;
import jQuery.JQuery;
using util.FigureUtil;
interface ImageEditorListener {
    public function onImageEditorChange (editor: ImageEditor): Void;
}

class ImageEditorView extends ViewModel {
    private var mCanvas: CanvasElement;
    private var mEditor: ImageEditor = new ImageEditor();
    public var listener: ImageEditorListener;
    public function new(jq: JQuery) {
        super(jq);
        // img
        mCanvas = cast jq.find("#imageEditorPreviewCanvas").get()[0];
        jq.find("#grayInput").on("change", function(e){
            mEditor.gray = !mEditor.gray;
            renderThumb();
            postOnChange(mEditor);
        });
        jq.find("#lineExtractInput").on("change", function (e) {
            mEditor.lineExtraction = !mEditor.lineExtraction;
            jq.find("#lineExtractInputWrapper").toggle();
            renderThumb();
            postOnChange(mEditor);
        });
        jq.find("#lineExtractSwitchInput").on("change", function(e: Event) {
            mEditor.useLaplacian8 = !mEditor.useLaplacian8;
            renderThumb();
            postOnChange(mEditor);
        });
        jq.find("#imageAlpha").on("input", function(e) {
            mEditor.alpha = Std.parseInt(cast new JQuery(e.target).val())/100;
            renderThumb();
        }).on("change", function(e) {
            postOnChange(mEditor);
        });
    }

    override public function init() {
        listenTo(Main.App.mainCanvas, "change:activeFigure", onactiveFigureChange);
    }

    private var mThumbData: ImageData;
    private var mImage: ImageFigure;
    public function onactiveFigureChange (canvas: MainCanvas, value: DisplayObject) {
        if (value != null && value.isImageFigure() && value != mImage) {
            var fig: ImageFigure = cast value;
            mThumbData = fig.imageWrap.getResizedImageData(220,100,AspectPolicy.AspectToFit);
            mImage = fig;
        }
        if (mThumbData != null) {
            renderThumb();
        }
    }
    private function renderThumb() {
        var f = mEditor.createFilter();
        f.applyToImageData(mThumbData).done(function(id: ImageData) {
            var x = (220-id.width)*0.5;
            var y = (100-id.height)*0.5;
            var ctx = mCanvas.getContext2d();
            ctx.clearRect(0,0,220,100);
            ctx.putImageData(id,x,y);
        }).fail(function (e) {
            Log.e(e);
            Rollbar.error(e);
        });

    }
    private function postOnChange (editor: ImageEditor) {
        if (listener != null) {
            listener.onImageEditorChange(editor);
        }
    }
}
