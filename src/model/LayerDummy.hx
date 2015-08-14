package model;
import js.Error;
class LayerDummy extends BBModel {
    @:isVar public var layerId(get, set):Int;
    function set_layerId(value:Int) {
        if (value == null) {
            throw new Error("ivalid id value: "+value);
        }
        set("layerId", value);
        return value;
    }

    function get_layerId():Int {
        return get("layerId");
    }

    public function new(layerId: Int) {
        super({
            layerId: layerId
        });
    }
}
