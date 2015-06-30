package model;
class ZoomEditor {
    public var minScale: Float = 0.1;
    public var maxScale: Float = 5;
    public var scale(default,set): Float = 1.0;
    function set_scale(value:Float) {
        if (value < minScale) {
            value = minScale;
        } else if (maxScale < value) {
            value = maxScale;
        }
        // 必ず100%を通るようにする
        if ((this.scale < 1 && 1 < value) || (value < 1 && 1 < this.scale)) {
            value = 1;
        }
        return this.scale = value;
    }
    public var pivotX: Float;
    public var pivotY: Float;
    public function new(?scale: Float = 1, ?pivotX: Float, ?pivotY: Float) {
        this.scale = scale;
        this.pivotX = pivotX;
        this.pivotY = pivotY;
    }
    public function clone(): ZoomEditor {
        return new ZoomEditor(scale, pivotX, pivotY);
    }
    public function zoomUnit (): Float {
        if (scale <= 0.5){
            return 0.1;
        }else if (0.5 < scale && scale < 2) {
            return 0.25;
        } else if (2 <= scale) {
            return 0.5;
        }
        return 1;
    }
    public function zoomIn(): ZoomEditor {
        var ret = clone();
        ret.scale += zoomUnit();
        return ret;
    }
    public function zoomOut(): ZoomEditor {
        var ret = clone();
        ret.scale -= zoomUnit();
        return ret;
    }
}
