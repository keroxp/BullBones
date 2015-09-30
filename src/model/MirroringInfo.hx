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

    @:isVar public var mirroringType(get, set):MirroringType;

    function set_mirroringType(value:MirroringType) {
        set("mirroringType", value);
        return value;
    }

    function get_mirroringType():MirroringType {
        return get("mirroringType");
    }

    @:isVar public var pivotEnabled(get, set):Bool;

    function get_pivotEnabled():Bool {
        return get("pivotEnabled");
    }

    function set_pivotEnabled(value:Bool) {
        set("pivotEnabled", value);
        return value;
    }

    @:isVar public var pivot(get, set):Point;

    function get_pivot():Point {
        return get("pivot");
    }

    function set_pivot(value:Point) {
        set("pivot", value);
        return value;
    }

    public function getMirrorX(x: Float): Float {
        return x - (x-pivot.x)*2;
    }

    public function new(?opts: DrawingModeOptions) {
        super (opts == null ? {
            enabled: false,
            mirroingType: MirroringType.None,
            pivotEnabled: false,
            pivot: null
        } : opts);
    }
}

typedef DrawingModeOptions = {
    enabled: Bool,
    mirroringType: MirroringType,
    pivotEnabled: Bool,
    pivot: Point
}

enum MirroringType {
    None;
    Line;
    Point;
}
