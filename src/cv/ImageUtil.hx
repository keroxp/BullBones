package cv;
import createjs.easeljs.Rectangle;
import js.html.ImageElement;
import js.html.Document;
import js.html.ImageData;
import js.html.CanvasElement;
class ImageUtil {
    private static var canvas: CanvasElement;
    private static function getCanvas(): CanvasElement {
        if (canvas == null) {
            var doc: Document = js.Browser.document;
            canvas = cast doc.createElement("canvas");
        }
        return canvas;
    }
    public static function createTmpImage(w:Int, h:Int):ImageData {
        var c = clearCanvas();
        var ctx = c.getContext2d();
        var outImg = ctx.createImageData(w, h);
        for (y in 0...h) {
            for (x in 0...w) {
                var i = (y * w + x) * 4;
                outImg.data[i] = 255;
                outImg.data[i + 1] = 255;
                outImg.data[i + 2] = 255;
                outImg.data[i + 3] = 255;
            }
        }
        return outImg;
    }
    private static function clearCanvas (): CanvasElement {
        var c = getCanvas();
        c.getContext2d().clearRect(0,0,c.width,c.height);
        return c;
    }
    public static function toDataUrl (imageData: ImageData, ?type: String = "image/png"): String {
        var c = clearCanvas();
        c.width = imageData.width;
        c.height = imageData.height;
        c.getContext2d().putImageData(imageData,0,0);
        return c.toDataURL(type);
    }

    public static function getImageData (image: ImageElement): ImageData {
        var c = clearCanvas();
        c.width = image.width;
        c.height = image.height;
        var ctx = c.getContext2d();
        ctx.drawImage(image,0,0);
        return ctx.getImageData(0,0,c.width,c.height);
    }
}
