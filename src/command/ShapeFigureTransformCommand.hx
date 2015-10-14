package command;
import figure.BaseFigure;
import command.Undoable.ExecType;
import canvas.MainCanvas;
import figure.ShapeFigure;
class ShapeFigureTransformCommand extends DisplayCommand {
    private var mBeforeScaleX: Float;
    private var mBeforeScaleY: Float;
    private var mAfterScaleX: Float;
    private var mAfterScaleY: Float;
    private var mShape: ShapeFigure;
    public function new(shape: ShapeFigure, canvas: MainCanvas) {
        super(shape, canvas);
        mShape = shape;
        mBeforeScaleX = shape.shapeScaleX;
        mBeforeScaleY = shape.shapeScaleY;
    }

    override function _do(draggable:BaseFigure, undo:Bool): DisplayCommand {
        super._do(draggable, undo);
        if (mAfterScaleX != mBeforeScaleX || mAfterScaleY != mBeforeScaleY) {
            var sx = undo ? mBeforeScaleX : mAfterScaleX;
            var sy = undo ? mBeforeScaleY : mAfterScaleY;
            mShape.applyScale(sx,sy).render();
        }
        return this;
    }

    override public function exec(args:ExecType<Dynamic,Void>):DisplayCommand {
        super.exec(args);
        mAfterScaleX = mShape.shapeScaleX;
        mAfterScaleY = mShape.shapeScaleY;
        return this;
    }
}
