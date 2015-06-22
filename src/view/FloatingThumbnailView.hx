package view;
import cv.ImageWrap;
import jQuery.JQuery;
class FloatingThumbnailView extends ViewModel {
    var thumbs: Array<FloatingThumbnail> = [];
    public function new(jq: JQuery) {
        super(jq);
    }
    public function add(img: ImageWrap, onclick: Void -> Void) {
        var dataUrl = img.src;
        var thumb = new FloatingThumbnail(dataUrl, img.id);
        thumb.jq.attr("data-image-id", img.id);
        thumb.jq.on("click", onclick);
        thumb.jImg.addClass(img.image.width > img.image.height ? "wide" : "tall");
        jq.append(thumb.jq);
        thumbs.push(thumb);
    }
    function find(img: ImageWrap): FloatingThumbnail {
        var tgt: FloatingThumbnail = null;
        for (t in thumbs) {
            if (t.id == img.id) {
                tgt = t;
                break;
            }
        }
        return tgt;
    }
    public function remove(img: ImageWrap) {
        var tgt = find(img);
        if (tgt != null) {
            tgt.jq.remove();
            thumbs.remove(tgt);
        }
    }
    public function contains(img: ImageWrap): Bool {
        return find(img) != null;
    }
    public function hide(img: ImageWrap) {
        var tgt = find(img);
        if (tgt != null) {
            tgt.jq.hide();
        }
    }
    public function show(img: ImageWrap) {
        var tgt = find(img);
        if (tgt != null) {
            tgt.jq.show();
        }
    }
}

class FloatingThumbnail extends ViewModel {
    public var jImg: JQuery;
    public var id: String;
    public function new(src: String, id: String) {
        this.id = id;
        var html =
        '<div class="floating-thumb circle z-depth-1">
         </div>';
        super(new JQuery(html));
        jq.css({
            "background-image": 'url("$src")',
            "background-size": "cover",
            "background-repeat": "no-repeat no-repeat"
        });
        jImg = jq.find("img");
    }
    public function render(src: String): FloatingThumbnail {
        jImg.attr("src", src);
        return this;
    }
}
