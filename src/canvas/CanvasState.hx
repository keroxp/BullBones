package canvas;

import createjs.easeljs.DisplayObject;
import figure.BoundingBox.Corner;

enum CanvasState {
    Idle;
    Drawing(tool: CanvasTool);
    Dragging(draggingShape: DisplayObject);
    Grabbing;
    Scaling(corner: Corner);
}