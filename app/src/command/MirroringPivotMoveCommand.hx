package command;
import canvas.MainCanvas;
import createjs.easeljs.DisplayObject;
import command.Undoable.ExecType;
class MirroringPivotMoveCommand extends DisplayCommand {
    private var mBeforePivotX: Float;
    private var mBeforePivotY: Float;
    private var mAfterPivotX: Float;
    private var mAfterPivotY: Float;
    public function new (d: DisplayObject, mcanvas: MainCanvas) {
        super(d,mcanvas);
        mBeforePivotX = mcanvas.mirroringInfo.pivotX;
        mBeforePivotY = mcanvas.mirroringInfo.pivotY;
    }
    override public function exec(args:ExecType<Dynamic,Void>):DisplayCommand {
        super.exec(args);
        mAfterPivotX = this.canvas.mirroringInfo.pivotX;
        mAfterPivotY = this.canvas.mirroringInfo.pivotY;
        return this;
    }

    override public function undo():DisplayCommand {
        super.undo();
        this.canvas.mirroringInfo.pivotX = mBeforePivotX;
        this.canvas.mirroringInfo.pivotY = mBeforePivotY;
        return this;
    }
    override public function redo():DisplayCommand {
        super.redo();
        this.canvas.mirroringInfo.pivotX = mAfterPivotX;
        this.canvas.mirroringInfo.pivotY = mAfterPivotY;
        return this;
    }
}
