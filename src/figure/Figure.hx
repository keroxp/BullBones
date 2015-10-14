package figure;
import createjs.easeljs.Rectangle;
interface Figure {
    public function render(): Dynamic;
    public function setActive(bool: Bool): Void;
    public function getTransformedBounds(): Rectangle;
    public function type(): FigureType;
    public function onScale(sx: Float, sy: Float): Void;
    public function onMove(dx: Float, dy: Float): Void;
}
