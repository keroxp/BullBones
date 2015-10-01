package performance;
class GeneralObjectPool <T> {
    public var recycleFunc: T -> Void;
    public var objects: Array<T>;
    var index: Int = -1;
    public static function create<U>(size: Int, ctorFunc: Void -> U, recycleFunc: U -> Void): GeneralObjectPool<U> {
        var arr = [];
        for (i in 0...size) {
            arr[i] = ctorFunc();
        }
        return new GeneralObjectPool<U>(arr, recycleFunc);
    }
    public function new(arr: Array<T>, recycleFunc: T -> Void) {
        this.recycleFunc = recycleFunc;
        this.objects = arr;
        for (i in 0...objects.length) {
            recycleFunc(objects[i]);
        }
    }
    function nextIndex():Int {
        return index == objects.length-1 ? index = 0 : ++index;
    }
    public function take(): T {
        var o = objects[nextIndex()];
        recycleFunc(o);
        return o;
    }
}
