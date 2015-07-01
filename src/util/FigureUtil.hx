package util;
import figure.ImageFigure;
import figure.ShapeFigure;
import createjs.easeljs.DisplayObject;
class FigureUtil {
    public static function isShapeFigure(d: DisplayObject): Bool {
        return d.toString().indexOf("ShapeFigure") > -1;
    }
    public static function isImageFigure(d: DisplayObject): Bool {
        return d.toString().indexOf("ImageFigure") > -1;
    }
    public static function asShapeFigure(d: DisplayObject, callback: ShapeFigure -> Void): Void {
        if (isShapeFigure(d)) {
            callback(cast d);
        }
    }
    public static function asImageFigure(d: DisplayObject, callback: ImageFigure -> Void): Void {
        if (d != null && isImageFigure(d)) {
            callback(cast d);
        }
    }
}
