package support;
import canvas.MainCanvas;
import canvas.CanvasMouseEvent;
import figure.ShapeFigure;
import js.Browser;
import js.html.CanvasElement;
class Ghost {
    private var mCanvas: CanvasElement = cast Browser.document.createElement("canvas");
    public function new(width: Int, height: Int) {
        mCanvas.width = width;
        mCanvas.height = height;
    }
    public static function generate(mcanvas: MainCanvas, e: CanvasMouseEvent, buffer: ShapeFigure) {
        // ゴースト生成
        // 完全に線対称なもの
        
    }
}
