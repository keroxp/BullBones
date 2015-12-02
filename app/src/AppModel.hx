package ;
import model.ZoomEditor;
import model.BrushEditor;
import model.BaseModel;

class AppModel extends BaseModel {

    @:isVar public var env(get, set):String;
    function set_env(value:String) {
        set("env", value);
        return value;
    }

    function get_env():String {
        return get("env");
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

    @:isVar public var undoStackSize(get, set):Int;

    function get_undoStackSize():Int {
        return get("undoStackSize") | 0;
    }

    function set_undoStackSize(value:Int) {
        set("undoStackSize", value);
        return value;
    }

    @:isVar public var redoStackSize(get, set):Int;

    function get_redoStackSize():Int {
        return get("redoStackSize") | 0;
    }

    function set_redoStackSize(value:Int) {
        set("redoStackSize", value);
        return value;
    }


    public function new(attr: Dynamic) {
        super(attr);
    }
}
