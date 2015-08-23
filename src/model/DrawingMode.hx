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

    public function new() {
        super ({
            isMirroring: false,
            mirroingType: MirroringType.None
        });
    }

}

enum MirroringType {
    None;
    Line;
    Point;
}
