package view;
import model.ImageEditor;
import cv.ImageUtil;
import figure.Image;
import ajax.Loader;
import js.html.ImageData;
import js.html.Event;
import jQuery.JQuery;

interface ImageEditorListener {
    public function onImageEditorChange (editor: ImageEditor): Void;
}

class ImageEditorView extends ViewModel {
    private var jImg: JQuery;
    private var mEditor: ImageEditor = new ImageEditor();
    public var listener: ImageEditorListener;
    public function new(jq: JQuery) {
        super(jq);
        // img
        jImg = new JQuery("#imageEditorPreviewImage");
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
    private var mThumbData: ImageData;
    private var mImage: Image;
    public function setImage (value: Image) {
        if (value != null && mImage != value) {
            Loader.loadImage(value.thumbSrc).done(function(img: js.html.Image) {
                mThumbData = ImageUtil.getImageData(img);
                jImg.attr("src", ImageUtil.toDataUrl(mThumbData,"image/png"));
            }).fail(function (e: Dynamic) {
                trace(e);
            });
            mImage = value;
        }
        if (mThumbData != null) {
            renderThumb();
        }
    }
    private function renderThumb() {
        var f = mEditor.createFilter();
        var id = f.applyToImageData(mThumbData);
        jImg.attr("src", ImageUtil.toDataUrl(id,"image/png"));
    }
    private function postOnChange (editor: ImageEditor) {
        if (listener != null) {
            listener.onImageEditorChange(editor);
        }
    }
}
