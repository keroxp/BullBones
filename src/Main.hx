package ;

class Main {
    private static var App: App;
    public static function main () {
        var app = new App();
        app.start();
        App = app;
    }
}
