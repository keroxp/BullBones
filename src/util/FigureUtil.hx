package util;
import js.Error;
import figure.FigureType;
import figure.ImageFigure;
import figure.ShapeFigure;
import createjs.easeljs.DisplayObject;
class FigureUtil {
    public static function type(d: DisplayObject): FigureType {
        var s = d.toString();
        if (s.indexOf("ShapeFigure") > 0) {
            return FigureType.Shape;
        } else if (s.indexOf("ImageFigure") > 0) {
            return FigureType.Image;
        } else if (s.indexOf("ShapeFigureSet") > 0) {
            return FigureType.ShapeSet;
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
    public static function typeString(d: DisplayObject): String {
        var s = d.toString();
        if (s.indexOf("ShapeFigure") > 0) {
            return "図形";
        } else if (s.indexOf("ImageFigure") > 0) {
            return "画像";
        } else if (s.indexOf("ShapeFigureSet") > 0) {
            return "図形セット";
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
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
