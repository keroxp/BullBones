package canvas;

import createjs.easeljs.DisplayObject;
import figure.BoundingBox.Corner;

enum CanvasState {
    Idle;
    UsingTool(tool: CanvasTool);
    Dragging(draggingShape: DisplayObject);
    Grabbing;
    Scaling(corner: Corner);
}