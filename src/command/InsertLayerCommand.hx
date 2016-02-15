package command;
import figure.Layer;
import createjs.easeljs.Container;
class InsertLayerCommand extends DisplayCommand<Layer> implements Undoable {
    private var mParent: Container;
    private var mIndex: Int;

    public function exec<ET>(arg: Dynamic -> ET): Undoable {
        arg(null);
        mParent = target.parent;
        mIndex = mParent.getChildIndex(target);
        isExcuted = true;
        return this;
    }


    public function undo():Void {
        if (isExcuted) {
            mainCanvas.deleteLayer(target,true);
        }
    }

    public function redo():Void {
        if (isExcuted) {
            mainCanvas.insertLayer(target,true,mIndex);
        }
    }
    override public function toString(): String {
        return '[InsertLayerCommand]';
    }
}
