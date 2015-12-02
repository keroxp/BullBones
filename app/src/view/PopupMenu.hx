package view;
import util.BrowserUtil;
import jQuery.JQuery;

class PopupMenu extends ViewModel {
    public var isShown = false;
    private var dir = "bottom";
    public function new(parent: JQuery) {
        var html =
        '<div class="arrow_box_wrapper" style="display:none" >
            <div class="arrow_box">
              <ul></ul>
            </div>
        </div>';
        super(new JQuery(html));
        parent.append(jq);
    }
    public function render (items: Array<PopupItem>): PopupMenu {
        jq.find("ul > li").remove();
        var frag = BrowserUtil.document.createDocumentFragment();
        for(item in items) {
            var li = BrowserUtil.document.createElement("li");
            li.innerHTML = item.title;
            li.addEventListener("click", function (e) {
                item.onclick(item);
            }, false);
            frag.appendChild(li);
        }
        jq.find("ul").get()[0].appendChild(frag);
        return this;
    }
    public function showAt(left: Float, top: Float, ?dir: String = "bottom", ?duration: Int = 0): PopupMenu {
        jq.find(".arrow_box").removeClass('arrow_box_${this.dir}').addClass('arrow_box_$dir');
        jq.css({"left": left, "top": top}).fadeIn(duration);
        this.dir= dir;
        this.isShown = true;
        return this;
    }
    public function dismiss(duration: Int = 0): PopupMenu {
        jq.fadeOut(duration, function(){
            jq.hide();
        });
        this.isShown = false;
        return this;
    }
}

class PopupItem {
    public var title: String;
    public var onclick: PopupItem -> Void;
    public function new (?title: String, ?onclick: PopupItem -> Void) {
        this.title = title;
        this.onclick = onclick;
    }
}