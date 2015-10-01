package performance;
class ObjectPool <T : Poolable> {
    public var objects(default, null): Array<T>;
    public var index(default, null): Int = -1;
    function nextIndex():Int {
        return index == objects.length-1 ? index = 0 : ++index;
    }

    public function new(objects: Array<T>) {
        this.objects = objects;
        for (o in objects) {
            o.recycle();
        }
    }

    public function take(): T {
        var o = objects[nextIndex()];
        o.recycle();
        return o;
    }
}
