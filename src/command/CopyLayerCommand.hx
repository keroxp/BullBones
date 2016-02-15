package command;
import figure.Layer;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Container;
class CopyLayerCommand extends DisplayCommand<Layer> implements Undoable {
    private var mParent: Container;
    public var copiedObject: Layer;

    public function exec<ET>(args: Dynamic -> ET): Undoable {
        mParent = target.parent;
        copiedObject = cast args(null);
        isExcuted = true;
        return this;
    }


    public function undo(): Void {
        if (isExcuted) {
            mainCanvas.deleteLayer(copiedObject,true);
        }
    }

    public function redo(): Void {
        if (isExcuted) {
            var i = mParent.getChildIndex(target) + 1;
            mainCanvas.insertLayer(copiedObject,true, i);
        }
    }

    override public function toString(): String {
        return '[CopyLayerCommand]';
    }
}
