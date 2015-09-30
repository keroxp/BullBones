package figure;
import util.CursorUtil;
import geometry.Scalar;
import createjs.easeljs.Rectangle;
import geometry.Point;
import event.MouseEventCapture;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.MouseEvent;
import createjs.easeljs.Container;
import createjs.easeljs.Shape;
using util.RectangleUtil;

typedef Corner = {
    isLeft: Bool,
    isTop: Bool
}
class BoundingBox {
    private static var CORNER_LT = {isLeft: true, isTop: true};
    private static var CORNER_RT = {isLeft: false, isTop: true};
    private static var CORNER_LB = {isLeft: true, isTop: false};
    private static var CORNER_RB = {isLeft: false, isTop: false};
    public var shape(default, null): Container;
    var mLTCorner: Shape;
    var mRTCorner: Shape;
    var mLBCorner: Shape;
    var mRBCorner: Shape;
    var mBox: Shape;
    public var cornerRadius = Scalar.valueOf(5.0);
    public var color = "#000";
    public var cornerFillColor = "#fff";
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
    public function render (bounds: Rectangle): BoundingBox {
        mBox.graphics
        .setStrokeStyle(Scalar.valueOf(1))
        .beginStroke(color)
        .drawRoundRect(0.5,0.5,bounds.width,bounds.height,0)
        .endStroke();
        var cr = cornerRadius.toFloat();
        drawCorner(mLTCorner,-cr,-cr);
        drawCorner(mRTCorner,bounds.width-cr,-cr);
        drawCorner(mLBCorner,-cr,bounds.height-cr);
        drawCorner(mRBCorner,bounds.width-cr,bounds.height-cr);
        shape.setBounds(0,0,bounds.width,bounds.height);
        return this;
    }
    function drawCorner(s: Shape, x: Float, y: Float) {
        s.graphics
        .setStrokeStyle(1)
        .beginStroke(color)
        .beginFill(cornerFillColor)
        .drawRoundRect(x+0.5,y+0.5,cornerRadius.toFloat()*2,cornerRadius.toFloat()*2,0);
    }
    public function clear() {
        mBox.graphics.clear();
        mRBCorner.graphics.clear();
        mRTCorner.graphics.clear();
        mLTCorner.graphics.clear();
        mLBCorner.graphics.clear();
    }

    public function hitsCorner(x: Float, y: Float): Corner {
        var hw = cornerRadius.toFloat()*2;
        var bounds = shape.getTransformedBounds();
        inline function isLeft (_x: Float): Bool {
            return bounds.x-hw <= _x && _x <= bounds.x+hw;
        }
        inline function isRight (_x: Float): Bool {
            return bounds.x+bounds.width-hw <= _x && _x <= bounds.x+bounds.width+hw;
        }
        inline function isTop (_y: Float): Bool {
            return bounds.y-hw <= _y && _y <= bounds.y+hw;
        }
        inline function isBottom (_y: Float): Bool {
            return bounds.y+bounds.height-hw <= _y && _y <= bounds.y+bounds.height+hw;
        }
        if (isLeft(x)) {
            if (isTop(y)) {
                return CORNER_LT;
            } else if (isBottom(y)) {
                return CORNER_LB;
            }
        }else if (isRight(x)) {
            if (isTop(y)) {
                return CORNER_RT;
            } else if (isBottom(y)) {
                return CORNER_RB;
            }
        }
        return null;
    }

    public static function getPointerCSS(corner: Corner): String {
        if (corner == null) return CursorUtil.POINTER;
        return CursorUtil.resizeCursor(corner.isLeft,corner.isTop);
    }

}
