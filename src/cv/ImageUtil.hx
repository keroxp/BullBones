package cv;
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
