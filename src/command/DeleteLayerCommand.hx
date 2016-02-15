package command;
import figure.Layer;
import createjs.easeljs.Container;
class DeleteLayerCommand extends DisplayCommand<Layer> implements Undoable {
    private var mParent: Container;
    private var mIndex: Int;
    public function exec<ET>(args: Dynamic -> ET): Undoable {
        mParent = target.parent;
        mIndex = mParent.getChildIndex(target);
        args(null);
        isExcuted = true;
        return this;
    }

    public function undo():Void {
        if (isExcuted) {
            mainCanvas.insertLayer(target,true,mIndex);
        }
    }

    public function redo():Void {
        if (isExcuted) {
            mainCanvas.deleteLayer(target,true);
        }
    }
    override public function toString(): String {
        return '[DeleteLayerCommand]';
    }
}
