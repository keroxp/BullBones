package figure;
import createjs.easeljs.Rectangle;
import geometry.Point;
import event.MouseEventCapture;
import figure.Draggable.DraggableType;
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
    public var shape(default, null): Container;
    var mLTCorner: Shape;
    var mRTCorner: Shape;
    var mLBCorner: Shape;
    var mRBCorner: Shape;
    var mBox: Shape;
    public var cornerRadius = 5.0;
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
        .setStrokeStyle(1)
        .beginStroke(color)
        .drawRoundRect(0.5,0.5,bounds.width,bounds.height,0)
        .endStroke();
        drawCorner(mLTCorner,0,0);
        drawCorner(mRTCorner,bounds.width,0);
        drawCorner(mLBCorner,0,bounds.height);
        drawCorner(mRBCorner,bounds.width,bounds.height);
        shape.setBounds(0,0,bounds.width,bounds.height);
        return this;
    }
    function drawCorner(s: Shape, x: Float, y: Float) {
        s.graphics
        .setStrokeStyle(0.2)
        .beginStroke(color)
        .beginFill(cornerFillColor)
        .drawCircle(x,y,cornerRadius);
    }
    public function clear() {
        mBox.graphics.clear();
        mRBCorner.graphics.clear();
        mRTCorner.graphics.clear();
        mLTCorner.graphics.clear();
        mLBCorner.graphics.clear();
    }

    public function hitsCorner(x: Float, y: Float): Corner {
        var hw = cornerRadius*2;
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
                return {isLeft: true, isTop: true};
            } else if (isBottom(y)) {
                return {isLeft: true, isTop: false};
            }
        }else if (isRight(x)) {
            if (isTop(y)) {
                return {isLeft: false, isTop: true};
            } else if (isBottom(y)) {
                return {isLeft: false, isTop: false};
            }
        }
        return null;
    }

    public static function getPointerCSS(corner: Corner): String {
        if (corner == null) return "pointer";
        var a = corner.isTop ? "n" : "s";
        var b = corner.isLeft ? "w" : "e";
        return a+b+"-resize";
    }

}
