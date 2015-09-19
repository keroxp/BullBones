package view;
import js.html.Element;
import backbone.Model;
import jQuery.JQuery;
class ViewModel extends Model {
    public var jq: JQuery;
    @:isVar public var el(get, null):Element;
    function get_el():Element {
        return cast this.jq.get()[0];
    }

    public function new(jq: JQuery) {
        super();
        this.jq = jq;
    }
    public function init() {

    }
}
