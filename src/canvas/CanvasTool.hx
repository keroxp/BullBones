package canvas;
interface CanvasTool {
    public function onMouseDown(mcanvas: MainCanvas, e: CanvasMouseEvent): Void;
    public function onMouseMove(mcanvas: MainCanvas, e: CanvasMouseEvent): Void;
    public function onMouseUp(mcanvas: MainCanvas, e: CanvasMouseEvent): Void;
    public function toString(): String;
}
