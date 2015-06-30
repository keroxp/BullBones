package cv;
import protocol.Clonable;
import util.StringUtil;
import deferred.Deferred;
import createjs.easeljs.Rectangle;
import js.html.ImageData;
import haxe.ds.Either;
import js.Error;
import js.html.ImageElement;
import ajax.Loader;
import deferred.Promise;
import js.html.Image;
import util.BrowserUtil;
import js.html.CanvasElement;
enum AspectPolicy {
    ScaleToFit;
    AspectToFill;
    AspectToFit;
}
class ImageWrap implements Clonable<ImageWrap> {
    public var canvas: CanvasElement;
    public var src(get, never): String;
    function get_src():String {
        return image.src;
    }
    public var width(get, never): Int;
    function get_width(): Int {
        return image.width;
    }
    public var height(get, never): Int;
    function get_height():Int {
        return image.height;
    }
    public var image: Image;
    public var id: String;
    public function new(img: Image) {
        canvas = cast BrowserUtil.document.createElement("canvas");
        image = img;
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx = canvas.getContext2d();
        ctx.drawImage(img,0,0);
        this.id = StringUtil.UUID();
    }
    public function clone():ImageWrap {
        return new ImageWrap(cast image.cloneNode(true));
    }

    public function toDataUrl(?type: String = ""): String {
        return canvas.toDataURL(type);
    }
    public function getImageData(): ImageData {
        return getResizedImageData(image.width,image.height);
    }
    public function getResizedImageData(
        w: Float,
        h: Float,
        ?asp: AspectPolicy
    ): ImageData
    {
        var ret: ImageData;
        resize(w,h,function(c:CanvasElement,r:Rectangle){
            ret = c.getContext2d().getImageData(r.x,r.y,r.width,r.height);
        }, asp);
        return ret;
    }
    public function resize(w: Float, h: Float, callback: CanvasElement -> Rectangle -> Void, ?asp: AspectPolicy) {
        if (asp == null){
            asp = AspectPolicy.AspectToFit;
        }
        var ctx = canvas.getContext2d();
        ctx.save();
        ctx.clearRect(0,0,image.width,image.height);
        var _w = w;
        var _h = h;
        var ratio = 1.0;
        switch (asp) {
            case AspectPolicy.AspectToFit: {
                var ratio = 0.0;
                if (image.width > image.height) {
                    ratio = w > h ? w/image.width : h/image.height;
                } else {
                    ratio = w > h ? h/image.height : w/image.width;
                }
                _w = image.width * ratio;
                _h = image.height * ratio;
            }
            case AspectPolicy.AspectToFill: {
                if (image.width > image.height) {
                    ratio = w > h ? h/image.width : w/image.height;
                } else {
                    ratio = w > h ? w/image.height : h/image.width;
                }
                _w = image.width * ratio;
                _h = image.height * ratio;
            }
            case AspectPolicy.ScaleToFit: {}
        }
        ctx.drawImage(image,0,0,_w,_h);
        callback(ctx.canvas,new Rectangle(0,0,_w,_h));
        ctx.restore();
    }
    public function getResizedDataUrl(
        w: Int,
        h: Int,
        ?asp: AspectPolicy,
        ?type: String = ""
    ): String {
        var ret: String;
        resize(w,h,function(c:CanvasElement,r:Rectangle){
           ret = canvas.toDataURL(type);
        });
        return ret;
    }
}
