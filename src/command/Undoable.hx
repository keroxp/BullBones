package command;

interface Undoable {
    public function exec<ET>(exec: Dynamic -> ET): Undoable;
    public function undo(): Void;
    public function redo(): Void;
    public function toString(): String;
}
