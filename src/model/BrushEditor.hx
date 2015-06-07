package model;
class BrushEditor {
    public var thickness: Int = 255;
    public var alpha: Float = 1.0;
    public var width: Float = 3;
    public var color(get, null): String;
    function get_color (): String {
        var thick = 255-thickness;
        var ret = 'rgba($thick,$thick,$thick,$alpha)';
        return ret;
    }
}