package event;
import hammer.HammerEvent;
class MouseEventCapture {
    public var startX(default, null): Int;
    public var startY(default, null): Int;
    public var prevX(default, null): Int;
    public var prevY(default, null): Int;
    public function new() {
    }
    public function down(e: HammerEvent) {
        startX = e.center.x;
        startY = e.center.y;
        prevX = startX;
        prevY = startY;
    }
    public function move(e: HammerEvent) {
        prevX = e.center.x;
        prevY = e.center.y;
    }
    public function getMoveX(e: HammerEvent): Int {
        return e.center.x-prevX;
    }
    public function getMoveY(e: HammerEvent): Int {
        return e.center.y-prevY;
    }
    public function getTotalMoveX(e: HammerEvent): Int {
        return e.center.x-startX;
    }
    public function getTotalMoveY(e: HammerEvent): Int {
        return e.center.y-startY;
    }
    public function up(e: HammerEvent) {

    }
}
