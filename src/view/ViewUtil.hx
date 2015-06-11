package view;
import js.html.Element;
import js.html.Document;
class ViewUtil {
    private static var document: Document = js.Browser.document;
    public static function on <T> (el: Element, event: String, callback: T -> Void) {
        el.addEventListener(event, callback);
    }
}
