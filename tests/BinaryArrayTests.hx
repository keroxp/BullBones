package ;
import js.Error;
import haxe.PosInfos;
import cv.BinaryArray;
class BinaryArrayTests extends haxe.unit.TestCase {
    public function new() {
        super();
    }
    public function test1() {
        var bn = new BinaryArray(64);
        bn[0] = true;
        bn[1] = false;
        bn[2] = true;
        bn[32] = true;
        bn[33] = false;
        bn[34] = true;
        assertTrue(bn[0]);
        assertFalse(bn[1]);
        assertTrue(bn[2]);
        assertTrue(bn[32]);
        assertFalse(bn[33]);
        assertTrue(bn[34]);
        bn[34] = false;
        assertFalse(bn[34]);
    }
    public function test2 () {
        var len = 32*32;
        var arr = [];
        var bna = new BinaryArray(len);
        for (i in 0...len) {
            arr[i] = Math.floor(Math.random()*2) == 0;
            bna[i] = arr[i];
        }
        for (i in 0...arr.length) {
            if (arr[i] != bna[i]) {
                trace('index is $i');
            }
            assertTrue(arr[i] == bna[i]);
        }
    }
}
