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
    function find(imageId: String): FloatingThumbnail {
        var tgt: FloatingThumbnail = null;
        for (t in thumbs) {
            if (t.imageId == imageId) {
                tgt = t;
                break;
            }
        }
        return tgt;
    }
    public function remove(imageId: String) {
        var tgt = find(imageId);
        if (tgt != null) {
            tgt.jq.remove();
            thumbs.remove(tgt);
        }
    }
}

class FloatingThumbnail extends ViewModel {
    public var jImg: JQuery;
    public var imageId: String;
    public function new(src: String, id: String) {
        this.imageId = id;
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
