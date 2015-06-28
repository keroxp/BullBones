package ;
import model.ZoomEditor;
import model.BrushEditor;
import model.BBModel;

class V extends BBModel {

    @:isVar public var isEditing(get, set):Bool = false;

    function get_isEditing():Bool {
        return get("isEditing");
    }

    function set_isEditing(value:Bool) {
        set("isEditing", value);
        return value;
    }

    @:isVar public var brush(get, set):BrushEditor;

    function set_brush(value:BrushEditor) {
        set("brush", value);
        return value;
    }

    function get_brush():BrushEditor {
        return get("brush");
    }

    @:isVar public var isDebug(get, set):Bool;

    function get_isDebug():Bool {
        return get("isDebug");
    }

    function set_isDebug(value:Bool) {
        set("isDebug", value);
        return value;
    }

    @:isVar public var zoom(get, set):ZoomEditor;
    function set_zoom(value:ZoomEditor) {
        if (value.scale != zoom.scale) {
            set("zoom", value);
        }
        return value;
    }
    function get_zoom():ZoomEditor {
        return get("zoom");
    }

    public function new(attr: Dynamic) {
        super(attr);
    }
}
