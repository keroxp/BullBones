package canvas;
import createjs.easeljs.Point;
import createjs.easeljs.Container;
import js.html.EventTarget;
import js.html.TouchEvent;
import util.BrowserUtil;
import js.html.UIEvent;


private enum EventTiming {
    Start;
    Prev;
    Current;
}
class CanvasMouseEvent {
    var mStartPointCache: Map<Int, Point> = new Map<Int, Point>();
    var mPrevPointCache: Map<Int, Point> = new Map<Int, Point>();
    var mCurPointCache: Map<Int, Point> = new Map<Int, Point>();
    private static var sTmpPoint: Point = new Point();
    private var mCacheExpired: Bool = false;
    public var startX(default, null): Float = 0;
    public var startY(default, null): Float = 0;
    public var x(default, null): Float = 0;
    public var y(default, null): Float = 0;
    public var prevX(get, null): Float = 0;
    function get_prevX():Float {
        return x-deltaX;
    }
    public var prevY(get, null): Float = 0;
    function get_prevY(): Float {
        return y-deltaY;
    }
    public var deltaX(get, null): Float = 0;
    public function get_deltaX () {
        return deltaX;
    }
    public var deltaY(get, null): Float = 0;
    public function get_deltaY () {
        return deltaY;
    }
    public var totalDeltaX(get, null): Float;
    function get_totalDeltaX(): Float {
        return (x - startX);
    }
    public var totalDeltaY(get, null): Float;
    function get_totalDeltaY(): Float {
        return (y - startY);
    }
    public var srcEvent: UIEvent;
    public function new() {
    }
    private function getClientX(e: UIEvent): Float {
        if (BrowserUtil.isBrowser) {
            return Reflect.getProperty(e,"clientX") * BrowserUtil.window.devicePixelRatio;
        } else {
            var te: TouchEvent = cast e;
            return te.touches.item(0).clientX * BrowserUtil.window.devicePixelRatio;
        }
    }
    private function getClientY(e: UIEvent): Float {
        if (BrowserUtil.isBrowser) {
            return Reflect.getProperty(e,"clientY") * BrowserUtil.window.devicePixelRatio;
        } else {
            var te: TouchEvent = cast e;
            return te.touches.item(0).clientY * BrowserUtil.window.devicePixelRatio;
        }
    }
    private function down(e: UIEvent): CanvasMouseEvent {
        startX = getClientX(e);
        startY = getClientY(e);
        x = startX;
        y = startY;
        srcEvent = e;
        return this;
    }
    private function move(e: UIEvent): CanvasMouseEvent {
        var _x = getClientX(e);
        var _y = getClientY(e);
        deltaX = _x - x;
        deltaY = _y - y;
        x = _x;
        y = _y;
        srcEvent = e;
        return this;
    }
    private function up(e: UIEvent): CanvasMouseEvent {
        srcEvent = e;
        return this;
    }

    public function onDown (el: EventTarget,  callback: CanvasMouseEvent -> Void, ?filter: UIEvent -> Bool) {
        var ev = BrowserUtil.isBrowser ? "mousedown" : "touchstart";
        el.addEventListener(ev, function (e: UIEvent) {
            if (filter != null && !filter (e)) return;
            callback(down(e));
            mCacheExpired = true;
        }, false);
    }
    public function onMove(el: EventTarget, callback: CanvasMouseEvent -> Void, ?filter: UIEvent -> Bool) {
        var ev = BrowserUtil.isBrowser ? "mousemove" : "touchmove";
        el.addEventListener(ev, function (e: UIEvent) {
            if (filter != null && !filter (e)) return;
            callback(move(e));
            mCacheExpired = true;
        }, false);
    }
    public function onUp(el: EventTarget, callback: CanvasMouseEvent -> Void, ?filter: UIEvent -> Bool) {
        var ev = BrowserUtil.isBrowser ? "mouseup" : "touchend";
        el.addEventListener(ev, function (e: UIEvent) {
            if (filter != null && !filter (e)) return;
            callback(up(e));
            mCacheExpired = true;
        }, false);
    }
    private function _getLocal(container: Container, timing: EventTiming): Point {
        var cache = switch (timing) {
            case Start: mStartPointCache;
            case Prev: mPrevPointCache;
            case Current: mCurPointCache;
        }
        var lpt = switch (timing) {
            case Start: sTmpPoint.x = startX; sTmpPoint.y = startY; sTmpPoint;
            case Prev: sTmpPoint.x = prevX; sTmpPoint.y = prevY; sTmpPoint;
            case Current: sTmpPoint.x = x; sTmpPoint.y = y; sTmpPoint;
        }
        var ret: Point;
        var cid = Std.int(container.id);
        if (!cache.exists(cid)) {
            ret = container.globalToLocal(lpt.x,lpt.y);
            cache.set(cid, ret);
        } else {
            if (mCacheExpired) {
                ret = container.globalToLocal(lpt.x,lpt.y, cast cache.get(cid));
            } else {
                ret = cast cache.get(cid);
            }
        }
        return ret;
    }
    public function getLocalStart(container: Container): Point {
        return _getLocal(container, Start);
    }
    public function getLocalPrev(container: Container): Point {
        return _getLocal(container, Prev);
    }
    public function getLocal(container: Container): Point {
        return _getLocal(container, Current);
    }
}

