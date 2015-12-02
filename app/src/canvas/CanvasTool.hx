package canvas;
interface CanvasTool {
    public function onMouseDown(canvas: MainCanvas, e: CanvasMouseEvent): Void;
    public function onMouseMove(canvas: MainCanvas, e: CanvasMouseEvent): Void;
    public function onMouseUp(canvas: MainCanvas, e: CanvasMouseEvent): Void;
}
