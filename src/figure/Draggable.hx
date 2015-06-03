package figure;

import geometry.Rect;
interface Draggable {
    public var bounds(get,null): Rect;
    public var display(get, null): createjs.easeljs.DisplayObject;
    public function onDragStart(e: js.html.MouseEvent): Void;
    public function onDragMove(e: js.html.MouseEvent): Void;
    public function onDragEnd(e: js.html.MouseEvent): Void;
}
