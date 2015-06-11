package figure;

import hammer.HammerEvent;
import geometry.Rect;

interface Draggable {
    public var bounds(get,null): Rect;
    public var display(get, null): createjs.easeljs.DisplayObject;
    public var type(get, null): DraggableType;
    public function onDragStart(e: HammerEvent): Void;
    public function onDragMove(e: HammerEvent): Void;
    public function onDragEnd(e: HammerEvent): Void;
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
