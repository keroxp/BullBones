package command;
import canvas.MainCanvas;
import figure.Layer;
class LayerAffineCommand extends AffineCommand<Layer>{
    private var mBeforeScaleX: Float;
    private var mBeforeScaleY: Float;
    private var mAfterScaleX: Float;
    private var mAfterScaleY: Float;
    public function new(target: Layer, cvs: MainCanvas) {
        super(target,cvs);
        mBeforeScaleX = target.layerScaleX;
        mBeforeScaleY = target.layerScaleY;
    }

    override public function exec<ET>(args: Dynamic -> ET): Undoable {
        super.exec(args);
        mAfterScaleX = target.layerScaleX;
        mAfterScaleY = target.layerScaleY;
        return this;
    }

    override public function undo():Void {
        super.undo();
        if (isExcuted) {
            if (mAfterScaleX != mBeforeScaleX || mAfterScaleY != mBeforeScaleY) {
                target.applyScale(mBeforeScaleX,mBeforeScaleY);
            }
        }
    }

    override public function redo():Void {
        super.redo();
        if (isExcuted) {
            if (mAfterScaleX != mBeforeScaleX || mAfterScaleY != mBeforeScaleY) {
                target.applyScale(mAfterScaleX,mAfterScaleY);
            }
        }
    }

    override public function toString():String {
        return "[LayerAffineCommand]";
    }

}
