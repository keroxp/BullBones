package view;
import ajax.Loader;
import js.html.Image;
import util.ArrayUtil;
import backbone.haxe.BackboneCollection;
import backbone.Collection;
import util.Log;
import util.BrowserUtil;
import cv.Images;
import jQuery.JQuery;
using util.ArrayUtil;
class SimilarLineSuggestView extends ViewModel {
    var mItmes: Array<SimilarLineItemView> = [];
    public function new(jq: JQuery) {
        super(jq);
    }
    public static var SUGGEST_SELECTED_EVENT: String = "SUGGEST_SELECTED_EVENT";
    public function render (lines: Array<Dynamic>) {
        jq.children().remove();
        mItmes.clear();
        var f = BrowserUtil.document.createDocumentFragment();
        var h = Math.round(jq.outerHeight());
        for (line in lines) {
            var item = new SimilarLineItemView(line.line_id,line.category);
//            item.image.height = h;
            item.jq.on("click", function() {
                trigger(SUGGEST_SELECTED_EVENT,item.image);
            });
            item.jq.on("dragstart", function(e) {
               Log.d(this);
            });
            mItmes.push(item);
            f.appendChild(item.el);
        }
        el.appendChild(f);
    }
}

class SimilarLineItemView extends ViewModel {
    public var image: Image;
    public var lineId: Int;
    public var category: String;
    public function new(lineId: Int, category: String) {
        super(new JQuery('<div class="similarLinesListItem" draggable="true"></div>'));
        this.lineId = lineId;
        this.category = category;
        image = new Image();
        image.src = Images.WHITE_IMG;
        image.src = '/image_match?line_id=${lineId}';
        jq.attr("data-line-id", lineId);
        jq.attr("data-category", category);
        jq.append(image);
    }
}
