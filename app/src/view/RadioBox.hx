package view;
import js.html.Element;
import js.html.MouseEvent;
import jQuery.JQuery;
class RadioBox extends ViewModel {
    public var indexes: Array<Int> = [];
    public var multiSelectable: Bool = false;
    private var jRadios: JQuery;
    public function new(jq: JQuery, onChange: Int -> Void, ?defaultIndex: Int) {
        super(jq);
        jRadios = jq.find(".radioParts");
        jRadios.on("click", function (e: MouseEvent) {
            var thiz = cast(e.target, Element);
            if (multiSelectable) {
                thiz.closest("a").classList.toggle("editing");
            } else {
                jRadios.removeClass("editing");
                thiz.closest("a").classList.add("editing");
            }
            var idx = Std.parseInt(thiz.closest(".radioParts").dataset.radioIndex);
            onChange(idx);
        });
        if (defaultIndex != null) {
            select(defaultIndex);
        }
    }
    public function select(i: Int) {
        var j: JQuery = jRadios.filter('[data-radio-index="$i"]');
        if (!multiSelectable) {
            jRadios.removeClass("editing");
        }
        j.addClass("editing");
    }
}
