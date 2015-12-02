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
class ImageFigure extends Bitmap implements Figure {
    // non-filterd, non-scaled, original image,
    public var imageWrap(default,null): ImageWrap;
    public var editor(default,null): ImageEditor = new ImageEditor();

    public function new (img: ImageWrap) {
        super(cast img.image.cloneNode(true));
        imageWrap = img;
        cache(0,0,image.width,image.height);
    }

    override public function clone(): ImageFigure {
        var ret = new ImageFigure(imageWrap.clone());
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this,_clone,[ret]);
        ret.editor = editor.clone();
        ret.image = cast image.cloneNode(true);
        ret.cache(0,0,image.width,image.height);
        return ret;
    }

    override public function toString(): String {
        return '[ImageFigure id="${id}"]';
    }

    public function setFilterAsync(filter: Filter): Promise<ImageElement,Dynamic,Float> {
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

    public function render():Dynamic {
        return this;
    }

    public function setActive(bool:Bool):Void {
        this.alpha = bool ? .5: 1;
    }

}
