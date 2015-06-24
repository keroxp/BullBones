package figure;

import createjs.easeljs.DisplayObject;
import event.MouseEventCapture;

interface Draggable {
    public var display(get, null): DisplayObject;
    public var type(get, null): DraggableType;
    public function render(?arg: Dynamic = null): Draggable;
    public function clone(): Draggable;
    public function onDragStart(e: MouseEventCapture): Void;
    public function onDragMove(e: MouseEventCapture): Void;
    public function onDragEnd(e: MouseEventCapture): Void;
}

class DraggableUtil {
    public static function isImageFigure (d: Draggable): Bool {
        return d != null && d.type == DraggableType.Image;
    }
}

enum DraggableType {
    Figure;
    Image;
}
