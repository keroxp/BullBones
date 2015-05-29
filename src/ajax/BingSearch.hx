package ajax;
import jQuery.JQuery;
import haxe.io.BytesData;
class BingSearch {
  public function new() {
  }
  private static var URL = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query=";
  private static var KEY = "piWl0WnCx9b4HytksVqG3h0crLcki4MrY4XrwwS0Jo0";
  public static function search (q: String): jQuery.Promise {
    var ba = new BytesData();
    var auth:String = KEY+":"+KEY;
    for (i in 0...auth.length-1) {
      ba[i] = KEY.charCodeAt(i);
    }
    var encodedKey:String = js.Lib.eval("btoa(\""+auth+"\");");
    return cast JQuery._static.ajax({
      url: URL+"'"+q+"'",
      type: "PUT",
      headers: {
        Authorization: "Basic "+encodedKey
      },
      dataType: "json"
    });
  }
}
