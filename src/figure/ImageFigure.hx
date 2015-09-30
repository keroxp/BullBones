package figure;
import model.ImageEditor;
import cv.ImageWrap;
import deferred.Deferred;
import deferred.Promise;
import js.html.ImageElement;
import cv.Images;
import cv.Filter;
import js.html.ImageData;
import createjs.easeljs.Bitmap;
class ImageFigure extends Bitmap {
    // non-filterd, non-scaled, original image,
    public var imageWrap(default,null): ImageWrap;
    public var editor: ImageEditor = new ImageEditor();

    public function new (img: ImageWrap) {
        super(cast img.image.cloneNode(true));
        imageWrap = img;
        cache(0,0,image.width,image.height);
        updateCache();
    }

    override public function clone(): ImageFigure {
        var ret = new ImageFigure(imageWrap.clone());
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this,_clone,[ret]);
        ret.image = cast image.cloneNode(true);
        if (filter != null) {
            ret.filter = filter.clone();
        }
        return ret;
    }

    override public function toString(): String {
        return '[ImageFigure id="${id}"]';
    }

    public var filter(default, null):Filter;

    public function setFilterAsync(filter: Filter): Promise<ImageElement,Dynamic,Float> {
        this.filter = filter;
        var pr = new Deferred<ImageElement,Dynamic,Float>();
        var self = this;
        filter.applyToImageData(Images.getImageData(imageWrap.image))
        .done(function(filtered: ImageData){
            self.image.onload = function (e) {
                var w = self.image.width;
                var h = self.image.height;
                self.cache(0,0,w,h);
                self.updateCache();
                pr.resolve(self.image);
            };
            self.image.onerror = function (e) {
                trace("hoge");
                pr.reject(e);
            };
            self.image.src = Images.toDataUrl(filtered);
        }).fail(function(e) {
            pr.reject(e);
        });
        return pr;
    }

}
