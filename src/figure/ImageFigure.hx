package figure;
import js.Browser;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import model.ImageEditor;
import cv.ImageWrap;
import deferred.Deferred;
import deferred.Promise;
import js.html.ImageElement;
import cv.Images;
import cv.Filter;
import js.html.ImageData;
class ImageFigure extends BaseFigure {
    // non-filterd, non-scaled, original image,
    public var image(default,null): ImageWrap;
    public var editor: ImageEditor = new ImageEditor();
    var drawCanvas: CanvasElement = cast Browser.document.createElement("canvas");
    public function new (img: ImageWrap) {
        super();
        image = img;
        drawCanvas.width = image.width;
        drawCanvas.height = image.height;
        drawCanvas.getContext2d().drawImage(image.image,0,0);
        cache(0,0,image.width,image.height);
    }

    override public function draw(ctx:CanvasRenderingContext2D, ?ignoreCache:Bool):Bool {
        if (super.draw(ctx,ignoreCache)) return true;
        ctx.drawImage(drawCanvas,0,0);
        return true;
    }

    override public function clone(): ImageFigure {
        var ret = new ImageFigure(image.clone());
        var _clone = Reflect.field(this, "_cloneProps");
        ret = Reflect.callMethod(this,_clone,[ret]);
        if (filter != null) {
            ret.filter = filter.clone();
        }
        return ret;
    }

    override public function toString(): String {
        return '[ImageFigure id="${id}"]';
    }

    public var filter(default, null):Filter;

    public function setFilterAsync(filter: Filter): Promise<ImageWrap,Dynamic,Float> {
        this.filter = filter;
        var pr = new Deferred<ImageWrap,Dynamic,Float>();
        filter.applyToImageData(Images.getImageData(image.image))
        .done(function(filtered: ImageData){
            drawCanvas.getContext2d().putImageData(filtered,0,0);
            cache(0,0,filtered.width,filtered.height);
            pr.resolve(image);
        }).fail(function(e) {
            pr.reject(e);
        });
        return pr;
    }

    override public function setActive(bool:Bool):Void {
        this.alpha = bool ? .5: 1;
    }

}
