package command;

import createjs.easeljs.DisplayObject;
import canvas.MainCanvas;
class DisplayCommand <T : DisplayObject> {
    public var target(default, null): T;
    public var mainCanvas(default, null): MainCanvas;
    public var isExcuted(default, null): Bool = false;
    public function new (target: T, canvas: MainCanvas) {
        this.target = target;
        this.mainCanvas = canvas;
    }
    public function toString(): String {
        return "[DisplayCommand]";
    }

}
