package figure;
import js.Error;
import figure.FigureType;
import figure.ImageFigure;
import figure.ShapeFigure;
import createjs.easeljs.DisplayObject;
class Figures {
    public static function type(d: DisplayObject): FigureType {
        var s = d.toString();
        if (s.indexOf("ShapeFigureSet") > 0) {
            return FigureType.TypeShapeSet;
        }else if (s.indexOf("ShapeFigure") > 0) {
            return FigureType.TypeShape;
        } else if (s.indexOf("ImageFigure") > 0) {
            return FigureType.TypeImage;
        } else if (s.indexOf("InternalShape") > 0) {
            return FigureType.TypeInternal;
        } else if (s.indexOf("Layer") > 0) {
            return FigureType.TypeLayer;
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
    public static function typeString(d: DisplayObject): String {
        var s = d.toString();
        if (type(d) == FigureType.TypeShape) {
            return "図形";
        } else if (type(d) == FigureType.TypeImage) {
            return "画像";
        } else if (type(d) == FigureType.TypeShapeSet) {
            return "図形セット";
        } else if (type(d) == FigureType.TypeLayer) {
            return "レイヤー";
        } else if (type(d) == FigureType.TypeInternal) {
            return "その他";
        }
        throw new Error("Invalid DisplayObject => "+d);
    }
    public static function asShapeFigure(d: DisplayObject, callback: ShapeFigure -> Void): Void {
        if (type(d) == FigureType.TypeShape) {
            callback(cast d);
        }
    }
    public static function asImageFigure(d: DisplayObject, callback: ImageFigure -> Void): Void {
        if (type(d) == FigureType.TypeImage) {
            callback(cast d);
        }
    }
}
