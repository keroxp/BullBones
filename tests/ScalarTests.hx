package ;
import util.BrowserUtil;
import geometry.Scalar;
class ScalarTests extends haxe.unit.TestCase {
    public function new() {
        super();
    }

    public inline function v(float: Float) return float * BrowserUtil.dpr;
    override public function setup():Void {
        BrowserUtil.dpr = 2;
    }

    public function testBase() {
        var s = new Scalar(2);
        assertEquals(v(2),s);
        s = new Scalar(3);
        assertEquals(v(3),s);
        s = new Scalar(-100);
        assertEquals(v(-100),s);
        s = new Scalar(0.1);
        assertEquals(v(0.1),s);
    }

    public function testAdd() {
        inline function test(base, f) {
            var s = new Scalar(base);
            var t = new Scalar(f);
            var e = v(base+f);
            assertEquals(e, s.addf(f));
            assertEquals(e, s+t);
            assertEquals(e, t+s);
        }
        test(2,2);
        test(-10,5);
        test(0.3,0.11);
    }

    public function testSub() {
        inline function test(base, f) {
            var s = new Scalar(base);
            var t = new Scalar(f);
            assertEquals(v(base-f),s.subf(f));
            assertEquals(v(base-f),s-t);
            assertEquals(v(f-base),t-s);
        }
        test(2,2);
        test(-10,5);
        test(0.3,0.11);
    }

    public function testMul() {
        inline function test(base: Float,f: Float) {
            var s = new Scalar(base);
            var t = new Scalar(f);
            assertEquals(v(base*f), s.toFloat()*f);
            assertEquals(v(base)*v(f), s*t);
            assertEquals(v(f)*v(base), t*s);
        }
        test(2,2);
        test(-10,5);
        test(4.5,2.3);
    }

    public function testDiv() {
        inline function test(base: Float,f: Float) {
            var s = new Scalar(base);
            var t = new Scalar(f);
            assertEquals(v(base/f), s.toFloat()/f);
            assertEquals(v(base)/v(f), s/t);
            assertEquals(v(f)/v(base), t/s);
        }
        test(2,2);
        test(-10,5);
        test(4.5,2.3);
    }

}
