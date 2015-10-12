package model;
import geometry.Scalar;
class BrushEditor {
    public var thickness: Int = 255;
    public var alpha: Float = 1.0;
    public var width: Scalar = Scalar.valueOf(2);
    public var color(get, null): String;
    public var supplemnt: Bool = true;

    public function new () {}

    function get_color (): String {
        var thick = 255-thickness;
        var ret = 'rgba($thick,$thick,$thick,$alpha)';
        return ret;
    }
}