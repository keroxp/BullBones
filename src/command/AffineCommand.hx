package command;
import canvas.MainCanvas;
import createjs.easeljs.DisplayObject;
import createjs.easeljs.Matrix2D;
using figure.Figures;
class AffineCommand<AT : DisplayObject> extends DisplayCommand<AT> implements Undoable {
    private var mBeforeAlpha: Float;
    private var mBeforeMatrix: Matrix2D;
    private var mAfterAlpha: Float;
    private var mAfterMatrix: Matrix2D;
    public function new (d: AT, canvas: MainCanvas) {
        super(d,canvas);
        mBeforeMatrix = d.getMatrix().clone();
        mBeforeAlpha = d.alpha;
    }
    private function _do(draggable: AT, undo: Bool) {
        if (undo) {
            mBeforeMatrix.decompose(draggable);
            draggable.alpha = mBeforeAlpha;
        } else {
            mAfterMatrix.decompose(draggable);
            draggable.alpha = mAfterAlpha;
        }
    }

    public function exec<ET>(args: Dynamic -> ET): Undoable {
        mAfterMatrix = target.getMatrix().clone();
        mAfterAlpha = target.alpha;
        isExcuted = true;
        return this;
    }

    public function undo(): Void {
        if (isExcuted) _do(target,true);
    }
    public function redo(): Void {
        if (isExcuted) _do(target,false);
    }

    override public function toString(): String {
        return '[DisplayCommand]';
    }

}
