package hammer;
import js.html.Element;
@:native("Hammer")
extern class Hammer {
    public function new(el: Element, ?opts: Dynamic): Void;
    public function on (ev: String, callback: HammerEvent -> Void) :Hammer;
}
