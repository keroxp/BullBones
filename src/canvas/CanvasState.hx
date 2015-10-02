package canvas;

import createjs.easeljs.DisplayObject;
import canvas.CanvasState.CanvasEventState;
import figure.BoundingBox.Corner;
import figure.ShapeFigure;

enum CanvasEventState {
    Idle;
    Drawing;
    Dragging;
    Grabbing;
    Scaling;
}

class CanvasState {
    public function Idle() {
        this.eventState = CanvasEventState.Idle;
    }
    public function Dragging(dragging: DisplayObject) {
        this.eventState = CanvasEventState.Dragging;
        this.draggingFigure = dragging;
    }
    public function Drawing(drawing: ShapeFigure, ?mirror: ShapeFigure) {
        this.eventState = CanvasEventState.Drawing;
        this.drawingFigure = drawing;
        this.mirrorFigure = mirror;
    }
    public function Scaling(scaling: Corner) {
        this.eventState = CanvasEventState.Scaling;
        this.scalingCorner = scaling;
    }
    public function Grabbing() {
        this.eventState = CanvasEventState.Grabbing;
    }
    public function new () {}
    public var drawingFigure(default,null): ShapeFigure;
    public var draggingFigure(default,null): DisplayObject;
    public var mirrorFigure(default,null): ShapeFigure;
    public var scalingCorner(default,null): Corner;
    public var eventState(default, null): CanvasEventState = CanvasEventState.Idle;
}