package view;
import js.html.Document;
class ViewUtil {
    private static var document: Document = js.Browser.document;
    public static function on <T> (id: String, event: String, callback: T -> Void) {
        document.getElementById(id).addEventListener(event, callback);
    }
}
