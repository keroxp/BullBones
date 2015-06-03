package view;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import createjs.easeljs.Event;
import jQuery.JQuery;
class BrushView {
    public var jq: JQuery;
    private var jWidthInput: JQuery;
    private var jAlphaInput: JQuery;
    private var jThickInput: JQuery;
    private var mCanvas: CanvasElement;
    private var mContext: CanvasRenderingContext2D;
    public function new(app: App, j: JQuery) {
        this.jq = j;
        mCanvas = cast jq.find("#brushPreviewCanvas").get()[0];
        mContext = mCanvas.getContext2d();
        jWidthInput = jq.find("#brushWidthInput");
        jWidthInput.attr("value", app.brushWidth);
        jAlphaInput = jq.find("#brushAlphaInput");
        jAlphaInput.attr("value", app.brushAlpha);
        jThickInput = jq.find("#brushThickInput");
        jThickInput.attr("value", app.brushThickness);
        jq.find("input").on("input", renderBrush);
        jq.find("input").on("change", function (e: Event) {
            Main.App.brushThickness = thick();
            Main.App.brushAlpha = alpha();
            Main.App.brushWidth = width();
        });
        renderBrush(null);
    }
    public function width(): Float return Std.parseFloat(cast jWidthInput.val());
    public function alpha(): Int return Std.parseInt(cast jAlphaInput.val());
    public function thick(): Int return Std.parseInt(cast jThickInput.val());

    private function renderBrush (e: Event) {
        var width = width();
        var alpha = alpha()/255;
        var thick = 255-Std.parseInt(cast jThickInput.val());
        var color = 'rgba($thick,$thick,$thick,$alpha)';
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
