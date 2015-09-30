package model;
import cv.Filter;
import cv.FilterFactory;
class ImageEditor extends BaseModel {
    function get_lineExtraction():Bool {
        return get("lineExtraction");
    }

    function set_lineExtraction(value:Bool) {
        set("lineExtraction", value);
        return value;
    }

    function get_gray():Bool {
        return get("gray");
    }

    function set_gray(value:Bool) {
        set("gray", value);
        return value;
    }

    function set_alpha(value:Float) {
        set("alpha", value);
        return value;
    }

    function get_alpha():Float {
        return get("alpha");
    }

    function get_useLaplacian8():Bool {
        return get("useLaplacian8");
    }

    function set_useLaplacian8(value:Bool) {
        set("useLaplacian8", value);
        return value;
    }

    @:isVar public var lineExtraction(get, set):Bool;
    @:isVar public var gray(get, set):Bool;
    @:isVar public var useLaplacian8(get, set):Bool;
    @:isVar public var alpha(get, set):Float;

    public function new () {
        super({
            lineExtraction: false,
            useLaplacian8: false,
            gray: false,
            alpha: 1
        });
    }

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