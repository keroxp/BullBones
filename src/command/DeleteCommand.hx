package command;
import command.Undoable.ExecType;
import createjs.easeljs.Container;
class DeleteCommand extends FigureCommand implements Undoable<DeleteCommand, Dynamic, Void>{
    private var mParent: Container;
    private var mIndex: Int;
    public function exec(args:ExecType<Dynamic,Void>):DeleteCommand {
        mParent = target.parent;
        mIndex = mParent.getChildIndex(target);
        args(null);
        isExcuted = true;
        return this;
    }

    public function undo():DeleteCommand {
        if (isExcuted) {
            mParent.addChildAt(target, mIndex);
        }
        return this;
    }

    public function redo():DeleteCommand {
        if (isExcuted) {
            mParent.removeChild(target);
        }
        return this;
    }
    override public function toString(): String {
        return '[DeleteCommand]';
    }
}
