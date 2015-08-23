package command;
import createjs.easeljs.Container;
import command.Undoable.ExecType;
class InsertCommand extends FigureCommand implements Undoable<InsertCommand,Dynamic,Void>{
    private var mParent: Container;
    private var mIndex: Int;

    public function exec(args:ExecType<Dynamic,Void>):InsertCommand {
        args(null);
        mParent = target.parent;
        mIndex = mParent.getChildIndex(target);
        isExcuted = true;
        return this;
    }

    public function undo():InsertCommand {
        if (isExcuted) {
            canvas.deleteFigure(target,true);
        }
        return this;
    }

    public function redo():InsertCommand {
        if (isExcuted) {
            canvas.insertFigure(target,true,mIndex);
        }
        return this;
    }
    override public function toString(): String {
        return '[InsertCommand]';
    }
}
