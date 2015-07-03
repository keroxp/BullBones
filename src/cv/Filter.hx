package cv;

import protocol.Clonable;
import cv.FilterFactory.FilterFunc;
import js.html.ImageData;

class Filter implements Clonable<Filter>{
    public var funcs: Array<FilterFunc>;
    public function new(?filters: Array<FilterFunc>) {
        funcs = filters;
        if (funcs == null) {
            funcs = [];
        }
    }

    public function clone():Filter {
        return new Filter(funcs.copy());
    }

    public function applyToImageData (inImg: ImageData): ImageData {
        var out: ImageData = inImg;
        for (f in funcs) {
            out = f(out);
        }
        return out;
    }
}