package command;
typedef ExecType <E, R> = E -> R;
interface Undoable <T, E, R> {
    public function exec(args: ExecType<E, R>): T;
    public function undo(): T;
    public function redo(): T;
}
