package hammer;
import js.html.Element;
import js.html.TouchEvent;
import js.html.Touch;
typedef HammerPoint = {
    var x: Int;
    var y: Int;
}
extern class HammerEvent {
    var pointers : Array<Touch>;
    var changedPointers : Array<Touch>;
    var pointerType : String;
    var srcEvent : TouchEvent;
    var isFirst : Bool;
    var isFinal : Bool;
    var eventType : Int;
    var center : HammerPoint;
    var timeStamp : Int;
    var deltaTime : Int;
    var angle : Float;
    var distance : Float;
    var deltaX : Float;
    var deltaY : Float;
    var offsetDirection : Float;
    var scale : Float;
    var rotation : Float;
    var velocity : Float;
    var velocityX : Float;
    var velocityY : Float;
    var direction : Int;
    var target : Element;
    var type : String;
    function preventDefault() : Void;
}
