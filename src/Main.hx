package ;

import model.ZoomEditor;
import model.BrushEditor;
class Main {
    public static var App: App;
    public static function main () {
        App = new App({
            brush: new BrushEditor(),
            isDebug: false,
            isEditing: false,
            zoom: new ZoomEditor()
        });
        App.start();
    }
}
