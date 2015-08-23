package command;
import createjs.easeljs.DisplayObject;
import command.Undoable.ExecType;
import createjs.easeljs.Container;
class CopyCommand extends FigureCommand implements Undoable<CopyCommand, Dynamic, DisplayObject>{
    private var mParent: Container;
    private var mCopied: DisplayObject;

    public function exec(args:ExecType<Dynamic, DisplayObject>):CopyCommand {
        mParent = target.parent;
        mCopied = args(null);
        isExcuted = true;
        return this;
    }

    public function undo():CopyCommand {
        if (isExcuted) {
            canvas.deleteFigure(mCopied,true);
        }
        return this;
    }

    public function redo():CopyCommand {
        if (isExcuted) {
            var i = mParent.getChildIndex(target) + 1;
            canvas.insertFigure(mCopied,true, i);
        }
        return this;
    }

    override public function toString(): String {
        return '[CopyCommand]';
    }
}
