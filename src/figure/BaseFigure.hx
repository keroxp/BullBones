package figure;
import protocol.Clonable;
import js.Error;
import createjs.easeljs.DisplayObject;
class BaseFigure extends DisplayObject
implements Clonable
implements Figure {
    public function new() {
        super();
    }

    override public function clone(): Dynamic {
        throw new Error("need to verride");
    }

    public function render():Dynamic {
        return this;
    }

    public function type():FigureType {
        throw new Error("need to override");
    }

    public function setActive(bool:Bool):Void {
        throw new Error("need to override");
    }

    public function onScale(sx:Float, sy:Float):Void {
        scaleX = sx;
        scaleY = sy;
    }

    public function onMove(dx:Float, dy:Float):Void {
        x += dx;
        y += dy;
    }
}
