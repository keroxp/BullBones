package model;
import createjs.easeljs.Point;
import model.BaseModel;
class DrawingMode extends BaseModel {
    @:isVar public var isMirroring(get, set):Bool;

    function set_isMirroring(value:Bool) {
        set("isMirroring", value);
        return value;
    }

    function get_isMirroring():Bool {
        return get("isMirroring");
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

    public function new(?opts: DrawingModeOptions) {
        super (opts == null ? {
            isMirroring: false,
            mirroingType: MirroringType.None,
            pivotEnabled: false,
            pivot: null
        } : opts);
    }
}

typedef DrawingModeOptions = {
    isMirroring: Bool,
    mirroringType: MirroringType,
    pivotEnabled: Bool,
    pivot: Point
}

enum MirroringType {
    None;
    Line;
    Point;
}
