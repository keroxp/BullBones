package ;
import createjs.easeljs.Container;
import createjs.easeljs.Shape;
class BoundingBox {
    public var shape(default, null): Container;
    var mLTCorner: Shape;
    var mRTCorner: Shape;
    var mLBCorner: Shape;
    var mRBCorner: Shape;
    var mBox: Shape;
    var onBoundsChange: Dynamic;
    public var conerRadius = 5.0;
    public function new() {
        shape = new Container();
        mRTCorner = new Shape();
        mRBCorner = new Shape();
        mLTCorner = new Shape();
        mLBCorner = new Shape();
        mBox = new Shape();
        shape.addChild(mBox);
        shape.addChild(mRTCorner);
        shape.addChild(mRBCorner);
        shape.addChild(mLTCorner);
        shape.addChild(mLBCorner);
    }
    public function render (bounds: Rect) {
        mBox.graphics
        .setStrokeStyle(0.3)
        .beginStroke("#111")
        .drawRoundRect(bounds.left,bounds.top,bounds.width(),bounds.height(),0);
        drawCorner(mLTCorner,bounds.left,bounds.top);
        drawCorner(mRTCorner,bounds.right,bounds.top);
        drawCorner(mLBCorner,bounds.left,bounds.bottom);
        drawCorner(mRBCorner,bounds.right,bounds.bottom);
    }
    function drawCorner(s: Shape, x: Float, y: Float) {
        s.graphics
        .setStrokeStyle(0.2)
        .beginStroke("#000")
        .beginFill("#999")
        .drawRoundRect(x-conerRadius,y-conerRadius,conerRadius*2,conerRadius*2,0);
    }
    public function clear() {
        mBox.graphics.clear();
        mRBCorner.graphics.clear();
        mRTCorner.graphics.clear();
        mLTCorner.graphics.clear();
        mLBCorner.graphics.clear();
    }
}
