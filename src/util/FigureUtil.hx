package util;
import js.Error;
import figure.FigureType;
import figure.ImageFigure;
import figure.ShapeFigure;
import createjs.easeljs.DisplayObject;
class FigureUtil {
    public static function type(d: DisplayObject): FigureType {
        var s = d.toString();
        if (s.indexOf("ShapeFigureSet") > 0) {
            return FigureType.ShapeSet;
        }else if (s.indexOf("ShapeFigure") > 0) {
            return FigureType.Shape;
        } else if (s.indexOf("ImageFigure") > 0) {
            return FigureType.Image;
        } else if (s.indexOf("InternalShape") > 0) {
            return FigureType.Internal;
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
    public static function typeString(d: DisplayObject): String {
        var s = d.toString();
        if (type(d) == FigureType.Shape) {
            return "図形";
        } else if (type(d) == FigureType.Image) {
            return "画像";
        } else if (type(d) == FigureType.ShapeSet) {
            return "図形セット";
        } else if (type(d) == FigureType.Internal) {
            return "その他";
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
    public static function asShapeFigure(d: DisplayObject, callback: ShapeFigure -> Void): Void {
        if (type(d) == FigureType.Shape) {
            callback(cast d);
        }
    }
    public static function asImageFigure(d: DisplayObject, callback: ImageFigure -> Void): Void {
        if (type(d) == FigureType.Image) {
            callback(cast d);
        }
    }
}
