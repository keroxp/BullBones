package view;
import backbone.haxe.BackboneEvents;
import jQuery.JQuery;
class ViewModel extends BackboneEvents {
    public var jq: JQuery;
    public function new(?jq: JQuery) {
        super();
        this.jq = jq;
    }
}
