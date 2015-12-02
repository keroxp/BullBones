package ajax;
import js.Error;
import cv.Images;
import Reflect;
import js.html.Image;
import cv.ImageWrap;
import deferred.Deferred;
import deferred.Promise;
import js.html.XMLHttpRequest;
import jQuery.JQuery;

typedef CoherentLineSourceImage = {
    id: Int,
    category: String,
    name: String,
    width: Int,
    height: Int,
}
typedef CoherentLine = {
    id: Int,
    image_id: Int,
    label: Int,
    sx: Int,
    sy: Int,
    width: Int,
    height: Int,
    area: Float,
    length: Float,
    coherentcy: Float,
    direction: Int,
    tiled_sx: Int,
    tiled_sy: Int
}
typedef CoherentLineSuggestionResult = {
    Images: CoherentLineSourceImage,
    CoherentLines: CoherentLine
}

typedef CoherentLineSuggestionResults = Array<CoherentLineSuggestionResult>;

class CoherentLineSuggestion {
    public function new() {
    }
    public static function postSuggest(dataurl: String): Promise<CoherentLineSuggestionResults,XMLHttpRequest,Float> {
        var def = new Deferred<CoherentLineSuggestionResults,XMLHttpRequest,Float>();
        JQuery._static.ajax({
            url: "/suggest",
            method: "POST",
            dataType: "json",
            data: {
                dataURL: dataurl
            }
        }).done(function(res: CoherentLineSuggestionResults) {
            def.resolve(res);
        }).fail(def.reject);
        return def;
    }
    public static function getCoherentLine(result: CoherentLineSuggestionResult): Promise<ImageWrap,Error,Float> {
        var q = {
            category: result.Images.category,
            name: result.Images.name,
            sx: result.CoherentLines.tiled_sx,
            sy: result.CoherentLines.tiled_sy,
            width: result.CoherentLines.width,
            height: result.CoherentLines.height
        }
        var url = '/coherent_lines?';
        for (key in Reflect.fields(q)) {
            url += '${key}=${Reflect.field(q,key)}&';
        }
        return ImageWrap.load(url);
    }
}
