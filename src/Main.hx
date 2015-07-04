package ;

import util.BrowserUtil;
import model.ZoomEditor;
import model.BrushEditor;
class Main {
    public static var App: App;
    public static function main () {
        var env = BrowserUtil.window.location.host.indexOf("localhost") == 0 ? "development" : "production";
        App = new App({
            brush: new BrushEditor(),
            isDebug: false,
            isEditing: false,
            zoom: new ZoomEditor(),
            env: env
        });
        App.start();
    }
}
