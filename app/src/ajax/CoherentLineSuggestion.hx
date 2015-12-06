package ajax;
import jQuery.JqXHR;
import haxe.ds.Either;
import js.Error;
import cv.Images;
import Reflect;
import js.html.Image;
import cv.ImageWrap;
import deferred.Deferred;
import deferred.Promise;
import js.html.XMLHttpRequest;
import jQuery.JQuery;

typedef CoherentLinesSuggestionError = {
    code: Int,
    error: String
}
typedef CoherentLineSuggestionResult = {
    pivX: Float,
    pivY: Float,
    dataURL: String
}

class CoherentLineSuggestion {
    public function new() {
    }
    public static function postSuggest(dataurl: String): Promise<CoherentLineSuggestionResult,CoherentLinesSuggestionError,Float> {
        var def = new Deferred<CoherentLineSuggestionResult,CoherentLinesSuggestionError,Float>();
        JQuery._static.ajax({
            url: "/suggest",
            method: "POST",
            dataType: "json",
            data: {
                dataURL: dataurl
            }
        }).done(function(res: Dynamic) {
            var error = Reflect.field(res,"error");
            if (error != null) {
                def.reject(res);
            } else {
                def.resolve(res);
            }
        }).fail(function(e: JqXHR){
            def.reject({
                code: -1,
                error: e.statusText
            });
        });
        return def;
    }
}
