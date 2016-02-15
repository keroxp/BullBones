package view;
import canvas.MainCanvas;
import cv.AspectPolicy;
import cv.Images;
import figure.FigureType;
import util.Log;
import createjs.easeljs.DisplayObject;
import js.html.CanvasElement;
import rollbar.Rollbar;
import model.ImageEditor;
import figure.ImageFigure;
import js.html.ImageData;
import js.html.Event;
import jQuery.JQuery;
using figure.Figures;

class ImageEditorView extends ViewModel {
    private var mCanvas: CanvasElement;
    private var mAlpha: Float = 1.0;
    private var mDirty: Bool = false;
    public function new(jq: JQuery) {
        super(jq);
        // img
        mCanvas = cast jq.find("#imageEditorPreviewCanvas").get()[0];
        jq.find("#grayInput").on("change", function(e){
            mImage.editor.gray = !mImage.editor.gray;
        });
        jq.find("#lineExtractInput").on("change", function (e) {
            mImage.editor.lineExtraction = !mImage.editor.lineExtraction;
            jq.find("#lineExtractInputWrapper").toggle();
        });
        jq.find("#lineExtractSwitchInput").on("change", function(e: Event) {
            mImage.editor.useLaplacian8 = !mImage.editor.useLaplacian8;
        });
        jq.find("#imageAlpha").on("input", function(e) {
            mAlpha = Std.parseInt(cast new JQuery(e.target).val())/100;
        }).on("change", function(e) {
            mImage.editor.alpha = mAlpha;
        });
    }

    override public function init() {
        listenTo(Main.App.mainCanvas, "change:activeLayer", onChangeActiveLayer);
    }

    private var mThumbData: ImageData;
    private var mImage: ImageFigure;
    public function onChangeActiveLayer (canvas: MainCanvas, value: DisplayObject) {
        if (value == mImage) return;
        if (value != null && value.type() == FigureType.TypeImage) {
            mImage = cast value;
            listenTo(mImage.editor, "change", reRenderThumb);
        } else if (mImage != null){
            stopListening(mImage.editor, "change", reRenderThumb);
            mImage = null;
            mThumbData = null;
        }
    }

    public function toggle() {
        if (jq.css("display") == "none") {
            open();
        } else {
            hide();
        }
    }
    public function open () {
        mThumbData = Images.getResizedImageData(
            cast mImage.image,
            220,100,
            AspectPolicy.AspectToFit
        );
        renderThumb(mThumbData);
        jq.show();
    }

    public function hide() {
        jq.hide();
    }

    private function reRenderThumb() {
        var f = mImage.editor.createFilter(true);
        f.applyToImageData(mThumbData).done(function(id: ImageData) {
            renderThumb(id);
        }).fail(function (e) {
            Log.e(e);
            Rollbar.error(e);
        });
    }

    private function renderThumb (id: ImageData) {
        var x = (220-id.width)*0.5;
        var y = (100-id.height)*0.5;
        var ctx = mCanvas.getContext2d();
        ctx.clearRect(0,0,220,100);
        ctx.globalAlpha = mAlpha;
        ctx.globalCompositeOperation = "destination-in";
        ctx.putImageData(id,x,y);
    }

}
