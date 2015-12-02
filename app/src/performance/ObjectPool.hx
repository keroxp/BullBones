package performance;
class ObjectPool <T : Poolable> extends GeneralObjectPool <T> {
    public function new(size: Int, ctorFunc: Void -> T) {
        super(size, ctorFunc, function (o: T) {
            o.recycle();
        });
    }
}
