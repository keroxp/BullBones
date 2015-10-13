package performance;
class GeneralObjectPool <T> {
    public var objects(default, null): Array<T> = new Array<T>();
    public var index(default, null): Int = -1;
    public var initialSize(default,null): Int;
    public var markedIndex(default, null): Int = -1;
    private var markedTag: String;
    private var ctorFunc: Void -> T;
    private var recycleFunc: T -> Void;

    public function new(size: Int, ctorFunc: Void -> T, ?recycleFunc: T -> Void) {
        this.initialSize = size;
        this.ctorFunc = ctorFunc;
        this.recycleFunc = recycleFunc;
        for (i in 0...size) {
            this.objects[i] = ctorFunc();
        }
    }

    public function mark(tag: String = "") {
        markedIndex = index;
        markedTag = tag;
    }

    public function unmark() {
        markedIndex = -1;
    }

    public function take(): T {
        var i = index == objects.length-1 ? index = 0 : ++index;
        if (i == markedIndex) {
            return ctorFunc();
        }
        var o = objects[i];
        if (recycleFunc != null) {
            recycleFunc(o);
        }
        return o;
    }
}
