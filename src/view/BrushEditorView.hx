package view;
import model.BrushEditor;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import createjs.easeljs.Event;
import jQuery.JQuery;

interface BrushEditorListener {
    public function onBrushEditorChange(editor: BrushEditor): Void;
}

class BrushEditorView extends ViewModel {
    private var jWidthInput: JQuery;
    private var jAlphaInput: JQuery;
    private var jThickInput: JQuery;
    private var mCanvas: CanvasElement;
    private var mContext: CanvasRenderingContext2D;
    public var listener: BrushEditorListener;
    public function new(j: JQuery) {
        super(j);
        mCanvas = cast jq.find("#brushPreviewCanvas").get()[0];
        mContext = mCanvas.getContext2d();
        jWidthInput = jq.find("#brushWidthInput");
        jWidthInput.attr("value", Main.App.v.brush.width);
        jAlphaInput = jq.find("#brushAlphaInput");
        jAlphaInput.attr("value", Main.App.v.brush.alpha*100);
        jThickInput = jq.find("#brushThickInput");
        jThickInput.attr("value", Main.App.v.brush.thickness);
        jq.find("input").on("input", function (e) {
            var brush = new BrushEditor();
            brush.thickness = thick();
            brush.width = width();
            brush.alpha = alpha();
            Main.App.v.brush = brush;
            renderBrush(e);
        });
        jq.find("input").on("change", function (e: Event) {
            if (listener != null) {
                listener.onBrushEditorChange(Main.App.v.brush);
            }
        });
        renderBrush(null);
    }
    public function width(): Float return Std.parseFloat(cast jWidthInput.val());
    public function alpha(): Float return Std.parseInt(cast jAlphaInput.val())/100;
    public function thick(): Int return Std.parseInt(cast jThickInput.val());

    private function renderBrush (e: Event) {
        var width = Main.App.v.brush.width;
        var color = Main.App.v.brush.color;
        var pad = 30;
        var padx = 30;
        var pady = 100;
        mContext.clearRect(0,0,mCanvas.width,mCanvas.height);
        mContext.beginPath();
        mContext.moveTo(pad,mCanvas.height-pad);
        mContext.bezierCurveTo(
            pad+padx,pad-pady,
            mCanvas.width-pad-padx,mCanvas.height-pad+pady,
            mCanvas.width-pad,pad
        );
        mContext.strokeStyle = color;
        mContext.lineWidth = width;
        mContext.lineCap = "round";
        mContext.stroke();
    }
}
