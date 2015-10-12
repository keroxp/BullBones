package model;
import createjs.easeljs.Point;
import model.BaseModel;
class MirroringInfo extends BaseModel {
    @:isVar public var enabled(get, set):Bool;

    function set_enabled(value:Bool) {
        set("enabled", value);
        return value;
    }

    function get_enabled():Bool {
        return get("enabled");
    }

    @:isVar public var mirrorByPoint(get, set):Bool;

    function get_mirrorByPoint():Bool {
        return get("mirrorByPoint");
    }

    function set_mirrorByPoint(value:Bool) {
        set("mirrorByPoint", value);
        return value;
    }

    @:isVar public var pivotEnabled(get, set):Bool;

    function get_pivotEnabled():Bool {
        return get("pivotEnabled");
    }

    function set_pivotEnabled(value:Bool) {
        set("pivotEnabled", value);
        return value;
    }

    @:isVar public var pivotX(get, set): Float;

    function set_pivotX(value:Float) {
        set("pivotX", value);
        return value;
    }

    function get_pivotX():Float {
        return get("pivotX");
    }

    @:isVar public var pivotY(get, set): Float;

    function get_pivotY():Float {
        return get("pivotY");
    }

    function set_pivotY(value:Float) {
        set("pivotY", value);
        return value;
    }


    public function getMirrorX(x: Float): Float {
        return x - (x-pivotX)*2;
    }

    public function getMirrorY(y: Float): Float {
        return mirrorByPoint ? y - (y-pivotY)*2 : y;
    }

    public function new(?opts: DrawingModeOptions) {
        super (opts == null ? {
            enabled: false,
            mirrorByPoint: false,
            pivotEnabled: false,
            pivot: null
        } : opts);
    }
}

typedef DrawingModeOptions = {
    enabled: Bool,
    pivotEnabled: Bool,
    mirrorByPoint: Bool,
    pivot: Point
}