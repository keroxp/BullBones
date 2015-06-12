package event;
import js.html.TouchEvent;
import util.BrowserUtil;
import js.html.Element;
import js.html.UIEvent;

typedef MouseEventCaptureCallback = MouseEventCapture -> Void;

class MouseEventCapture {
    public var startX(default, null): Int = 0;
    public var startY(default, null): Int = 0;
    public var x(default, null): Int = 0;
    public var y(default, null): Int = 0;
    public var deltaX(default, null): Int = 0;
    public var deltaY(default, null): Int = 0;
    public var totalDeltaX(default, null): Int;
    function get_totalMoveX(): Int {
        return x - startX;
    }
    public var totalDeltaY(default, null): Int;
    function get_totalMoveY(): Int {
        return y - startY;
    }
    public var srcEvent: UIEvent;
    public function new() {
    }
    private function getClientX(e: UIEvent): Int {
        if (BrowserUtil.isBrowser()) {
            return Reflect.getProperty(e,"clientX") ;
        } else {
            var te: TouchEvent = cast e;
            return te.touches.item(0).clientX;
        }
    }
    private function getClientY(e: UIEvent): Int {
        if (BrowserUtil.isBrowser()) {
            return Reflect.getProperty(e,"clientY");
        } else {
            var te: TouchEvent = cast e;
            return te.touches.item(0).clientY;
        }
    }
    private function down(e: UIEvent): MouseEventCapture {
        startX = getClientX(e);
        startY = getClientY(e);
        this.x = startX;
        this.y = startY;
        srcEvent = e;
        return this;
    }
    private function move(e: UIEvent): MouseEventCapture {
        var _x = getClientX(e);
        var _y = getClientY(e);
        deltaX = _x - x;
        deltaY = _y - y;
        this.x = _x;
        this.y = _y;
        srcEvent = e;
        return this;
    }
    private function up(e: UIEvent): MouseEventCapture {
        srcEvent = e;
        return this;
    }
    public function onDown (el: Element,  callback: MouseEventCaptureCallback) {
        var ev = BrowserUtil.isBrowser() ? "mousedown" : "touchstart";
        el.addEventListener(ev, function (e: UIEvent) {
            callback(down(e));
        }, false);
    }
    public function onMove(el: Element, callback: MouseEventCaptureCallback) {
        var ev = BrowserUtil.isBrowser() ? "mousemove" : "touchmove";
        el.addEventListener(ev, function (e: UIEvent) {
            callback(move(e));
        }, false);
    }

    public function onUp(el: Element, callback: MouseEventCaptureCallback) {
        var ev = BrowserUtil.isBrowser() ? "mouseup" : "touchend";
        el.addEventListener(ev, function (e: UIEvent) {
            callback(up(e));
        }, false);
    }
}

