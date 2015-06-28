package figure;

import createjs.easeljs.DisplayObject;

interface Draggable {
    public var display(get, null): DisplayObject;
    public var type(get, null): DraggableType;
    public function render(?arg: Dynamic = null): Draggable;
    public function clone(): Draggable;
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
