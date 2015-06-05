package cv;

import js.html.ImageElement;
import cv.FilterFactory.FilterFunc;
import js.html.ImageData;

class Filter {
    public var funcs: Array<FilterFunc>;
    public function new(?filters: Array<FilterFunc>) {
        funcs = filters;
        if (funcs == null) {
            funcs = [];
        }
    }
    public function applyToImageData (inImg: ImageData): ImageData {
        var out: ImageData = inImg;
        for (f in funcs) {
            out = f(out);
        }
        return out;
    }
    public function apply(image: ImageElement): ImageData {
        return applyToImageData(ImageUtil.getImageData(image));
    }

}