package ajax;
import deferred.Promise;
import js.html.DOMWindow;
import jQuery.JQuery;
import deferred.Deferred;
class BingSearch {
    private static var URL = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query=";
    private static var KEY = "piWl0WnCx9b4HytksVqG3h0crLcki4MrY4XrwwS0Jo0";

    public static function search(q:String): Promise<Array<BingSearchResult>, Dynamic, Int> {
        var def = new Deferred<Array<BingSearchResult>, Dynamic, Int>();
        var auth = KEY + ":" + KEY;
        var window: DOMWindow = js.Browser.window;
        var encodedKey = window.btoa(auth);
        JQuery._static.ajax({
            url: URL + "'" + q + "'",
            type: "PUT",
            headers: {
                Authorization: "Basic " + encodedKey
            },
            dataType: "json"
        }).done(function(data:Dynamic) {
            def.resolve(data.d.results);
        }).fail(function(xhr:jQuery.JqXHR) {
            def.reject(xhr);
        });
        return def;
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