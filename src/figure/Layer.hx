package figure;
import createjs.easeljs.DisplayObject;
import js.html.Image;
interface Layer {
    public function getDisplay(): DisplayObject;
    public function getLayerId(): Int;
    public function getTile(): String;
    public function getImageURL(): String;
    public function render(): Dynamic;
}
