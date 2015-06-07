package ;
import view.BrushEditorView.BrushEditor;
class V extends Model {

    @:isVar public var isEditing(get, set):Bool = false;

    function get_isEditing():Bool {
        return get("isEditing");
    }

    function set_isEditing(value:Bool) {
        set("isEditing", value);
        return this.isEditing = value;
    }

    @:isVar public var brush(get, set):BrushEditor;

    function set_brush(value:BrushEditor) {
        set("brush", value);
        return this.brush = value;
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
        return this.isDebug = value;
    }

    public function new(attr: Dynamic) {
        super(attr);
    }
}
