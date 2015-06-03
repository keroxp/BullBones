package ;

class Main {
    public static var App: App;
    public static function main () {
        var app = new App({
            brushWidth: 3,
            brushAlpha: 255,
            brushThickness: 255,
            isDebug: false,
            isEditing: false
        });
        app.start();
        App = app;
    }
}
