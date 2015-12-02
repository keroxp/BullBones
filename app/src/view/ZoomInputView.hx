package view;
import model.ZoomEditor;
import jQuery.JQuery;
class ZoomInputView extends ViewModel {
    var jZoomValue: JQuery;
    public function new(jq: JQuery) {
        super(jq);
        var self = this;
        jq.find("#zoomOutButton").on("click", function(e) {
            Main.App.model.zoom = Main.App.model.zoom.zoomOut();
        });
        jq.find("#zoomInButton").on("click", function(e) {
            Main.App.model.zoom = Main.App.model.zoom.zoomIn();
        });
        jZoomValue = jq.find("#zoomValue");
    }
    override public function init() {
        listenTo(Main.App.model,"change:zoom", onChangeZoomScale);
    }
    private function onChangeZoomScale (model, value: ZoomEditor) {
        jZoomValue.html(Math.floor(value.scale*100)+"%");
    }
}
