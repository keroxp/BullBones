package ajax;
import jQuery.JqXHR;
import Reflect;
import deferred.Deferred;
import deferred.Promise;
import jQuery.JQuery;

class CoherentLineSuggestion {
    public function new() {
    }
    public static function postSuggest(dataurl: String): Promise<Array<Dynamic>,JqXHR,Float> {
        var def = new Deferred<Array<Dynamic>,JqXHR,Float>();
        JQuery._static.ajax({
            url: "/suggest",
            method: "POST",
            dataType: "json",
            data: {
                dataURL: dataurl
            }
        }).done(def.resolve)
        .fail(def.reject);
        return def;
    }
}
