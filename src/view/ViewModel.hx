package view;
import backbone.Model;
import jQuery.JQuery;
class ViewModel extends Model {
    public var jq: JQuery;
    public function new(?jq: JQuery) {
        super();
        this.jq = jq;
    }
    public function init() {

    }
}
