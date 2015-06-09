package rollbar;
@:native("Rollbar")
typedef RollbarCallback = Dynamic -> Dynamic -> Void;
extern class Rollbar {
    @:overload(function (error: Dynamic, ?callback: RollbarCallback): Void{})
    public static function critical(error: Dynamic, ?options: Dynamic): Void;
    @:overload(function (error: Dynamic, ?callback: RollbarCallback): Void{})
    public static function error(error: Dynamic, ?options: Dynamic): Void;
    @:overload(function (error: Dynamic, ?callback: RollbarCallback): Void{})
    public static function warning(error: Dynamic, ?options: Dynamic): Void;
    @:overload(function (error: Dynamic, ?callback: RollbarCallback): Void{})
    public static function info(error: Dynamic, ?options: Dynamic): Void;
    @:overload(function (error: Dynamic, ?callback: RollbarCallback): Void{})
    public static function debug(error: Dynamic, ?options: Dynamic): Void;
}
