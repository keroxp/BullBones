package ;

import view.BrushEditorView.BrushEditor;
class Main {
    public static var App: App;
    public static function main () {
        App = new App({
            brush: new BrushEditor(),
            isDebug: false,
            isEditing: false
        });
        App.start();
    }
}
