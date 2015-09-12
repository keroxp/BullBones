package figure;
import createjs.easeljs.Shape;
using util.RectangleUtil;
class PivotShape extends Shape {
    public var coreRadius: Float;
    public function new(coreRadius: Float = 6) {
        super();
        this.coreRadius = coreRadius;
    }
    public function render() {
        var cen = coreRadius+5;
        this.graphics
        .beginFill("#455a64")
        .drawCircle(cen,cen,cen)
        .endFill()
        .beginFill("#e3f2fd")
        .drawCircle(cen,cen,cen-1)
        .endFill()
        .beginFill("#fff")
        .drawCircle(cen,cen,coreRadius+2)
        .endFill()
        .beginFill("#2979ff")
        .drawCircle(cen,cen,coreRadius)
        .endFill();
        setBounds(0,0,cen*2,cen*2);
    }

    override public function toString(): String {
        return '[InternalShape id="${id}"';
    }

    override public function hitTest(x:Float, y:Float):Bool {
        return getTransformedBounds().containsPoint(x,y);
    }
}
