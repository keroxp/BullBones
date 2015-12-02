package ajax;
import deferred.Promise;
import jQuery.JQuery;
import deferred.Deferred;
class BingSearch {
    public static function search(q:String): Promise<Array<BingSearchResult>, Dynamic, Int> {
        var def = new Deferred<Array<BingSearchResult>, Dynamic, Int>();
        var _q = js.Lib.eval('encodeURIComponent("$q")');
        JQuery._static.ajax({
            url: '/search',
            data: {
                q: q
            },
            dataType: "json"
        }).done(function(data:Dynamic,status: Dynamic,opts:Dynamic) {
            def.resolve(data);
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