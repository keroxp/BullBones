package ;
class TestMain {
    public static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new ScalarTests());
        r.run();
    }
}
