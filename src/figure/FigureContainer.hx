package figure;
import js.Error;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Container;
class FigureContainer extends Container {
    public function new() {
    }

    override public function addChildAt(child:DisplayObject, index:Float):DisplayObject {
        if (Type.getClass(child) != Type.resolveClass("figure.BaseFigure")) {
            throw new Error("");
        }
        return super.addChildAt(children,index);
    }

    public function getChildren(): Array<BaseFigure> {
        return cast children;
    }
}
