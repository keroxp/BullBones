package ajax;
import jQuery.Deferred;
import jQuery.JQuery;
import haxe.io.BytesData;
class BingSearch {
    private static var URL = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query=";
    private static var KEY = "piWl0WnCx9b4HytksVqG3h0crLcki4MrY4XrwwS0Jo0";

    public static function search(q:String):Deferred {
        var ba = new BytesData();
        var deferred:Deferred = new jQuery.Deferred();
        var auth:String = KEY + ":" + KEY;
        for (i in 0...auth.length) {
            ba[i] = KEY.charCodeAt(i);
        }
        var encodedKey:String = js.Lib.eval('btoa(\"$auth\");');
        JQuery._static.ajax({
            url: URL + "'" + q + "'",
            type: "PUT",
            headers: {
                Authorization: "Basic " + encodedKey
            },
            dataType: "json"
        }).done(function(data:Dynamic) {
            deferred.resolve(data.d.results);
        }).fail(function(xhr:jQuery.JqXHR) {
            deferred.reject(xhr);
        });
        return deferred;
    }
}

typedef BingSearchResult = {
    var ContentType:String;
    var DisplayUrl:String;
    var FileSize:String;
    var Height:String;
    var ID:String;
    var MediaUrl:String;
    var SourceUrl:String;
    var Thumbnail:BingSearchResultThumbnail;
    var ObjectTitle:String;
    var Width:String;
}

typedef BingSearchResultThumbnail = {
    var ObjectContentType:String;
    var FileSize:String;
    var Height:String;
    var MediaUrl:String;
    var Width:String;
}