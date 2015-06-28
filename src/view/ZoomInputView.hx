package view;
import model.ZoomEditor;
import jQuery.JQuery;
class ZoomInputView extends ViewModel {
    var jZoomValue: JQuery;
    public function new(jq: JQuery) {
        super(jq);
        var self = this;
        jq.find("#zoomOutButton").on("click", function(e) {
            Main.App.v.zoom = Main.App.v.zoom.zoomOut();
        });
        jq.find("#zoomInButton").on("click", function(e) {
            Main.App.v.zoom = Main.App.v.zoom.zoomIn();
        });
        jZoomValue = jq.find("#zoomValue");
    }
    override public function init() {
        listenTo(Main.App.v,"change:zoom", onChangeZoomScale);
    }
    private function onChangeZoomScale (model, value: ZoomEditor) {
        jZoomValue.html(Math.floor(value.scale*100)+"%");
    }
}
