package model;
class GhostInfo extends BaseModel {
    public function new(?attr) {
        super(attr == null ? {
            enabled: false
        }: attr);
    }
    @:isVar public var enabled(get, set):Bool;
    function set_enabled(value:Bool) {
        set("enabled", value);
        return value;
    }
    function get_enabled():Bool {
        return get("enabled");
    }
}
