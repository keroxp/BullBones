package figure;
import geometry.Scalar;
import geometry.Scalar;
import geometry.Scalar;
import util.BrowserUtil;
import createjs.easeljs.Shape;
using util.RectangleUtil;
class PivotShape extends Shape {
    public var coreRadius(default, null): Scalar;
    public var totalRadius(default, null): Scalar;
    public function new(coreRadius: Float = 6) {
        super();
        trace(coreRadius);
        this.coreRadius = new Scalar(coreRadius);
        this.totalRadius = this.coreRadius + 5;
    }
    public function adjustPivot(pivX: Float, pivY: Float) {
        x = pivX - totalRadius.toFloat();
        y = pivY - totalRadius.toFloat();
    }
    public function render() {
        var dpr = BrowserUtil.window.devicePixelRatio;
        var rad = totalRadius;
        var crad = coreRadius;
        this.graphics
        .beginFill("#455a64")
        .drawCircle(rad,rad,rad)
        .endFill()
        .beginFill("#e3f2fd")
        .drawCircle(rad,rad,totalRadius-1)
        .endFill()
        .beginFill("#fff")
        .drawCircle(rad,rad,coreRadius+2)
        .endFill()
        .beginFill("#2979ff")
        .drawCircle(rad,rad,crad)
        .endFill();
        setBounds(0,0,rad*2,rad*2);
    }

    override public function toString(): String {
        return '[InternalShape id="${id}"';
    }

    override public function hitTest(x:Float, y:Float):Bool {
        return getTransformedBounds().containsPoint(x,y);
    }
}
