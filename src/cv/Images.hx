package cv;
import js.Browser;
import deferred.Deferred;
import js.Error;
import deferred.Promise;
import js.html.Image;
import js.html.ImageElement;
import js.html.Document;
import js.html.ImageData;
import js.html.CanvasElement;
class Images {
    public static var WHITE_IMG(default,null): String
        = "data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
    private static var sCanvas: CanvasElement = cast Browser.document.createElement("canvas");
    private static function resizeInternal(image: Image, w: Int, h: Int, ?asp: AspectPolicy) {
        if (asp == null){
            asp = AspectPolicy.AspectToFit;
        }
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
                _w = Math.round(image.width * ratio);
                _h = Math.round(image.height * ratio);
            }
            case AspectPolicy.AspectToFill: {
                if (image.width > image.height) {
                    ratio = w > h ? h/image.width : w/image.height;
                } else {
                    ratio = w > h ? w/image.height : h/image.width;
                }
                _w = Math.round(image.width * ratio);
                _h = Math.round(image.height * ratio);
            }
            case AspectPolicy.ScaleToFit: {}
        }
        sCanvas.width = _w;
        sCanvas.height = _h;
        var ctx = sCanvas.getContext2d();
        ctx.drawImage(image,0,0,_w,_h);
    }
    public static function resize(image: Image, w: Int, h: Int, ?asp: AspectPolicy): Promise<ImageWrap,Error,Void> {
        var def = new Deferred<ImageWrap,Error,Void>();
        var im = new Image();
        resizeInternal(image,w,h,asp);
        im.src = sCanvas.toDataURL();
        im.width = w;
        im.height = h;
        im.onload = (function (_im: Image) {
            return function(e) {
                def.resolve(new ImageWrap(_im));
            }
        })(im);
        im.onerror = function (e: Error) {
            def.reject(e);
        }
        sCanvas.width = sCanvas.height = 0;
        return def;
    }

    public static function toDataUrl (imageData: ImageData, type: String = "image/png"): String {
        sCanvas.width = imageData.width;
        sCanvas.height = imageData.height;
        sCanvas.getContext2d().putImageData(imageData,0,0);
        var ret = sCanvas.toDataURL(type);
        sCanvas.width = sCanvas.height = 0;
        return ret;

    }

    public static function getImageData (image: Dynamic): ImageData {
        sCanvas.width = image.width;
        sCanvas.height = image.height;
        var ctx = sCanvas.getContext2d();
        ctx.drawImage(image,0,0);
        var ret = ctx.getImageData(0,0,image.width,image.height);
        sCanvas.width = sCanvas.height = 0;
        return ret;
    }

    public static function getResizedImageData(
        image: Image,
        w: Int,
        h: Int,
        ?asp: AspectPolicy
    ): ImageData
    {
        resizeInternal(image,w,h,asp);
        var ret = sCanvas.getContext2d().getImageData(0,0,sCanvas.width,sCanvas.height);
        sCanvas.width = sCanvas.height = 0;
        return ret;
    }

    public static function getResizedDataUrl(
        image: Image,
        w: Int,
        h: Int,
        ?asp: AspectPolicy,
        type: String = "image/png"
    ): String {
        resizeInternal(image,w,h,asp);
        var ret = sCanvas.toDataURL(type);
        sCanvas.width = sCanvas.height = 0;
        return ret;
    }
}
