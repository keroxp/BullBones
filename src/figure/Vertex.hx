package figure;
import geometry.FuzzyPoint;
class Vertex {
    public var point: FuzzyPoint;
    public var radian: Float;
    public function new (?p: FuzzyPoint = null, ?rad: Float = -1) {
        point = p;
        radian = rad;
    }
}