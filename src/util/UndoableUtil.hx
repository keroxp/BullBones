package util;
import command.Undoable;
class UndoableUtil {
    public static function isInsertLayerCommand(tgt: Undoable): Bool {
        return tgt.toString().indexOf("InsertLayerCommand") > -1;
    }
    public static function isCopyLayerCommand(tgt: Undoable): Bool {
        return tgt.toString().indexOf("CopyLayerCommand") > -1;
    }
    public static function isDeleteLayerCommand(tgt: Undoable): Bool {
        return tgt.toString().indexOf("DeleteLayerCommand") > -1;
    }
}
