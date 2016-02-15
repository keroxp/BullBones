package command;
import canvas.MainCanvas;
import createjs.easeljs.DisplayObject;
class MirroringPivotMoveCommand extends AffineCommand<DisplayObject> {
    private var mBeforePivotX: Float;
    private var mBeforePivotY: Float;
    private var mAfterPivotX: Float;
    private var mAfterPivotY: Float;
    public function new (d: DisplayObject, mcanvas: MainCanvas) {
        super(d,mcanvas);
        mBeforePivotX = mcanvas.mirroringInfo.pivotX;
        mBeforePivotY = mcanvas.mirroringInfo.pivotY;
    }
    override public function exec<ET>(args: Dynamic -> ET): Undoable {
        super.exec(args);
        mAfterPivotX = mainCanvas.mirroringInfo.pivotX;
        mAfterPivotY = mainCanvas.mirroringInfo.pivotY;
        return this;
    }

    override public function undo():Void {
        super.undo();
        mainCanvas.mirroringInfo.pivotX = mBeforePivotX;
        mainCanvas.mirroringInfo.pivotY = mBeforePivotY;
    }
    override public function redo():Void {
        super.redo();
        mainCanvas.mirroringInfo.pivotX = mAfterPivotX;
        mainCanvas.mirroringInfo.pivotY = mAfterPivotY;
    }

    override public function toString():String {
        return "[MirroringPivotMvoeCommand]";
    }

}
