package figure;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.MouseEvent;
import geometry.Rect;
import createjs.easeljs.Container;
import createjs.easeljs.Shape;

interface OnChangeListener {
    function onCornerDown (e: MouseEvent, corner: Corner): Void;
    function onCornerMove (e: MouseEvent, corner: Corner, dx: Float, dy: Float): Void;
    function onCornerUp (e: MouseEvent, corner: Corner): Void;
}
enum Corner {
    TopLeft;
    TopRight;
    BottomLeft;
    BottomRight;
}
class BoundingBox {
    public var shape(default, null): Container;
    var mLTCorner: Shape;
    var mRTCorner: Shape;
    var mLBCorner: Shape;
    var mRBCorner: Shape;
    var mBox: Shape;
    public var listener: OnChangeListener;
    public var conerRadius = 5.0;
    public function new() {
        shape = new Container();
        mRTCorner = new Shape();
        mRBCorner = new Shape();
        mLTCorner = new Shape();
        mLBCorner = new Shape();
        mRTCorner.on("mousedown", onCornerDonw);
        mRTCorner.on("pressmove", onCornerMove);
        mRTCorner.on("pressup", onCornerUp);
        mRBCorner.on("mousedown", onCornerDonw);
        mRBCorner.on("pressmove", onCornerMove);
        mRBCorner.on("pressup", onCornerUp);
        mLTCorner.on("mousedown", onCornerDonw);
        mLTCorner.on("pressmove", onCornerMove);
        mLTCorner.on("pressup", onCornerUp);
        mLBCorner.on("mousedown", onCornerDonw);
        mLBCorner.on("pressmove", onCornerMove);
        mLBCorner.on("pressup", onCornerUp);
        mBox = new Shape();
        shape.addChild(mBox);
        shape.addChild(mRTCorner);
        shape.addChild(mRBCorner);
        shape.addChild(mLTCorner);
        shape.addChild(mLBCorner);
    }
    var mPrevX: Float;
    var mPrevY: Float;
    private function onCornerDonw (e: MouseEvent) {
        mPrevX = e.stageX;
        mPrevY = e.stageY;
        if (listener != null) {
            listener.onCornerDown(e, getCorner(e.target));
        }
    }
    private function onCornerMove (e: MouseEvent) {
        var dx = e.stageX-mPrevX;
        var dy = e.stageY-mPrevY;
        var c = getCorner(e.target);
        if (listener != null) {
            listener.onCornerMove(e,c,dx,dy);
        }
        mPrevX = e.stageX;
        mPrevY = e.stageY;
    }
    private function onCornerUp (e: MouseEvent) {
        if (listener != null) {
            listener.onCornerUp(e, getCorner(e.target));
        }
    }
    private function getCorner (d: DisplayObject): Corner {
        if (d == mLTCorner) return Corner.TopLeft;
        if (d == mRTCorner) return Corner.TopRight;
        if (d == mLBCorner) return Corner.BottomLeft;
        if (d == mRBCorner) return Corner.BottomRight;
        throw new js.Error("error");
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
