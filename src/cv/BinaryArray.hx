package cv;
import js.Error;
import js.html.Uint32Array;
class BinaryArray implements ArrayAccess<Bool> {
    private var mArray: Uint32Array;
    public function new(size: Int) {
        mArray = new Uint32Array(Math.ceil(size/32));
    }

    @:arrayAccess
    public inline function get(i: Int) {
        var idx = Math.floor(i/32);
        if (idx >= mArray.length) {
            throw new Error('index is out of range. current length is ${mArray.length} but got $idx');
        }
        return mArray[idx] >>> i%32 & 1 == 1;
    }

    @arrayAccess
    public inline function set(i: Int, flag: Bool) {
        var idx = Math.floor(i/32);
        if (idx >= mArray.length) {
            throw new Error('index out of range. current length is ${mArray.length} but got $idx');
        }
        mArray[idx] |= flag ? 1 : 0 << i%32;
        return flag;
    }

}
