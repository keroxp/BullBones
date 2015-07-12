package command;
import util.FigureUtil;
import createjs.easeljs.DisplayObject;
import figure.ShapeFigure;
import createjs.easeljs.Matrix2D;
import command.Undoable.ExecType;
using util.FigureUtil;
class DisplayCommand extends FigureCommand
implements Undoable<DisplayCommand,Dynamic,Void>{
    private var mBeforeAlpha: Float;
    private var mBeforeMatrix: Matrix2D;
    private var mAfterAlpha: Float;
    private var mAfterMatrix: Matrix2D;
    private var mBeforeScaleX: Float;
    private var mBeforeScaleY: Float;
    private var mAfterScaleX: Float;
    private var mAfterScaleY: Float;
    public function new (d: DisplayObject) {
        super(d);
        mBeforeMatrix = d.getMatrix().clone();
        mBeforeAlpha = d.alpha;
        d.asShapeFigure(function(fig: ShapeFigure) {
            mBeforeScaleX = fig.shapeScaleX;
            mBeforeScaleY = fig.shapeScaleY;
        });
    }
    private function _do(draggable: DisplayObject, undo: Bool) {
        if (undo) {
            mBeforeMatrix.decompose(draggable);
            draggable.alpha = mBeforeAlpha;
        } else {
            mAfterMatrix.decompose(draggable);
            draggable.alpha = mAfterAlpha;
        }
        if (mAfterScaleX != mBeforeScaleX || mAfterScaleY != mBeforeScaleY) {
            draggable.asShapeFigure(function(fig: ShapeFigure) {
                var sx = undo ? mBeforeScaleX : mAfterScaleX;
                var sy = undo ? mBeforeScaleY : mAfterScaleY;
                fig.applyScale(sx,sy).render();
            });
        }
        return this;
    }

    public function exec(args:ExecType<Dynamic,Void>):DisplayCommand {
        mAfterMatrix = target.getMatrix().clone();
        mAfterAlpha = target.alpha;
        target.asShapeFigure(function(fig: ShapeFigure) {
            mAfterScaleX = fig.shapeScaleX;
            mAfterScaleY = fig.shapeScaleY;
        });
        isExcuted = true;
        return this;
    }

    public function undo():DisplayCommand {
        return isExcuted ? _do(target,true) : this;
    }
    public function redo():DisplayCommand {
        return isExcuted ? _do(target,false): this;
    }

    override public function toString(): String {
        return '[DisplayCommand]';
    }

}
