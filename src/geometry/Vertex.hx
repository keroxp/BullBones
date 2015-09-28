package geometry;
import performance.Poolable;
import protocol.Clonable;
import geometry.FuzzyPoint;
class Vertex implements Clonable implements Poolable {
    public var point: FuzzyPoint;
    public var radian: Float;
    public function new (p: FuzzyPoint = null, rad: Float = -1) {
        point = p;
        radian = rad;
    }

    public function clone():Vertex {
        return new Vertex(point.clone(), radian);
    }

    public function recycle():Void {
        point.recycle();
        radian = 0;
    }
}