package command;

import createjs.easeljs.DisplayObject;
class FigureCommand {
    public var target(default, null): DisplayObject;
    public var isExcuted(default, null): Bool = false;
    public function new (target: DisplayObject) {
        this.target = target;
    }
    public function toString(): String {
        return "[FigureCommand]";
    }
    public function isInsertCommand(): Bool {
        return this.toString().indexOf("InsertCommand") > -1;
    }
    public function isCopyCommand(): Bool {
        return this.toString().indexOf("CopyCommand") > -1;
    }
    public function isDeleteCommand(): Bool {
        return this.toString().indexOf("DeleteCommand") > -1;
    }
}
