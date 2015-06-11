package geometry;
import js.html.MouseEvent;
class MouseEventCapture {
    public var startX(default, null): Int;
    public var startY(default, null): Int;
    public var prevX(default, null): Int;
    public var prevY(default, null): Int;
    public function new() {
    }
    public function down(e: MouseEvent) {
        startX = e.clientX;
        startY = e.clientY;
        prevX = e.clientX;
        prevY = e.clientY;
    }
    public function move(e: MouseEvent) {
        prevX = e.clientX;
        prevY = e.clientY;
    }
    public function getMoveX(e: MouseEvent): Int {
        return e.clientX-prevX;
    }
    public function getMoveY(e: MouseEvent): Int {
        return e.clientY-prevY;
    }
    public function getTotalMoveX(e: MouseEvent): Int {
        return e.clientX-startX;
    }
    public function getTotalMoveY(e: MouseEvent): Int {
        return e.clientY-startY;
    }
    public function up(e: MouseEvent) {

    }
}
