package model;
import cv.Filter;
import cv.FilterFactory;
class ImageEditor {
    public var lineExtraction: Bool = false;
    public var gray: Bool = false;
    public var alpha: Float = 1.0;
    public var useLaplacian8: Bool = false;

    public function new () {}

    public function createFilter (includeAlpha: Bool = false): Filter {
        var f = new Filter();
        if (lineExtraction) {
            f.funcs = [
                useLaplacian8 ? FilterFactory.edge1() : FilterFactory.edge2(),
                FilterFactory.negaposi(),
                FilterFactory.gray()
            ];
        }
        if (!lineExtraction && gray) {
            f.funcs = [
                FilterFactory.gray()
            ];
        }
        if (includeAlpha) {
            f.funcs.push(FilterFactory.alpha(cast(alpha*255)));
        }
        return f;
    }
}